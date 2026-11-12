# web：Web 栈落地指南

> **一句话定位**：[adoption-workflow.md](adoption-workflow.md) 步 2/3/5 在 Web 栈的投影——`platforms/web/tokens.css` 的引入与双主题切换、动效五映射（三档时长／两缓动／意图事务／交错入场／减动效退化）、状态分层实现（hover 双轨三法／pressed／禁用两档／分层卡片三层 DOM）；每节末给「与 WPF 篇的对应关系」，桌面栈细节见 [wpf.md](wpf.md)。
> **来源**：仓内 `tokens/` 与 `platforms/web/tokens.css` 的用法展开＋skill「fts-style-system」动效/状态规则通用化；变量名严格按 TOKEN-MAP-V1 §一 CSS 规则（DTCG 路径 `.`→`-`＋`--` 前缀）。
> **日期**：2026-11-11　**行数预算**：≤420 行

## 一、定位与总纲关系

1. 本文＝总纲步 2/3/5 的 Web 投影；步 1/4/6/7/8 平台无关，不在本文重复。
2. 消费物：`platforms/web/tokens.css`——CSS 变量表（`:root`＝浅色解析值，`[data-theme="dark"]`＝深色解析值，共 106 变量）；色原始组不产变量，变量只在语义层出口。
3. 数值口径：本文代码全部消费变量；个别字面数值仅为示例并括注 token 路径。
4. 特性验证状态：本文用到的 `calc()`＋`min()` 组合、`isolation`＋负序覆层、`color-scheme`、`dataset`、媒体查询 `change` 事件均为主流双引擎现行版已验证；需支持旧引擎（如 `change` 事件之前的 Safari）时对媒体查询监听做 `addListener` 回退。

## 二、tokens.css 引入与主题切换

### 2.1 引入与首批消费

```html
<link rel="stylesheet" href="tokens.css" />
```

```css
/* 变量即设计词汇；组件样式零字面色值 */
.card {
  background: var(--color-surface-card);
  color: var(--color-text-primary);
  border: 1px solid var(--color-border-default);
  border-radius: var(--dimension-radius-surface);
}
```

### 2.2 主题切换（显式键＋跟随系统＋防闪变）

tokens.css 已内置 `[data-theme="dark"]` 深色块；应用侧补「未显式选择时跟随系统＋用户选择持久化＋首帧前定键」：

```html
<script>
  // 内联于 tokens.css 之后、首帧渲染前：无闪变
  (() => {
    const root = document.documentElement;
    const saved = localStorage.getItem('theme');  // 用户强制（'light'|'dark'|null）
    const system = matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    root.dataset.theme = saved ?? system;          // 优先级：显式 > 系统
    matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
      if (!localStorage.getItem('theme')) root.dataset.theme = e.matches ? 'dark' : 'light';
    });
  })();
</script>
```

```css
/* 原生控件/滚动条跟随主题（表单、滚动条等 UA 部件配色） */
:root { color-scheme: light; }
[data-theme='dark'] { color-scheme: dark; }
```

- 切换主题＝改 `data-theme` 一个属性，全部变量瞬时换轴，组件层零感知。
- 切换按钮只写 `localStorage`＋`dataset.theme`，不做逐组件刷新。

**与 WPF 篇的对应关系**

| Web | WPF 篇 |
|---|---|
| `:root`／`[data-theme="dark"]` 两套变量 | Light/Dark 双字典（§二.2） |
| 改 `data-theme` 属性 | 主题字典整本替换（§二.3） |
| `matchMedia`＋首帧前内联脚本 | 系统亮暗探测＋预览/用户/系统三层（§二.3） |
| `color-scheme` | 系统材质壳与原生件配对（§五.1） |

## 三、动效映射（五映射）

### 3.1 三档时长 → CSS 变量

```css
.fade-layer {
  transition: opacity var(--motion-duration-fade-visibility) var(--motion-easing-enter);
}
```

- 全部过渡时长取 `--motion-duration-*`（三档及其场景别名，如 `--motion-duration-hover-feedback`）；组件里禁止出现第 4 个裸 ms 值。
- 新场景先找别名：语义已有（悬停反馈/按压反馈/显隐淡入/删除反馈……）就直接用；确需新时长＝回 token 层加别名，不加档。

### 3.2 两缓动 → cubic-bezier() 直用

tokens.css 中缓动变量值即函数：`--motion-easing-enter: cubic-bezier(0, 0, 0, 1)`（进入态减速）、`--motion-easing-exit: cubic-bezier(1, 0, 1, 1)`（离开态加速）。**按语义选、不按数值方向**：

```css
/* 悬停抬升：进入减速、回落加速（两方向各自挂函数） */
.card-lift {
  transform: translateY(0);
  transition: transform var(--motion-duration-hover-feedback) var(--motion-easing-exit);
}
.card-lift:hover {
  transform: translateY(var(--dimension-offset-card-hover-lift)); /* -1px（示例：dimension.offset.card-hover-lift） */
  transition-timing-function: var(--motion-easing-enter);
}
```

- 位移可正可负：按「目标态」选曲线（进入视觉态=enter／离开=exit）；数值大小判据会把负向进入错配加速曲线。

### 3.3 意图事务 → 计时器模式

悬停触发的激活级内容切换是结构性反模式；确需悬停触发时用意图事务（布防→到期重验指针在内才提交）：

```js
/** 悬停意图事务：到期重验指针仍在元素内才提交（防扫边误触）。dwellMs 为驻留窗示例值。 */
function armIntent(el, dwellMs, commit) {
  let timer = 0;
  let last = { x: -1, y: -1 };
  el.addEventListener('pointerenter', (e) => {
    last = { x: e.clientX, y: e.clientY };
    timer = setTimeout(() => {
      const r = el.getBoundingClientRect();               // 到期重验
      const inside = last.x >= r.left && last.x <= r.right
        && last.y >= r.top && last.y <= r.bottom;
      if (inside) commit();                               // 布防→重验→提交
    }, dwellMs);
  });
  el.addEventListener('pointermove', (e) => { last = { x: e.clientX, y: e.clientY }; });
  el.addEventListener('pointerleave', () => clearTimeout(timer));  // 离开即撤防
}
```

### 3.4 交错入场 → transition-delay 计算

```css
.tile {
  --i: 0;  /* 序号由模板/内联注入；封顶＝交错封顶 token */
  transition:
    opacity var(--motion-duration-item-landing) var(--motion-easing-enter),
    transform var(--motion-duration-item-landing) var(--motion-easing-enter);
  transition-delay:
    calc(min(var(--i), var(--motion-stagger-tile-cap)) * var(--motion-duration-stagger-step));
}
```

```js
// 序号注入：服务端模板输出 style="--i:3"，或客户端逐元素设置；
// 入场类在挂载后下一帧添加（双重 rAF 确保起始态先生效）
requestAnimationFrame(() => requestAnimationFrame(() => grid.classList.add('is-in')));
// JS 等价写法：el.style.transitionDelay = `${Math.min(i, cap) * step}ms`;
```

- 封顶内联在 delay 里算（序号封顶后尾部节奏一致，长列表不无限递增）。

### 3.5 减动效退化（prefers-reduced-motion）

退化口径：系统/用户要求减动效时，全部动效退化为快档纯淡入或立即定格终值；交错等**时序性延迟保留**（节奏信息仍在，运动幅度归零）。

```css
@media (prefers-reduced-motion: reduce) {
  .card-lift:hover { transform: none; transition: none; }  /* 位移类：直接定格 */
  .tile {
    transition-property: opacity;                            /* 运动只留淡入 */
    transition-duration: var(--motion-duration-reduced-fade);
  }
}
```

```js
// JS 编排类动画同口径：跳过起始帧直接定格终值
const reduced = matchMedia('(prefers-reduced-motion: reduce)');
if (reduced.matches) settleImmediately(); else playEntrance();
reduced.addEventListener('change', (e) => (e.matches ? settleImmediately() : playEntrance()));
```

**与 WPF 篇的对应关系**

| Web | WPF 篇 |
|---|---|
| `transition: opacity var(--motion-duration-*)` | 淡入淡出原语（§四.1） |
| `--motion-easing-*` 直用 cubic-bezier() | SplineEase/FromToken 单点实例（§四.2） |
| 意图事务计时器（3.3） | 同一机制的计时器实现（总纲步 5） |
| `--i`×步长＋`min()` 封顶（3.4） | 交错步长/封顶 token（§四.4 清单） |
| `@media`＋matchMedia 双层退化（3.5） | AnimationsEnabled 开关立即定格（§四.1 要点 4） |

## 四、状态分层实现

### 4.1 hover 双轨三法＋pressed＋禁用两档

```css
/* A｜复合图标元素＝覆层淡入（伪元素层，不改属性值） */
.icon-btn { position: relative; isolation: isolate; }  /* isolation 建立层叠上下文 */
.icon-btn::after {
  content: ''; position: absolute; inset: 0; border-radius: inherit; z-index: -1;
  background: var(--color-interaction-hover-surface);
  opacity: 0; pointer-events: none;
  transition: opacity var(--motion-duration-hover-feedback) var(--motion-easing-enter);
}
.icon-btn:hover::after { opacity: 1; }

/* B｜单表面轻控件＝属性瞬切（零过渡，值直达） */
.chip:hover { background: var(--color-interaction-hover-surface); }

/* C｜密集内容控件＝仅描边（只换悬停描边，不换底不位移） */
.row:hover { border-color: var(--color-border-hover); }
```

```css
/* pressed 范式：瓦片族＝缩放；标准钮族＝换色 */
.tile:active { transform: scale(var(--motion-scale-tile-press)); }
.btn-solid:active { background: var(--color-interaction-hover-surface); }

/* 禁用两档：控件族/整卡；不可用≠禁用——入口守卫＋徽章表达，元素保持可命中 */
.control[aria-disabled='true'] { opacity: var(--motion-opacity-control-disabled); }
.card.is-disabled { opacity: var(--motion-opacity-card-disabled); }
```

- 覆层用 `z-index: -1`＋父层 `isolation: isolate`：覆层垫在内容之下、底色之上（已验证通用技法）。
- 「分层交叉淡入」在 CSS 的第一选择＝直接过渡 `background-color`/`border-color`（连续淡入，非瞬切换色）；伪元素覆层用于需保留底面细节或叠加非替换语义时。

### 4.2 分层卡片：三层 DOM

```html
<article class="card">
  <div class="card__shadow" aria-hidden="true"></div>  <!-- 阴影层：独立、不含内容 -->
  <div class="card__surface">                          <!-- 内容容器：底色/描边/圆角 -->
    <header class="card__head"><!-- 标题行与操作位（固定预留格） --></header>
    <p class="card__body"><!-- 正文（行数上限由 token 锁定） --></p>
  </div>
</article>
```

```css
.card {
  position: relative;
  margin: 0 var(--dimension-spacing-card-inset) var(--dimension-spacing-card-gutter);
}
.card__shadow {
  position: absolute; inset: 0; border-radius: var(--dimension-radius-card);
  box-shadow: var(--color-shadow-card);   /* tokens.css 已折叠为 box-shadow 值 */
  pointer-events: none;                   /* 阴影层不参与命中 */
}
.card__surface {
  position: relative; border-radius: var(--dimension-radius-card);
  background: var(--color-surface-card); border: 1px solid var(--color-border-default);
  padding: var(--dimension-spacing-card-padding);
  transition: background-color var(--motion-duration-hover-feedback) var(--motion-easing-enter),
              border-color var(--motion-duration-hover-feedback) var(--motion-easing-enter);
}
.card.is-selected .card__surface {
  background: var(--color-interaction-selected-card-surface);
  border-color: var(--color-interaction-selected-card-border);
}
```

- 根＝布局外距与命中；阴影层＝绝对定位独立节点（不裹内容、不挡命中）；内容容器＝底色/描边/圆角。选中态走 `background-color` 连续过渡（＝桌面栈覆层交叉淡入的等价表达）。
- CSS 的 `box-shadow` 不栅格化子树（无桌面栈效果关闭次像素渲染的副作用）——分层在此的价值是结构与命中隔离（阴影层 `pointer-events: none`、状态层与内容层解耦）。
- 右上操作位固定预留（格子隐藏留空、其余零漂移）：操作格用固定宽列（示例 30px＝`dimension.size.card-operation-column`）。

**与 WPF 篇的对应关系**

| Web | WPF 篇 |
|---|---|
| hover 双轨三法（4.1 A/B/C） | hover 双轨（§四.1 覆层淡入同源；类型学叙述在交互状态篇） |
| `transform: scale(var(--motion-scale-tile-press))` | 按压缩放范式（瓦片族，动效基建同源） |
| 禁用两档 opacity 变量 | 禁用不透明度两档常量（§二.1） |
| 三层 DOM（4.2） | 卡片根/阴影层/内容容器三层（§一管线与范式篇） |
| `background-color` 连续过渡 | 分层交叉淡入原语（§四.1） |
| 阴影层 `pointer-events: none` | 阴影层不参与命中（范式篇分层卡片） |

## 五、验收自查

- ☐ 组件样式零字面色值/时长：全部取 `--*` 变量（全仓 grep `#[0-9a-fA-F]{3,8}` 与 `\d+ms` 只应命中 tokens.css）。
- ☐ 主题切换只动 `data-theme`；`color-scheme` 成对；首帧前定键无闪变。
- ☐ 动效五映射齐：三档／两缓动／意图事务／交错封顶／减动效退化。
- ☐ hover 三法各就各位、无第四种；pressed/禁用按类型学落位；不可用不走禁用态。
- ☐ 分层卡片三层 DOM；阴影层不命中；操作位固定预留。
- ☐ 交错序号封顶生效（长列表尾部节奏一致）。

## 六、fts 溯源

| 本文元素 | fts 锚点（基线 bba9b4e，1.72.0） |
|---|---|
| §二 双主题同键位/整本换轴 | fts 双字典机制（`Services/DesignThemeManager.cs:24-52`）的 CSS 投影；变量两套＝`platforms/web/tokens.css`（:root／[data-theme]，TOKEN-MAP §二.4） |
| §3.1 三档 | `DesignTokens.cs:56-58`（Fluent 官方值 83/167/250）；场景别名＝const 引 const（:61-70） |
| §3.2 缓动按语义 | `DesignTokens.cs:140-141`（"0,0,0,1"/"1,0,1,1"）；「to<from 数值判据」反例修复注记＝`Views/LiftAnimation.cs:46-48` |
| §3.3 意图事务 | fts 悬停意图事务（60ms 意图窗，`DesignTokens.cs:86` 登记为豁免行、design.md §六）；本文为计时器模式通用化 |
| §3.4 交错 | `DesignTokens.cs:70`（步长 40ms）、:129（封顶 8；TOKEN-MAP 注②：封顶为文档性 token） |
| §3.5 退化口径 | `DesignTokens.cs:63`（快档别名 reduced-fade）；skill motion 规则「快档纯淡入或立即定格、时序性延迟保留」 |
| §4.1 状态类型学 | `DesignTokens.cs:133`（按压缩放 0.96）、:209-210（禁用两档）；类型学叙述＝[docs/interaction-states.md](../interaction-states.md) |
| §4.2 三层卡片 | fts 卡片三层结构（`Resources/MainWindowStyles.xaml:1241-1274`）；操作列预留＝同文件 :17（30px） |
| CSS 变量命名与 shadow 折叠 | TOKEN-MAP-V1 §一（`.`→`-`＋`--` 前缀；缓动值为 cubic-bezier() 函数）、§二.4（shadow 折叠为 box-shadow 值，另存 `--color-shadow-card-opacity`） |
