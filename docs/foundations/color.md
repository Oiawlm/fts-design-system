# 基础·配色（Color）

> **一句话定位**：配色的原子规则——语义分工、双层结构（原始值↔语义角色）、双主题同键位整本替换与豁免登记机制；数值只是示例，权威快照在 `tokens/color.tokens.json`。**来源**：源项目 1.72.0 基线（commit `bba9b4e`）设计规范配色章＋设计常量与两本主题字典，经 `handoff/2026-11-11-bootstrap/TOKEN-MAP-V1.md` §3.1 映射。**日期**：2026-11-11。**行数预算**：≤300 行（现 85 行）。

## 一、普适规则

1. **语义分工三原则**（配色体系的第一法则）：
   - **中性面只走灰阶**：窗壳、导航轨、头部、卡片底等承载层全部使用无彩灰阶，表面层级靠明度由浅入深区分（窗壳→轨道→头部/卡片），不靠色相。
   - **强调色只承担指示语义**：选中、活动、焦点、置顶指示、拖放插入、链接、成功反馈——一律强调色；**禁止作装饰底色**。选中底/选中描边/活动层/落点层是强调色家族的派生浅变体，各自独立成键。
   - **危险色只承担破坏性语义**：清空、删除、退出、失败反馈；不越界用作警示以外的高亮。
2. **文案反馈色约定**：成功反馈＝强调色、失败反馈＝危险色、中性提示＝次级文字色——三个语义键复用，不为反馈场景新造颜色。
3. **双层结构**：`primitive` 层持原始色值（浅/深各一组），`semantic` 层是按用途命名的角色键，值指向 primitive；UI 一律只消费语义层。语义键**按用途命名、不按色相命名**（"selected-card-surface" 而非 "light-purple"），换色板时键位不动。
4. **双主题＝同键位整本替换**：每个语义键在浅/深两本字典各有一值，切换主题是字典级替换，布局与结构零变化；深色值独立推导（提亮强调色、压暗表面），不是浅色的简单反色。
5. **同值不同名不合并**：两个键当前值相同但语义身份不同（如强调色上的前景与卡片底色恰同白），保持独立键位——各自身份独立演进，合并即冻结耦合。
6. **交互状态色是独立键**：悬停表面、悬停描边、选中底、选中描边、活动层、落点层、滚动条滑块/悬停各一枚语义键；**禁止用临时透明度叠加拼凑交互态**（半透明黑罩 = 幽灵色，深浅主题下不可控）。
7. **动态引用纪律**：代码构建的 UI 一律活解析引用（动态资源语义），禁止查找后快照持有——主题切换后停旧色是典型缺陷。
8. **配色豁免清单机制**：主题不变量与材质层不入主题键，但必须**成文登记**：扫码面恒白（可扫性是物理约束而非调色板颜色）、系统材质色调（材质层非表面色）、独立工具预览底、结构性透明（命中层/占位）。豁免是登记制不是自由区——新增豁免必须入册，禁止静默新增字面色。

## 二、数值示例表（引 `tokens/color.tokens.json`）

> 全部数值以 `tokens/color.tokens.json`（声明路径，tokens 任务产出）为唯一快照——本表只给键位全表、分组与浅/深角色关系，不复制第二份色值。分组对齐 TOKEN-MAP §3.1 C2；浅/深原始值共 46 枚（`color.light.*`/`color.dark.*`），语义别名 23 枚。

| 语义键（token 路径） | 分组 | 用途 | 浅/深角色关系（示例值语义） |
|---|---|---|---|
| color.surface.window-shell | surface | 窗壳背景（材质回退面） | 最浅灰 / 近黑炭 |
| color.surface.tab-rail | surface | 导航轨背景 | 略深于窗壳 / 略亮于窗壳 |
| color.surface.card | surface | 卡片、输入框底 | 纯白 / 深灰面 |
| color.surface.header | surface | 头部表面、紧凑弹层 | 介于壳与卡之间 / 同律 |
| color.surface.status | surface | 状态浮层背景 | 近白 / 深灰面 |
| color.surface.dialog | surface | 对话框壳（不透明） | 微暖灰白 / 深灰面 |
| color.material.window-shell-tint | material | 系统材质壳的半透明色调 | 约 80% alpha 的壳色（浅/深各一枚） |
| color.border.default | border | 通用描边 | 浅灰线 / 深灰线 |
| color.border.hover | border | 悬停描边（密集控件只换边） | 加深一档 / 加亮一档 |
| color.text.primary | text | 主文字 | 近黑 / 纯白 |
| color.text.secondary | text | 次文字、图标默认前景、灰态环 | 中灰 / 亮灰（兼灰态语义复用，非新键） |
| color.text.on-accent | text | 强调色上的前景（对勾、徽标文字） | 恒白（两主题同值） |
| color.accent.default | accent | 强调色（选中/活动/指示/插入/链接/成功） | 紫罗兰 / 提亮紫（深色下加亮保对比） |
| color.danger.default | danger | 破坏性动作与失败反馈 | 正红 / 柔红（深色降饱和） |
| color.interaction.hover-surface | interaction | 悬停表面层 | 壳灰微沉 / 面灰微亮 |
| color.interaction.selected-card-surface | interaction | 选中卡片底 | 强调色极浅变体 / 强调色暗变体 |
| color.interaction.selected-card-border | interaction | 选中卡片描边 | 强调色中深变体 / 同族 |
| color.interaction.active-category | interaction | 活动导航层、按下态 | 强调色浅变体（比选中底更淡）/ 同族暗变体 |
| color.interaction.drop-target | interaction | 拖放落点层 | 与选中底近似的强调浅变体 / 同族 |
| color.scrollbar.thumb | scrollbar | 滚动条滑块 | 中灰 / 深灰 |
| color.scrollbar.thumb-hover | scrollbar | 滑块悬停 | 加深一档 / 加亮一档 |

两枚字典侧补充值（阴影对象与不透明度）属「海拔与材质」主题，见 [elevation-and-material.md](elevation-and-material.md) 数值示例表：`color.shadow.card` 与 `color.shadow.card-opacity`（浅 0.12 / 深 0.35，示例值）。对话框表面键在源项目两本主题字典侧持值、无常量侧定义——**双主题字典允许持少量无常量对应物的表面值，但必须两本同键位成对出现**。

## 三、新项目落地要点

1. **先画语义键位图再选色**：按上面 8 个分组（surface/material/border/text/accent/danger/interaction/scrollbar）建键，每键回答「它承担什么语义」；色板可以整体更换，键位结构保持稳定。
2. **primitive 持值、semantic 别名**：浅/深两组原始色 + 语义层别名；深色解析规则＝把别名路径中的浅色分支替换为深色分支（机器可校验），保证两本字典键集逐键一致。
3. **强调色家族一次派生成键**：选强调色后立即派生选中底/选中描边/活动层/落点层四枚浅变体键（深色再独立推导一轮），不留「将来再补」的口子。
4. **双主题同步交付**：任何新键必须同时落两本字典；交付前用浅/深双主题截图对照验收（同一布局、结构零变化）。
5. **活解析引用**：桌面端用动态资源引用、Web 端用 CSS 变量——代码里不出现第二份色值字面量。
6. **单源镜像锁定**（mirror-lock test）：断言「UI 层引用的每个语义色 == 数值源声明」，发现第二份字面量即测试红。
7. **豁免清单从第一天登记**：建项目时就把扫码面恒白、材质色调、结构性透明等登记成文；豁免项也要写明「为什么不是颜色语义」。
8. **次级文字色兼任灰态语义**：灰态环/禁用图标前景复用次级文字色，不为「灰」再造键。

## 四、反例信号

- 强调色出现在大面积表面或装饰背景（语义越界）。
- 中性面带色相；表面层级靠彩色区分而不是明度阶。
- 交互态用临时 alpha 罩拼凑（半透明黑/白覆盖），或散布第二份色值字面量（幽灵色）。
- 主题切换后部分界面停旧色（静态快照引用）。
- 两个语义不同的键因「值恰好相同」被合并成一枚（身份耦合）。
- 深色主题＝浅色值取反或统一降饱和（未独立推导对比度）。
- 新增字面色/新豁免项未登记（静默扩张）。
- 反馈场景（成功/失败/中性）另造新色，不复用强调/危险/次级文字三键。

## 五、fts 溯源

> 源项目＝悬浮中转站（fts），基线 commit `bba9b4e`（1.72.0）；行号基于该基线。数值映射与计数见 TOKEN-MAP-V1.md。

| 规则/事实 | fts 锚点 |
|---|---|
| 语义分工三原则（中性灰阶/Accent 指示语义/Danger 破坏语义）与 21 键色板 | `docs/design.md` §一（9-61 行）；`src/FloatingTransferStation.Core/Design/DesignTokens.cs:10-53` |
| 反馈色约定（成功=Accent、失败=Danger、中性=SecondaryText，2026-11-08 定） | `docs/design.md` §一（11 行） |
| 双主题同键位整本替换（DesignThemeManager，浅/深两本字典） | `docs/design.md:35`；`src/FloatingTransferStation/Resources/DesignTheme.Light.xaml`（22 键全文）/ `DesignTheme.Dark.xaml`（22 键全文，键集逐键一致） |
| 系统材质壳色调（80% alpha 半透明表面，材质层非表面色） | `DesignTokens.cs:30-32`（WindowShellTintHex/DarkHex，注释「不透明值用于材质不可用时的回退」） |
| 对话框表面＝字典侧值、无常量对应物（两本成对持值） | `DesignTheme.Light.xaml:8` / `DesignTheme.Dark.xaml:7`（DialogSurfaceBrush 注释） |
| 配色豁免清单（扫码面恒白岛式/材质色调/独立工具底/结构性透明）与动态引用纪律（契约 #28） | `docs/design.md` §一末（61 行）＋ §六豁免表（226 行） |
| 灰态环复用 SecondaryTextBrush（非新 token，契约 #56） | `docs/design.md` §五·D（180 行，双态环语法） |
| OnAccent 与 Card 浅色同白属巧合、不设别名 | `handoff/2026-11-11-bootstrap/TOKEN-MAP-V1.md` §四.1 |
| 阴影深浅参数差异化（浅 0.12/深 0.35） | `DesignTheme.Light.xaml:27-33` / `DesignTheme.Dark.xaml:26-32`（CardShadowEffect） |
