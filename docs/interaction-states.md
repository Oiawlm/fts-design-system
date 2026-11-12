# 交互状态（Interaction States）

> **一句话定位**：交互状态类型学——H/P/D/F 四态×控件类型全景矩阵、hover 双轨与 pressed 三范式选型、禁用两档与「不可用≠禁用」、focus 矩阵、状态视觉的分层叠加图层结构；数值只是示例，权威快照在 `tokens/motion.tokens.json`（时长/缩放/禁用档）与 `tokens/color.tokens.json`（状态色）。**来源**：源项目 1.72.0 基线（commit `bba9b4e`）设计规范交互状态章＋样式族与锁定测试源码，经 TOKEN-MAP-V1 §3.1/§3.3 映射（对账见 [reference/extractions/2026-11-fts-v1.72.0.md](../reference/extractions/2026-11-fts-v1.72.0.md)）。**日期**：2026-11-12。**行数预算**：≤350 行（现 108 行）。

动效侧规则（时长档位/缓动/编排/减动效）见 [motion.md](motion.md)；本篇是总则，范式篇（[card.md](patterns/card.md)、[tile.md](patterns/tile.md)、[chip-rail.md](patterns/chip-rail.md) 等）是其落位。

## 一、类型学（控件类型全景）

新控件必须先在表中找归属（复用既有类型的整行范式），无归属才提新类型并登记本表。**hover 双轨/pressed 范式/禁用档的选型规则见 §二/§三。**

| 控件类型 | Hover | Pressed | Disabled |
|---|---|---|---|
| 头部图标钮（含危险钮） | 层淡入（悬停表面色＋悬停描边色） | 层切活动层色 83ms | 0.4 |
| 通用文字钮／折叠开关钮 | 瞬切换底＋换边 | 瞬切活动层色 | 0.4 |
| 卡片操作钮网格（行尾操作格） | 层淡入＋图标转强调色 | 层切活动层色 | 不禁用（矩阵隐藏＋守卫） |
| 勾选钮（卡片/瓦片/多选选择器） | 环换强调色 167ms | —（即时选中反馈） | 无禁用 |
| chip 过滤轨钮（toggle） | 瞬切换底＋换边 | 瞬切活动层色 | 0.4 |
| 设置开关（自绘） | 仅描边 | — | 0.4 |
| 设置导航项／分段控件 | 瞬切悬停表面色 | — | 无 |
| 下拉框（本体/列表项） | 本体仅换边；列表项换底 | —（开弹层即反馈） | 代码级禁用 |
| 菜单项 | 高亮换悬停表面色 | 顶层换活动层色 | 0.4 |
| 自绘 chip／全量伪 chip／导航轨标签 | 层淡入＋边框瞬切 | — | 无 |
| 快捷操作瓦片（action tile） | −2px 位移 167ms（`dimension.offset.tile-hover-lift`） | 0.96 缩放 83ms（`motion.scale.tile-press`） | 无禁用 |
| 复制行（伪按钮） | 悬停表面色瞬切 | — | — |
| 贴边把手（窗口级命中面） | 提亮＋强调色指示 167ms；60ms 意图事务提交展开（[motion.md](motion.md) §三） | —（命中面非钮） | 无 |
| 容器变换弹层缩略钮 | 仅换边 | 不透明度 0.85（孤例） | 无 |
| 文本输入框 | — | — | 0.4＋强调色聚焦描边 |
| 滚动条滑块 | 加宽 4→6＋换色 167ms | — | — |
| 设置卡（整卡灰化） | —（卡非钮） | — | 0.6（`motion.opacity.card-disabled`） |

数值均为示例值：0.4＝`motion.opacity.control-disabled`；167/83ms＝`motion.duration.hover-feedback`／`press-feedback`；悬停表面色/悬停描边色/活动层色/强调色等状态色键见 [foundations/color.md](foundations/color.md) 语义色表。

**命中区规格**（按类型登记，不 token 化——几何规格属结构值非设计 token）：图标钮 30×30（图标 14.5/16 两制）；文字钮高 30（对话框覆写 32、退出钮 34）；下拉 32；导航项 34；分段 26。

## 二、双轨三范式（hover 与 pressed 的选型）

### hover 双轨

「双轨」＝**动画轨 vs 瞬切轨**：悬停反馈要么由独立图层交叉淡入承载（动画轨），要么由属性直换承载（瞬切轨）；不存在第三种承载机制。瞬切轨内按「改什么」分三支系：

| 支系 | 对象 | 表现 | 模板判别 |
|---|---|---|---|
| ①层淡入（动画轨） | 复合图标元素（头部图标钮/卡片操作钮/导航轨标签/chip） | 悬停层交叉淡入 167ms（`motion.duration.hover-feedback`） | 模板无悬停属性触发器，悬停由动效开关驱动 |
| ②属性瞬切 | 单表面轻控件（文字钮/chip/导航/分段/菜单项/瓦片名带） | 触发器直换背景/描边，零时长 | 模板有悬停 Setter 直换底/边 |
| ③仅描边 | 密集内容控件（下拉框/弹层缩略钮/设置开关） | 只换悬停描边色（`color.border.hover`），不换底不位移 | 触发器只动描边 |

判别可由结构测试锁定（源项目以锁定测试断言头部钮模板零瞬切触发器＋含悬停层＝①支系、文字钮换底换边＝②支系、开关仅描边＝③支系，见溯源）。层淡入的图层结构见 §五。

### pressed 三范式

按压反馈只有三种范式，按控件族落位：

| 范式 | 表现 | 对象 |
|---|---|---|
| 换色 | 瞬切/层切活动层色（`color.interaction.active-category`），83ms（`motion.duration.press-feedback`） | 标准钮族（文字钮/chip/头部钮/菜单顶层） |
| 缩放 | 0.96（`motion.scale.tile-press`）83ms | 瓦片族（快捷操作瓦片） |
| 透明度 | 0.85 | 容器变换弹层缩略钮（孤例，白底码面配套） |

**无按压态类**：轻量选择类（勾选钮/导航/分段/开关/下拉/chip）无按压态——选中/弹层本身即反馈，再叠按压是冗余刺激。判别原则：按压态只加给「按下即执行」的动作族；「按下即选择」的族用选中态表达。

## 三、禁用档（两档灰化与不可用性表达）

| 档 | token 路径 | 示例值 | 对象 |
|---|---|---|---|
| 控件族 | `motion.opacity.control-disabled` | 0.4 | 按钮族/输入框/菜单项等一切控件级禁用 |
| 整卡灰化 | `motion.opacity.card-disabled` | 0.6 | 设置卡等整表面禁用 |

- 消费者一律 token 化引用（桌面端常量直引/资源键、Web 端 CSS 变量），禁止字面量；发现第三档（0.35/0.45/0.5 散档并存）就是漂移，归一两档。
- **叠加规则**：钮（0.4）叠在整卡灰化（0.6）内合成 ≈0.24，已裁定可接受——不为此引入第三档或豁免链。
- **不可用≠禁用态**：矩阵隐藏＋入口守卫优先，属性置灰为辅。理由：置灰元素不可命中，点击穿透成误触——正确做法是入口守卫（点击时校验并给反馈）＋视觉徽章/灰态表达，元素保持可命中。卡片操作钮「不禁用」一行即此原则落位：不可用时不灰化按钮，而是从操作矩阵隐藏或由守卫拦截（可见性矩阵见 [card.md](patterns/card.md)）。

## 四、Focus 矩阵

全仓默认：**非文本控件不参与 Tab 焦点＋无焦点视觉**（容器一律不画焦点框）。可见键盘焦点全仓仅两处：

| 位置 | 表达 | 理由 |
|---|---|---|
| 文本输入框 | 强调色描边 | 输入位置是功能信息，必须可见 |
| 瓦片勾选钮 | 键盘聚焦显隐（悬停∨选中∨键盘聚焦三态或） | 键盘多选路径的存在性指示 |

判别原则：焦点视觉只加给「键盘操作真实到达」的元素；纯鼠标控件画焦点框是噪音。新增键盘可达路径时先扩本矩阵并给出真实键盘驱动验证，不给纯装饰焦点框。

## 五、分层叠加（状态视觉的图层结构）

**总则：状态表达用独立图层交叉淡入，不换色、不重排。**同一控件的状态视觉拆为各司其职的图层——填充层（悬停表面底）、环层（描边/选中环）、命中层（透明命中面）——状态切换＝目标层不透明度 0↔1 交叉淡入（167ms 档），基线层几何与内容零变化。

1. **悬停层结构**：模板内独立图层承载悬停表面，与内容、描边分离；①支系全部经此结构。变体：滚动条滑块「基宽 4／悬停层宽 6」双层交叉淡入表现展宽——几何与颜色解耦于单一属性（见 [scrollbar.md](patterns/scrollbar.md)）。
2. **阴影隔离在文字子树之外**：带模糊效果的元素会把整个子树渲染进中间位图并强制关闭子像素渲染（小字发糊主因）。分层状态卡片因此为三层结构：根容器（外距与悬停上浮，无效果）＋阴影层（同形状不透明底＋共享冻结阴影效果，不承载内容、不参与命中）＋内容面（不透明底/描边/焦点态，**不得携带效果**）——结构分解见 [card.md](patterns/card.md)。阴影效果共享冻结单实例（浅 0.12/深 0.35，示例值：`color.shadow.card-opacity`），不逐元素实例化——虚拟化列表性能前提。
3. **位移不参与布局**：悬停上浮用渲染位移（卡片 −1px：`dimension.offset.card-hover-lift`；瓦片 −2px：`dimension.offset.tile-hover-lift`），不参与布局、不影响命中测试；缓动按语义选（抬升＝减速/回落＝加速，[motion.md](motion.md) §二）。
4. **操作格固定预留**：卡片操作钮网格列/行绝对尺寸，按钮隐藏时格子留空不漂移——状态变化不引起任何重排（§一命中区规格同一原则）。

## 附：fts 溯源

> 源项目＝悬浮中转站（fts），基线 commit `bba9b4e`（1.72.0）；行号基于该基线实测（2026-11-12 逐条抽查通过）。数值映射见 TOKEN-MAP-V1 §3.1/§3.3，对账 [reference/extractions/2026-11-fts-v1.72.0.md](../reference/extractions/2026-11-fts-v1.72.0.md)。

| 规则/事实 | fts 锚点 |
|---|---|
| 类型学矩阵＋双轨三范式＋禁用两档＋Focus 成文 | `docs/design.md` §三（93-118；`:95` 总述行含契约 #19/#57、W6 治理） |
| hover 双轨判别＋pressed 范式结构锁定测试 | `tests/FloatingTransferStation.Tests/MainWindowInteractionTests.ButtonStates.cs:105`（`ButtonStates_HoverAndPressedFollowSharedParadigms`） |
| 禁用两档归一锁定测试 | 同文件 `:45`（`ButtonStates_DisabledOpacityConsolidatesToControlAndCardTiers`） |
| 禁用两档常量 0.4/0.6 | `src/FloatingTransferStation.Core/Design/DesignTokens.cs:209-210`；token 化消费例 `src/FloatingTransferStation/Resources/MainWindowStyles.xaml:152` |
| 悬停层独立图层（头部钮/导航轨标签/滚动条滑块） | `MainWindowStyles.xaml:128`、`:1382`、`:2025`（ThumbHoverLayer 基宽 4/悬停层 6） |
| 卡片三层结构三样式与模板消费 | `MainWindowStyles.xaml:1243-1266`（三样式）、`:2196-2202`（模板三层） |
| 弹层缩略钮：仅描边 hover＋0.85 按压孤例 | `src/FloatingTransferStation/Views/SettingsWindow.xaml:270-275` |
| 瓦片勾选钮键盘聚焦显隐（三态或；源注释引 #13 族） | `MainWindowStyles.xaml:1799` |
| 悬停上浮渲染位移数值同源 | `src/FloatingTransferStation/Views/LiftAnimation.cs:17` |
| 非文本控件焦点视觉清空（W6 治理散点） | `MainWindowStyles.xaml:218`（FocusVisualStyle 显式置 Null）等 |
| 行为计时器豁免（意图窗 60ms 等） | `docs/design.md:228` |
