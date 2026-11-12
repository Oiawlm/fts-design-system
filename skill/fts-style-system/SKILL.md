---
name: fts-style-system
description: 悬浮中转站（fts）UI/动效/前端风格系统：把这套风格复用到任何新项目时使用——新界面、新窗口、新设置页、新对话框、统一风格、动效与微交互、空状态、卡片/瓦片/滚动条/网格布局、子分组 chip 轨与过滤、停靠/贴边 peek 与把手、二维码等容器变换（container transform）、实验开关与偏好迁移、悬停意图事务、hover/pressed/禁用交互状态体系、暗色主题，或用户说「按 fts 风格」「保持统一的风格」「跟悬浮中转站一样」时必读。包含：风格哲学六约束、语义 token 与档位表（圆角/时长/间距/字号/描边/阴影/禁用两档）、布局范式六式、动效三档与缓动按语义、交互状态类型学、反例库 24 条（现象→根因→正解）、WPF 落地映射与陷阱库、七个特性级 worked example、新项目八步套用工作流。源仓：fts-design-system（github.com/Oiawlm/fts-design-system，本 skill 随仓版本化于 skill/fts-style-system/，由仓内 scripts/sync-skill.ps1 一键部署到 ZCode / Claude Code / Codex / Cursor 等任意 AI 编码代理）。新项目默认采用本体系，无需逐次点名。不适用：非 UI 的纯逻辑/数据/持久化修复；项目已有自己的设计体系且未要求对齐 fts 风格；与界面无关的工程任务。
license: MIT
---

> **定位**：把「悬浮中转站」的设计体系（哲学/token/范式/动效/状态）提炼为可迁移风格系统，任何新项目不重新推导即可复现这套风格。本文件是**路由层**——哲学摘要＋八步工作流＋验收清单；通用规则细节由 references 七件承载（自包含提炼，离线可用），按「参考文件地图」按需精读。
> **权威分工**：本 Skill＝提炼视图；数值与规则的权威源＝**fts-design-system 仓**（`github.com/Oiawlm/fts-design-system`）——`tokens/`（W3C DTCG 数值快照，152 token）、`docs/`（人类可读权威叙述）、`platforms/`（WPF XAML 与 Web CSS 镜像）、`reference/extractions/`（提取对账）。同名规则表述以 docs 为准；再提取与再部署走仓内 `docs/extraction-protocol.md` 与 `scripts/sync-skill.ps1`。本文全部数值均为**示例值**。
> **来源**：仓内源 `skill/fts-style-system/`；内容溯源自 fts 1.72.0（commit `bba9b4e`，2026-11-10），fts 专属锚点（file:line/契约号）集中收录在 [references/fts-provenance.md](references/fts-provenance.md)。
> **日期与行数预算**：2026-11-12 重建（W3c）；2026-11-12 E1 跨 Agent 部署化；本文件 ≤300 行（现 113 行）；references 七件每件 ≤400 行。

## 适用边界

- **适用**：新项目从零搭建 UI 复现这套风格；给既有项目补统一风格体系；评审一次界面改动是否偏离本风格；设计具体特性（卡片列表、瓦片网格、chip 过滤轨、贴边停靠 peek、容器变换弹层、实验开关体系、设置窗 IA、阅读视图、后台 AI 管线）时借 worked example。
- **不适用**：非 UI 的纯逻辑/数据/持久化修复；项目已有自己的设计体系且未要求对齐；与界面无关的工程任务。
- 本 Skill 不承载 fts 的产品行为契约（那是 fts 仓 `docs/design-contracts.md` 的事），只提指针；不复制 fts `design.md` 原文（防副本漂移）。

## 核心设计约束（哲学六条，每条详见标注）

1. **单一数值源＋单源镜像锁定**。一切设计数值（颜色/圆角/时长/间距/字号/不透明度/固定文案）只在一处声明，UI 层只引用不复制；自动化测试锁定「界面层镜像 == 数值源」。发现第二份字面量（幽灵 token）即删。｜详见 references/tokens-and-ladders.md
2. **恒定几何**。几何不因无关因素跳变：滚动条出现/消失、按钮隐藏/显示不移动无关内容；窗口状态迁移一次矩形变更到位，连续迁移只走唯一受控动画通道（例外契约化登记，不散布）。｜详见 references/motion.md §例外通道
3. **档位制而非连续值**。圆角两档（判定按元素是「手」还是「托盘」）、时长三档、字号 7+3 档、字重单档、禁用不透明度两档；新场景**锚定**既有档不加新档，例外逐一登记。｜详见 references/tokens-and-ladders.md
4. **缓动按语义＋减动效退化**。进入视觉态减速、离开加速——按语义选不按数值方向（位移动画禁数值判据）；曲线经单点实例消费；减弱动效统一退化为纯淡入或立即定格，时序性信息保留。｜详见 references/motion.md
5. **分层叠加状态；hover 双轨；pressed 三范式；阴影隔离**。状态视觉用独立图层交叉淡入，不换色、不重排；悬停/按压/禁用/焦点按控件类型学落位；阴影等特效隔离在不承载文字的图层（三层结构＋共享冻结单实例）。｜详见 references/motion.md §交互状态
6. **克制与真实可达；意图事务**。动效可中断、不阻断命中测试、永不作信息唯一载体；不可用不用禁用态表达（入口守卫＋元素保持可命中）；悬停只预览、激活属点击——确需悬停触发激活级动作时用**意图事务**（布防→到期重验指针仍在→才提交）防扫边误触；关键路径必须真实输入验证。｜详见 references/motion.md §编排

## 新项目套用工作流（八步）

| 步 | 动作 | 依据（reference ｜ 权威 docs） |
|---|---|---|
| 1 | 读哲学六条＋反例库，确认目标项目范围与最小采用面 | 本文件＋references/anti-patterns.md ｜ docs/philosophy.md、docs/adaptation/adoption-workflow.md §最小采用集 |
| 2 | 建 token 层：语义键分组照搬（按用途命名），数值按项目品牌重新推导；双主题同键位 | references/tokens-and-ladders.md ｜ docs/foundations/ 四篇＋tokens/*.tokens.json |
| 3 | 搭单源镜像锁定测试：镜像通道逐键断言＋直引通道来源断言＋键数计数 | references/wpf-implementation.md §四 ｜ docs/adaptation/wpf.md §三（Web 栈：docs/adaptation/web.md） |
| 4 | 组件范式选型：对照六式逐项登记「入选/排除＋变体」；特性级需求读 worked example | references/layout-paradigms.md、references/features-worked-examples.md ｜ docs/patterns/ 十二篇 |
| 5 | 动效档位映射：场景→档位/曲线/编排/退化行为四列成表；交互状态按类型学归位 | references/motion.md ｜ docs/motion.md、docs/interaction-states.md |
| 6 | 反例库自查：24 条逐条对照设计方案，命中即改并记整改 | references/anti-patterns.md ｜ docs/anti-patterns.md |
| 7 | 双主题截图自检：浅/深全量截图逐区域对照（结构零变化、只有色板换） | 本文件 assets 对照表 ｜ 仓内 assets/ 台账 |
| 8 | 收尾验收：逐项过下面的质量验收清单；新增键位与例外登记进项目文档 | 本文件 ｜ docs/adaptation/adoption-workflow.md §八 |

只想投入两成成本先拿大部分风格收益时，做三件（最小采用集）：最小语义色板＋双主题同键位；动效只用三档两缓动＋减动效退化；分层状态卡片＋阴影隔离。

## 反模式 Top 10（全 24 条见 references/anti-patterns.md）

1. 第二个数值源（幽灵 token）→ 删，唯一权威＋镜像锁定测试。
2. Effect 进文字子树（正文发糊）→ 阴影隔离到不含文字的独立层。
3. 纯 Opacity 隐藏（占位漂移/残留命中）→ 布局塌缩＋统一显隐管理。
4. 为新场景新增时长档位 → 锚定既有三档（独立时长组是契约化例外，不是后门）。
5. 滚动条占布局宽（独立列/常驻留槽/宽度补偿特判）→ overlay 单一机制。
6. 弹窗假圆角三件套（透明背景＋margin 挤圆角＋手工阴影）→ 不透明表面单壳，圆角/阴影唯一来源系统。
7. 代码构建 UI 时快照画刷（主题切换后停旧色）→ 动态资源引用。
8. 模式化交互（全局「编辑模式」开关）→ 常态分区手势＋多选。
9. 缓动曲线硬编码散布 / 位移动画按数值方向选曲线 → 缓动单点实例＋按语义选曲线。
10. 禁用透明度散档（0.35/0.45/0.5 并存）→ 归一两档（控件 0.4/整卡 0.6）；同一组固定文案两处逐字双写 → 收敛唯一来源。

## 质量验收清单

- ☐ 所有数值有唯一声明点（含固定文案），UI 层零第二字面量（镜像锁定测试覆盖）。
- ☐ 圆角两档按「输入/动作＝4、内容表面＝8」判定；识别元素例外登记在册；派生三族规则成文。
- ☐ 时长只三档＋登记例外；场景锚定不加档；独立时长组仅契约化特例（示例：容器变换一组）。
- ☐ 两条缓动按**语义**各就各位；位移动画无数值判据；缓动单点实例；减动效有统一退化口径。
- ☐ 字号 7+3 档、H4–H6＝正文＋权重区分；字重单档；禁用不透明度两档；像素对齐按字号逐个点名。
- ☐ hover 双轨三支系/pressed 三范式/Focus 矩阵按类型学落位，无第四种 hover。
- ☐ 阴影与一切 Effect 不在文字子树内；共享冻结单实例；卡片三层结构。
- ☐ 显隐切换走布局塌缩＋统一显隐管理，不用纯 Opacity。
- ☐ 滚动条 overlay、不占布局宽，内容几何不随其出现/消失漂移。
- ☐ 弹窗单壳：不透明表面＋系统级圆角阴影唯一来源，无手工 Effect；系统不给圆角时直角回退。
- ☐ 状态视觉用分层交叉淡入，不换色不重排；按钮格子固定预留（隐藏留空）。
- ☐ 空状态：图标＋标题＋副文案三件套、信息层命中穿透、无 CTA 默认、文案矩阵单点派生。
- ☐ 双主题同键位整本替换；代码构建的 UI 行动态资源引用（主题活切换跟随）。
- ☐ 关键指针路径经真实输入验证（不只合成事件）；悬停触发的激活级动作用意图事务。
- ☐ 反例库 24 条过一遍，无已知反例。
- ☐ 浅/深双主题截图对照 assets 通过（看结构不看像素）。

## 参考文件地图（按需精读，不必先读）

| 文件 | 何时读 | 权威 docs 映射 |
|---|---|---|
| [references/tokens-and-ladders.md](references/tokens-and-ladders.md) | 建 token 层、对数值、排新键位时 | docs/foundations/（color/typography/shape-and-spacing/elevation-and-material）＋tokens/ |
| [references/layout-paradigms.md](references/layout-paradigms.md) | 搭卡片/瓦片/网格/滚动条/对话框/空状态时 | docs/patterns/ 表面六篇 |
| [references/motion.md](references/motion.md) | 做任何动效、微交互或交互状态时 | docs/motion.md＋docs/interaction-states.md |
| [references/anti-patterns.md](references/anti-patterns.md) | 设计评审、收尾验收时 | docs/anti-patterns.md |
| [references/wpf-implementation.md](references/wpf-implementation.md) | WPF/WinUI 技术栈落地时 | docs/adaptation/wpf.md＋platforms/wpf/ |
| [references/features-worked-examples.md](references/features-worked-examples.md) | 实现七类特性级功能（chip 轨/贴边 peek/容器变换/实验开关/阅读视图/设置 IA/AI 命名管线）时 | docs/patterns/ 动态六篇 |
| [references/fts-provenance.md](references/fts-provenance.md) | 需回 fts 源项目核对锚点（file:line/契约号）时 | reference/extractions/2026-11-fts-v1.72.0.md |

## assets 视觉对照（示例值截图，看结构不看像素）

PNG 图解（结构标注）：

| 图 | 看什么 |
|---|---|
| panel-anatomy.png | 展开态面板三行骨架：头部操作组、卡片、状态条（标注含两处旧术语，结构有效） |
| quicklaunch-anatomy.png | 瓦片结构：工具行、名称带、勾选钮、拖动排序标注 |
| card-gesture-zones.png | 卡片左右两半手势分区（左编辑与送达、右复制；边缘环带归左半） |
| card-delete-buttons.png | 删除钮双语义与操作列布局（左列选择/右列删除/下行置顶） |
| card-ai-organize-light.png / card-ai-organize-dark.png | 悬停操作列揭示、长文截断；深色版看描边与阴影分层 |
| pinned-divider-accent-bar.png | 置顶分区与强调色分隔线、右轨激活态 |
| theme-light-dark.png | 双主题同键位：同一布局两套色板，结构零变化 |
| quicklaunch-surface-light.png / quicklaunch-surface-dark.png | 瓦片网格拉伸填充铺满视口（侧栏为旧标签名，看瓦片区） |
| quicklaunch-url-dialog-light.png / quicklaunch-url-dialog-dark.png | 对话框单壳：不透明表面＋系统级圆角、聚焦描边输入框 |
| settings-window.png | 设置窗双栏 IA：左导航选中语言、分组卡、危险描边钮、页脚 |

GIF（动效叙事，首帧观察口径）：

| 图 | 看什么 |
|---|---|
| hero-loop.gif | 主循环演示（复制→入库→展开→拖回） |
| drag-reorder.gif | 拖动重排与插入指示线语义（同位松手无线） |
| multi-select-batch-pin.gif | 多选、批量置顶、整批移动 |
| review-markdown-toggle.gif | 归档视图「阅读/编辑」切换 |
| edge-collapse-hold.gif | 自动收起/展开/驻留锁定（演示自动收起，**非**停靠把手） |

已知资产缺口（不影响结构参照）：停靠把手特写、chip 轨、容器变换弹层、实验开关、深色设置窗、空状态均无资产——这些按 references 文字规格执行。
