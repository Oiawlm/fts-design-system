# 基础·形状与间距（Shape & Spacing）

> **一句话定位**：形状与间距的原子规则——圆角两档阶梯与判定规则、派生三族规则、阶梯外登记制、间距节奏的收/不收判据与豁免登记；数值只是示例，权威快照在 `tokens/dimension.tokens.json`。**来源**：源项目 1.72.0 基线（commit `bba9b4e`）设计规范圆角章与排版布局章＋设计常量，经 TOKEN-MAP-V1（对账 [2026-11-fts-v1.72.0.md](../../reference/extractions/2026-11-fts-v1.72.0.md)） §3.2 映射。**日期**：2026-11-11。**行数预算**：≤300 行（现 101 行）。交叉引用：[color.md](color.md) 的豁免登记制同构。

## 一、普适规则

1. **圆角两档阶梯**：只有「控件档」与「表面档」两档——**判定规则按元素类型二分**：输入/动作类控件（输入框、按钮、下拉、行内编辑器、菜单行、类型 chip）＝控件档（示例值：4px，`dimension.radius.control`）；承载内容的表面（卡片、瓦片、弹窗壳、主壳、标签容器、放大层）＝表面档（示例值：8px，`dimension.radius.surface`）。判定写「这个元素是**手**（动作）还是**托盘**（承载）」，不按视觉大小调。
2. **档位封闭，锚定不加档**：新场景圆角一律落入两档之一；「这个场景感觉 6px 更好看」不是加档理由——先问判定归类，再问是否有登记制例外。
3. **阶梯外登记制**：识别元素（选择环、置顶钮、头部钮/徽章等**身份性小件**）保留各自原值、**逐个登记入册、不入阶梯**——登记值同样以资源引用消费（样式不散布字面量），只是不参与两档判定。登记册成文即约束：新增识别元素必须登记，禁止静默出现第三档。
4. **同值不同名不合并**：表面档下「通用表面/卡片/窗壳」三键值相同但身份不同——各自独立 token，漂移治理时各自可独立演进（未来卡改 10px 不连带窗壳）。
5. **派生三族规则（成文不入档）**——派生值不设 token、不进登记册，规则本身成文：
   - **胶囊/圆形 ＝ 高的一半**：开关轨道与滑钮、圆形角标；
   - **线状件 ＝ 宽的一半**：滑块悬停层、导航指示条、停靠把手竖条（示例值：宽 3px 的竖条圆角 1.5）、分隔线（宽 1px 圆角 0.5）；
   - **内层 ＝ 外层 − 描边**：嵌套表面的填充层圆角（示例值：外 8 − 描边 1 ＝ 7、外 8 − 描边 2 ＝ 6）。
   派生规则的存在使「胶囊 10/滑钮 7、指示条 1.5」这类零散值无需逐个登记——它们是规则的输出，不是档位的例外。
6. **小件家族同值点名登记**：chip 容器族等一组同语义小件共用一个圆角（示例值：6px 容器＋5px 激活层/落点层的「6×5」配对）——作为家族一次登记并注明语义族边界（不复用他族数值 token，即便值相同）。
7. **间距节奏——收/不收判据**：
   - **收（token 化）**：结构性常量——表面内缩、纵向沟槽、表面内边距、阅读块距这类「同一数值在多个结构场景重复出现且语义同质」的间距；
   - **不收**：语义异质的常规 margin（元素横向间距、标题缩进）——同一数字出现在不同语义位置时强行 token 化会造成膨胀负收益，以**约定成文**（写进设计规范的节奏表）代替；
   - **豁免登记制**：个别结构节奏值（如分区边界上距）随结构体整体照抄并注释登记，不拆散成 token。
8. **结构性尺寸不是设计 token**：窗宽、轨道宽、面板宽、最小窗高等属结构层——**结构不为内容让步**（不为长内容加宽结构、不为内容回流改结构）；结构尺寸的权威在结构层自己的常量体系。
9. **位移与间距分立**：入场位移、出场位移、悬停抬升（示例值：`dimension.offset.content-entrance` 6px、`dimension.offset.collapse-exit` 24px、`dimension.offset.card-hover-lift` −1px）是**动效位移**不是布局间距——渲染位移（不参与布局、不影响命中）承载悬停抬升；不同组件族的抬升幅度各自成键（卡片 −1 与瓦片 −2 对仗），不共用。
10. **文字避让预留是派生公式**：正文侧为角标操作列预留的排他内缩＝「列数×列宽＋间隙」推导（示例值：2×30＋4＝64px，`dimension.spacing.card-text-reserved-right`），唯一来源是派生资源——**不得在别处写死第二个数值**；静态值（不随悬停动态变化），按钮显隐不得牵动正文回流。

## 二、数值示例表（引 `tokens/dimension.tokens.json`）

> 全部数值以 `tokens/dimension.tokens.json`（声明路径，tokens 任务产出）为唯一快照；下表数值均为示例值（源项目基线口径）。

**圆角（8 键）**

| 键 | 示例值 | 归属 | token 路径 |
|---|---|---|---|
| 控件档 | 4px | 阶梯·输入/动作类 | dimension.radius.control |
| 表面档 | 8px | 阶梯·内容表面 | dimension.radius.surface |
| 卡片 | 8px | 阶梯·独立身份键 | dimension.radius.card |
| 窗壳 | 8px | 阶梯·独立身份键（系统裁剪与内容自裁剪同值） | dimension.radius.shell |
| 头部操作钮 | 7px | 登记册·识别元素（含同值小件表面族） | dimension.radius.header-action |
| 选中计数徽章 | 7px | 登记册·别名（＝头部操作钮） | dimension.radius.selected-count-badge |
| 置顶钮 | 6px | 登记册·识别元素 | dimension.radius.pin-button |
| 选择环 | 5px | 登记册·识别元素（勾选钮/类型 chip 共用） | dimension.radius.selection-ring |

**派生规则输出（不入档，规则见 §一.5）**：胶囊＝高/2（开关轨道/滑钮、圆角标）；线状＝宽/2（滑块层/导航条/停靠把手竖条 1.5/分隔线 0.5）；内层＝外−描边（填充层 7、放置高亮内层 6）；chip 小件家族 6×5；头部表面转角 11 与滑块 2 为样式内既有字面量按规则登记。

**间距与位移**

| 键 | 示例值 | 收/不收 | token 路径 |
|---|---|---|---|
| 表面水平内缩 | 12px | 收（结构性） | dimension.spacing.card-inset |
| 表面纵向沟槽 | 4px | 收（结构性） | dimension.spacing.card-gutter |
| 表面内边距 | 12px | 收（结构性） | dimension.spacing.card-padding |
| 瓦片视口上下内衬 | 8px | 收（结构性，吸收动画溢出） | dimension.spacing.launcher-viewport-inset |
| 阅读块距 | 6px | 收（结构性） | dimension.spacing.reading-block-gap |
| 代码块内边距 | 8px | 收（结构性） | dimension.spacing.reading-code-padding |
| 操作列宽 | 30px | 收（结构列） | dimension.size.card-operation-column |
| 正文排他内缩 | 64px | 收（派生公式 2×30＋4） | dimension.spacing.card-text-reserved-right |
| 引用竖条宽 | 3px | 收（结构小件） | dimension.size.reading-quote-bar |
| 入场位移 | 6px | 收（动效位移） | dimension.offset.content-entrance |
| 出场位移 | 24px | 收（动效位移） | dimension.offset.collapse-exit |
| 卡片悬停抬升 | −1px | 收（动效位移） | dimension.offset.card-hover-lift |
| 瓦片悬停抬升 | −2px | 收（动效位移，与卡片对仗） | dimension.offset.tile-hover-lift |
| 瓦片入场位移 | 8px | 收（动效位移） | dimension.offset.tile-entrance |
| 元素横向间距 8／标题缩进 24 | — | **不收**（语义异质，约定成文） | —（设计规范节奏表） |
| 瓦片几何 84×100、沟槽 8、节距 92、列数 3–6 | — | 收（组件几何族） | dimension.tile.* |

## 三、新项目落地要点

1. **两档起步**：建 `radius.control`/`radius.surface` 两键＋判定口诀（动作＝小档、承载＝大档）；评审任何新控件先问归类，再谈例外。
2. **登记册模板**：识别元素入册四要素——名称、值、语义族边界、消费方式（资源引用）；登记册与 token 文件同生命周期维护。
3. **派生规则写进规范**：胶囊/线状/内层三族规则成文，样式里出现 `高/2` 结果值时注释指向规则；不为派生值开 token。
4. **间距先判「结构性 vs 语义性」**：只有结构性且语义同质才 token 化；常规 margin 写进节奏表（约定成文），出现第三种情况按判据重新归类而非加键。
5. **预留在前、避让公式化**：内容表面有角标/操作列时，预留量以公式派生（列×宽＋间隙）并做成唯一来源资源；静态预留（不随显隐动态变化）。
6. **结构层自立**：窗口/面板/轨道尺寸放结构常量体系，与设计 token 分仓；结构不为内容让步写进评审基准。
7. **镜像锁定**：圆角/间距 token 与界面层资源镜像互锁（断言每个资源值 == 数值源），发现散布字面量即红。

## 四、反例信号

- 第三档圆角出现（6px、10px 直接写进新控件）；同场景「感觉」驱动的圆角。
- 识别元素未登记就带着新值入仓；登记值在样式里散布字面量而不走资源引用。
- 派生值被立成 token（胶囊圆角、指示条圆角各一枚 token）。
- 值相同就把不同身份的键合并（表面/卡片/壳合一）。
- 全部 margin 一律 token 化（键位爆炸）；或结构性内缩反而是散布字面量。
- 结构尺寸被内容牵动（为长文本加宽轨道、为回流改窗宽）。
- 悬停抬升用布局位移实现（挤动邻居）或共用一个「抬升」键不分组件族。
- 避让预留出现第二份数值（某处写死 64 的邻值）；按钮显隐牵动正文回流。
- 新增派生值（非三族规则的「随手圆角」）未成文。

## 五、fts 溯源

> 源项目＝悬浮中转站（fts），基线 commit `bba9b4e`（1.72.0）；行号基于该基线。数值映射见 TOKEN-MAP-V1.md。

| 规则/事实 | fts 锚点 |
|---|---|
| 两档阶梯（控件 4/表面 8）＋判定规则（2026-11-08 成文，契约 #34） | `docs/design.md` §四（119-137 行）；`src/FloatingTransferStation.Core/Design/DesignTokens.cs:181-195`（圆角常量段含判定注释） |
| 阶梯外登记值（头部钮/徽章 7、置顶钮 6、选择环 5）与 7 值同族表面并入资源消费 | `docs/design.md` §四（133 行）；`src/FloatingTransferStation/Resources/MainWindowStyles.xaml:42-57`（Shell/Surface/Control/Card/HeaderAction/Pin/Badge/SelectionRing 八资源） |
| 派生三族规则（胶囊/线状/内层−描边）＋chip 6×5 点名登记＋把手竖条 1.5 | `docs/design.md` §四（137 行，派生规则例外段） |
| 间距节奏收/不收判据（元素横向 8/标题缩进 24 不 token 化；结构性尺寸非 token） | `docs/design.md` §五（145 行） |
| 卡片族间距三 token 与镜像 Thickness 资源（12/4/12；边界上距 10 为登记字面量） | `DesignTokens.cs:197-205`；`MainWindowStyles.xaml:62-64`（CardRootMargin/CardRootBoundaryMargin/CardPadding 及注释） |
| 同值不合并（surface/card/shell 三键独立身份） | TOKEN-MAP-V1.md §四.4 |
| 位移族（入场 6/出场 24/卡片 −1/瓦片 −2 对仗） | `DesignTokens.cs:198-205`；`docs/design.md` §五（151-157 行表格） |
| 文字避让排他内缩 64＝2×30＋4 派生资源唯一来源（1.33.0 回归两列网格） | `MainWindowStyles.xaml:25`（CardTextReservedRightInset 及推导注释）；`docs/design.md` §五·D（178 行） |
| 瓦片几何族（84×100/8/92/3–6，拉伸填充单一几何源） | `DesignTokens.cs:212-230`；`docs/design.md` §五（147 行布局范式索引） |
