# docs/ 导读与任务路由

> **一句话定位**：本仓文档层的阅读入口——按「我想做 X」路由到对应篇目，附全量文件清单；四层架构（tokens→platforms→docs→skill）的叙述层。**来源**：W3a 集成窗口按集成态文件现状编制（八执行窗口产物）。**日期**：2026-11-12。**行数预算**：≤120 行（现 37 行）。

## 一、任务路由（「我想做 X → 读哪篇」）

| 我想… | 先读 | 再读 |
|---|---|---|
| 整体了解这套体系（价值观与反例） | [philosophy.md](philosophy.md)（六原则四段） | [anti-patterns.md](anti-patterns.md)（反例库＋自查清单）；[visual-language.md](visual-language.md)（六视角观察） |
| 选/查一个 token（色、尺寸、动效、排版数值） | [foundations/color.md](foundations/color.md)／[typography.md](foundations/typography.md)／[shape-and-spacing.md](foundations/shape-and-spacing.md)／[elevation-and-material.md](foundations/elevation-and-material.md) | 数值快照 `tokens/*.tokens.json`（权威）＋平台镜像 `platforms/wpf/`、`platforms/web/` |
| 做动效（时长档位/缓动/编排/减动效） | [motion.md](motion.md) | [patterns/container-transform.md](patterns/container-transform.md)、[patterns/peek-dock.md](patterns/peek-dock.md)（编排落位） |
| 定交互状态（hover/pressed/禁用/focus/图层结构） | [interaction-states.md](interaction-states.md) | [motion.md](motion.md)（时长/缓动侧） |
| 选静态结构/表面范式（卡片、瓦片、网格、滚动条、对话框、空状态） | [patterns/card.md](patterns/card.md)、[tile.md](patterns/tile.md)、[grid.md](patterns/grid.md)、[scrollbar.md](patterns/scrollbar.md)、[dialog.md](patterns/dialog.md)、[empty-state.md](patterns/empty-state.md) | 各篇「fts 溯源与可移植要点」 |
| 选动态范式（chip 轨、贴边停靠、容器变换、实验开关、阅读视图、设置 IA） | [patterns/chip-rail.md](patterns/chip-rail.md)、[peek-dock.md](patterns/peek-dock.md)、[container-transform.md](patterns/container-transform.md)、[experiment-toggle.md](patterns/experiment-toggle.md)、[reading-view.md](patterns/reading-view.md)、[settings-ia.md](patterns/settings-ia.md) | 对应基础/动效篇节名（篇内已互链） |
| 新项目整体套用这套体系 | [adaptation/adoption-workflow.md](adaptation/adoption-workflow.md)（八步工作流＋最小采用集） | [philosophy.md](philosophy.md)；[visual-language.md](visual-language.md) |
| WPF/.NET 落地 | [adaptation/wpf.md](adaptation/wpf.md)（三骨架＋陷阱集） | `platforms/wpf/DesignTheme.*.xaml`（现成镜像）＋[foundations/](foundations/) 各篇 |
| Web/CSS 落地 | [adaptation/web.md](adaptation/web.md)（五映射＋reduced-motion/意图事务模式） | `platforms/web/tokens.css`（现成 CSS 变量） |
| 源项目升级后再提取一轮 | [extraction-protocol.md](extraction-protocol.md)（触发判定＋九步） | [../reference/extractions/2026-11-fts-v1.72.0.md](../reference/extractions/2026-11-fts-v1.72.0.md)（上轮对账＝diff 基准） |
| 查资产（截图/图解/动图）与识图结论 | [../assets/README.md](../assets/README.md)（台账 18 项） | [visual-language.md](visual-language.md)（逐图六视角） |
| 校验 tokens↔平台镜像一致性 | `scripts/validate-tokens.ps1`（三方对账） | [../reference/extractions/2026-11-fts-v1.72.0.md](../reference/extractions/2026-11-fts-v1.72.0.md)（计数与输出口径） |

## 二、文件清单（与仓库现状一一对应）

| 目录 | 文件 |
|---|---|
| docs/（根） | [philosophy.md](philosophy.md)、[anti-patterns.md](anti-patterns.md)、[visual-language.md](visual-language.md)、[motion.md](motion.md)、[interaction-states.md](interaction-states.md)、[extraction-protocol.md](extraction-protocol.md)、README.md（本文） |
| docs/foundations/（基础·视觉四篇） | [color.md](foundations/color.md)、[typography.md](foundations/typography.md)、[shape-and-spacing.md](foundations/shape-and-spacing.md)、[elevation-and-material.md](foundations/elevation-and-material.md) |
| docs/patterns/（范式·表面六篇） | [card.md](patterns/card.md)、[tile.md](patterns/tile.md)、[grid.md](patterns/grid.md)、[scrollbar.md](patterns/scrollbar.md)、[dialog.md](patterns/dialog.md)、[empty-state.md](patterns/empty-state.md) |
| docs/patterns/（范式·动态六篇） | [chip-rail.md](patterns/chip-rail.md)、[peek-dock.md](patterns/peek-dock.md)、[container-transform.md](patterns/container-transform.md)、[experiment-toggle.md](patterns/experiment-toggle.md)、[reading-view.md](patterns/reading-view.md)、[settings-ia.md](patterns/settings-ia.md) |
| docs/adaptation/（适配三篇） | [adoption-workflow.md](adaptation/adoption-workflow.md)、[wpf.md](adaptation/wpf.md)、[web.md](adaptation/web.md) |

其他层：`tokens/`（DTCG 四件，数值权威）、`platforms/wpf|web/`（平台镜像）、`assets/`（资产 18 项＋台账）、`reference/extractions/`（提取对账）、`scripts/`（对账校验）；`skill/`（Agent Skill 源，`skill/fts-style-system/`；部署脚本 `scripts/sync-skill.ps1`）。

## 三、读法约定

- 正文数值一律为**示例值**（表格双列「示例值｜token 路径」）；权威快照只在 `tokens/*.tokens.json`。
- 每篇正文保持框架中立（普适规则层）；fts 专属锚点（file:line/契约号）集中收纳在各篇「fts 溯源」尾节，溯源基线＝源项目 `bba9b4e`（1.72.0），对账链见 [../reference/extractions/2026-11-fts-v1.72.0.md](../reference/extractions/2026-11-fts-v1.72.0.md)。
