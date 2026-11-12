# fts-provenance：fts 溯源锚点总表

> **定位**：本 Skill 全部内容的 fts（悬浮中转站）源项目锚点集中收纳——基线链、缩写、术语对照、逐 reference 关键锚点与反例修复记录。其余六件 references 正文一律不出现 fts 专属锚点；需要回库核对时读本文件。
> **来源**：fts-design-system 仓各 docs 篇「fts 溯源」尾节汇编（其锚点按基线逐条实测复核）；对账链＝仓内 `reference/extractions/2026-11-fts-v1.72.0.md`（部署副本离线，无该文件时以本文件为准）。
> **日期与行数预算**：2026-11-12 新增（W3c）；≤400 行（现 153 行）。

## 一、基线与仓链

| 项 | 值 |
|---|---|
| 内容基线 | fts main `bba9b4e`（2026-11-10，Merge PR #365；version.txt＝1.72.0） |
| Skill 前基线 | `fe2de2d`（1.71.0 后 main）；`git diff fe2de2d..bba9b4e` 对 DesignTokens.cs＋两本主题字典**为空**——两基线数值面一致 |
| 数值权威 | fts `src/FloatingTransferStation.Core/Design/DesignTokens.cs`（112 常量）＋`Resources/DesignTheme.Light|Dark.xaml`（各 22 画刷键）→ 经 DTCG 化入本仓 `tokens/`（152 token）与 `platforms/` 镜像 |
| 对账与再提取 | 本仓 `reference/extractions/2026-11-fts-v1.72.0.md`（diff 基准）；再提取流程 `docs/extraction-protocol.md`；对账标签 `fts-v1.72.0` |
| 本 Skill 源 | 本仓 `skill/fts-style-system/`（随仓版本化；`scripts/sync-skill.ps1` 幂等部署到用户级 skills 目录） |
| fts 仓 | `github.com/Oiawlm/floating-transfer-station`（本机检出 `D:\Download\Agent Vault\悬浮中转站\悬浮中转站-main`，对提取工作只读） |

## 二、缩写表（锚点路径均相对 fts 仓根）

| 缩写 | 路径 |
|---|---|
| DT | src/FloatingTransferStation.Core/Design/DesignTokens.cs |
| design | docs/design.md（源项目设计规范，六章） |
| 契约 | docs/design-contracts.md（源项目设计契约清单） |
| M | src/FloatingTransferStation/Resources/MainWindowStyles.xaml |
| MW | src/FloatingTransferStation/Views/MainWindow.xaml |
| SW | src/FloatingTransferStation/Views/SettingsWindow.xaml |
| LT / DK | Resources/DesignTheme.Light.xaml / DesignTheme.Dark.xaml |
| 镜像测试 | tests/FloatingTransferStation.Tests/MainWindowInteractionTests.DesignTokens.cs |
| 状态测试 | tests/FloatingTransferStation.Tests/MainWindowInteractionTests.ButtonStates.cs |
| FadeAnimation / LiftAnimation | Views/ 下同名文件 |
| PlacementAnimator | Services/WindowPlacementAnimator.cs |
| QuickLaunch | Views/MainWindow.QuickLaunch.cs |

## 三、术语对照（本 Skill 通用词 ↔ fts 专有名）

| 本 Skill | fts |
|---|---|
| 单源镜像锁定 | 镜像锁定测试（STA 断言资源==常量） |
| 分层状态卡片 | 板面卡片 |
| 快捷操作瓦片 | 启动瓦片 |
| chip 过滤轨 | 子分组（按钮）轨 |
| 贴边停靠 | 一次性贴边隐藏／边缘 peek |
| 落点指示环 | 双态环／默认标记 |
| 系统材质壳 | Mica 窗壳 |
| 容器变换弹层 | 二维码放大层（QR container transform） |
| 命中层/命中区 | 手势分区命中层 |

## 四、SKILL.md 哲学六条 → fts 锚点

| 原则 | 锚点 |
|---|---|
| §一 单一数值源＋镜像锁定 | design:3（唯一数值来源宣言）；DT:1-231；镜像测试:14/50/95/129/218（画刷/圆角/边距/时长/字体五面）；契约 #34 |
| §二 恒定几何 | design §五·B/§五·C（:159-174）；PlacementAnimator:65-161（受控迁移通道）；契约 #23（overlay 解耦）/#16（固定预留格） |
| §三 档位制 | design §四（:119-137 圆角两档＋登记）/§二（:63-91 时长三档锚定）/§五（:139-145 字号档）；DT:56-58/181-195/207-210 |
| §四 缓动按语义＋减动效 | design:89；DT:140-141；FadeAnimation:17-18（单点实例）；LiftAnimation:47-49（语义判据修正实录）；契约 #41 |
| §五 分层叠加＋悬停双轨 | design §三（:93-117 类型学）；M:108-143（层淡入）＋SW:271-274（按压透明度孤例）；M:200-201（焦点描边）；QuickLaunch:1178（按压缩放） |
| §六 克制与真实可达＋意图事务 | 契约 #13（真实消息守卫）/#62（悬停驻留先例）；DT:86（意图驻留窗 60ms） |

## 五、tokens-and-ladders → fts 锚点

| 规则 | 锚点 |
|---|---|
| 语义分工三原则＋21 键色板 | design §一（9-61）；DT:10-53 |
| 反馈色约定（成功=Accent/失败=Danger/中性=SecondaryText） | design:11 |
| 双主题同键位整本替换 | design:35；LT/DK（各 22 键全文，键集逐键一致）；Services/DesignThemeManager.cs:24-52 |
| 材质壳色调（80% alpha 回退注释） | DT:30-32 |
| 对话框表面＝字典侧值两本成对 | LT:8 / DK:7 |
| 配色豁免清单＋动态引用纪律（契约 #28） | design:61＋:226 |
| 灰态环复用 SecondaryText（契约 #56） | design:180 |
| 圆角两档判定（契约 #34）＋登记值 | design §四（119-137）；DT:181-195；M:42-57（八资源） |
| 派生三族＋chip 6×5 点名＋把手竖条 1.5 | design:137 |
| 间距收/不收判据＋结构尺寸非 token | design:145；DT:197-205；M:62-64（卡片族 Thickness 三资源） |
| 避让排他内缩 64＝2×30＋4 派生唯一来源 | M:25（含推导注释）；design:178 |
| 字号十档＋像素对齐点名 | design:141；DT:150-161（行高链 19=ceil(14×1.27+1)，契约 #25/#48） |
| 字体链唯一来源＋XAML 镜像互锁 | DT:143-149；M:16；design:190 |
| 换字体槽位（四键/清单校验/行高族重推导） | Services/InterfaceFontManager.cs:23-26/42-44/50-60；design:191 |
| 阴影三层＋共享冻结（浅 0.12/深 0.35） | design §五·B（159-166）；M:1241-1274；LT:27-33 / DK:26-32 |
| 系统材质壳＋不透明回退＋对话框不用材质 | design §五·C（168-174）；Services/DwmWindowEffects.cs:34-52／:11-32；DT:181-189；M:42 |
| 阅读排版 token（H1–H3 20/17/15、颜色零新增注释） | DT:163-179；design §五·G（196-208） |
| 瓦片几何族（84×100/8/92/3–6） | DT:212-230；design:147 |

## 六、layout-paradigms / motion / features → fts 锚点

| 主题 | 锚点 |
|---|---|
| 卡片模板全貌（三层/五状态层/命中层/操作格） | M:1241-1274（三样式）、M:2195-2480（模板）、M:1087-1239（容器模板＋分区边界四态）、M:17-25（操作列宽与避让资源）；Views/CardGestureZones.cs:9-68；design:161-163/:178 |
| 瓦片（模板/五族微交互/右键菜单/常量） | MW:1112-1315；QuickLaunch:1143-1262（微交互）/1270-1360（落位与交错）；M:1699-1769；DT:120-137；design:109 |
| 网格（钳制公式/摊分/承载面板/宿主） | Core/Design/LauncherGridMath.cs:17-64；Views/LauncherTilePanel.cs:23-97；MW:1081-1100；design:147 |
| 滚动条（族全量/两宿主挂接/两轮恢复） | M:2000-2193；MW:661-667（列表作用域）/872-888（文本派生）；Views/MainWindow.VisualTransitions.cs:23-70；design:164-166（契约 #23） |
| 对话框单壳（壳样式/系统圆角/直角回退/五窗复用） | M:1770-1782；DwmWindowEffects.cs:11-32；Views/DialogShellFallback.cs:11-22；LauncherUrlInputWindow.xaml:40＋.xaml.cs:34-40；MultiItemPickerWindow.xaml:43＋.cs:99-105；design:147 |
| 空状态（四宿主/文案矩阵/唯一求值点） | MW:675-741（搜索/过滤＋内容桶）/907-940（记录）/1050-1079（启动面）；Views/MainWindow.BoardEmptyState.cs:34-50（矩阵）/109-158（求值点）；MW:601-636 |
| 时长三档与场景族 | DT:56-58、:61-70、:75、:121-129；design §二（63-91） |
| 两条缓动＋单点实例＋语义判据 | DT:140-141；FadeAnimation:15-18/:98；LiftAnimation:49 |
| 可中断四要点 | FadeAnimation:15/:95-99；design:91（契约 #41） |
| 意图窗 60ms 豁免＋chip 驻留 300ms | DT:86＋MW.xaml.cs:250-253；MainWindow.SubgroupRail.cs:26-30；design:228（豁免表；收起驻留 250ms 已除名引慢档同源） |
| QR 独立时长组（契约 #24） | DT:102-118（注释含外部数值考据原文）；design:87/:91 |
| 例外通道五条款＋放置动画 | design:172-173；PlacementAnimator:59-65/:113-118/:156-161；tests/…/VisualLifecycle.cs:1031（条款锁定测试） |
| 减动效同键覆盖 | Views/MainWindow.Settings.cs:432-436 |
| 交互状态类型学/双轨/禁用档/Focus | design §三（93-118）；状态测试:45/:105；DT:209-210；M:128/:1382/:2025（悬停层与滑块双层）；M:218（焦点视觉清空） |
| chip 轨（样式族/环三态/模板分派/守卫链/改名会话/保持窗） | M:732-827（五段样式）/875-899（环）；MW:115-216（模板）/568-599（轨宿主）；Views/SubgroupChipTemplateSelector.cs:13-26；MainWindow.SubgroupRail.cs:119-131/:381-389/:557-563；Views/InlineRenameSession.cs:10-209；Views/MainWindow.DragAndDrop.cs:666-775；DT:75；Core/Services/InsertionSlotResolver.cs；design:137/:180（契约 #56/#57/#60/#62） |
| 贴边 peek（相位机/互斥/把手/救援） | Core/Services/EdgeHideStateMachine.cs:20-69；Core/Services/DockingIntentMutex.cs:21-58；Views/MainWindow.EdgeHide.cs:41-369；PlacementAnimator:13-234；Views/MainWindow.Lifecycle.cs:118-206；MW:1486-1524；DT:82/:86；design:173/:228（契约 #12/#17）；tests EdgeHideStateMachineTests/DockingIntentMutexTests |
| 容器变换（编排/结构/测量/交接断言） | DT:87-118；SW.xaml.cs:318-790（开层 318/入场 403-424/收回 599-542/退化 544-599/测量 612-643/四变换 656-747）；SW:1322-1432（放大层）/237-280（岛式缩略）/1271-1282；FadeAnimation:49-57；design:61/226/229（契约 #24）；tests SettingsWindowContactTests |
| 实验开关（节/自绘开关/迁移/回显） | SW:838-959（节）/148-194（开关样式）；Core/Services/ExperimentalDefaultsMigration.cs:18-47；Core/Models/AppPreferences.cs:191-195；SW.cs:87-134/:1814-1817；App.xaml.cs:96-100；fts docs/README.md:40（毕业判据）；迁移五态锁定测试 |
| 阅读视图（token/渲染器/映射器/宿主/切换钮） | DT:163-179；Views/MainWindow.ReviewMarkdownView.cs（全文件；NBSP 代换 181-193/链接白名单 295-314）；Core/Services/MarkdownDocumentMapper.cs:11-15；MW:768-786/890-906；M:303-344；design:194-209 |
| 设置窗双栏 IA（导航/共享视口/切页/键盘/页脚/冻结几何） | SW:105-147/363-433/415-430/1263-1316；SW.cs:874-966；Core/Design/SettingsWindowMetrics.cs:12-29；design:182-186（契约 #24） |

## 七、例七（AI 识图命名）锚点——沿 1.71.0 Skill 登记

例七内容沿 skill 前基线 `fe2de2d` 的登记收录（本仓 docs 对应篇为 v0.2 缺口，PLAN 裁决 D23）；以下锚点在 `bba9b4e` 经抽查（文件与关键地标存在），行号未逐条复核：

| 主题 | 锚点 |
|---|---|
| 调度器（队列/开关单点/一次性标记/补扫/串行排空） | Services/AiImageNamingScheduler.cs:52-67/74/90/112/145-164 |
| 交付层参数化（参数化核心/临时副本＋清理账本） | Services/DragPayloadService.cs:72-101/116-150/164-200 |
| 命名落板管线 | Core/Services/BoardMutationService.cs:282 |
| 设置卡（AI 页第四卡，隐私披露常可见） | SW:1228-1250 |

## 八、反例库修复/否决记录（A1–A24）

| # | 反例 | 记录 |
|---|---|---|
| A1 | 壳圆角幽灵 token | commit `8282072`；契约 #34 |
| A2 | 双口径网格 | commit `2a01828` |
| A3 | 滚动条独立布局列 | commit `c7ec808`（先行失败 `288fcac`） |
| A4 | 稳定留槽 | 契约 #23 由来否决记录 |
| A5 | 宽度补偿特判 | 契约 #23 断言 |
| A6 | 弹窗假圆角三件套 | commit `f2b7795` |
| A7 | 内容列居中对齐 | commit `a650ba8` |
| A8 | 内缩动态派生 | 契约 #16 |
| A9 | 覆盖层替代静态内缩 | 契约 #16 |
| A10 | 等分/换行面板按钮区 | 契约 #16 选型否决 |
| A11 | 特效进文字子树 | commit `3b6cec8` |
| A12 | 条件性外形 | commit `44a798e` |
| A13 | 分层透明壳 | commit `706db3c` |
| A14 | 纯透明度隐藏 | commit `79f1d2f`＋`269caed` |
| A15 | 快照画刷 | commit `ffb6830` |
| A16 | 场景时长加档 | DT 场景常量注释＋design §二（:63-91） |
| A17 | 模式化交互 | commit `ed62424` |
| A18 | 拖拽追赶＋往返门住 | commit `5e202d8`＋`ca52406`；`19aa930` 沿登记引用（源仓对象库不可解析，集成对账移交项） |
| A19 | 上限由布局属性声明 | commit `5293f95` |
| A20 | 覆盖层就地编辑 | commit `156f00b`＋`efdd076`＋`4315acc` |
| A21 | 缓动实例散布 | PR #345（merge `22a4244`，Issue #340） |
| A22 | 数值方向选曲线 | PR #345；修正实录 LiftAnimation.cs:47-49 |
| A23 | 禁用灰度散档 | PR #345；两档常量 DT:207-210 |
| A24 | 文案双写 | commit `f8f7ef6`（InstalledAppPickerTexts.cs:7-20） |

## 九、口径备注

- **示例值原则**：本 Skill 全部数值（83/167/250ms、4/8 圆角、0.4/0.6 禁用档、20/17/15 阅读档等）均为示例值；权威快照在本仓 `tokens/*.tokens.json`，机器可对账。
- **终态化口径**：收起驻留 250ms 属慢档 token 同源（design:228 豁免表除名在案）——skill 旧版「行为计时器例外」口径作废；意图窗 60ms/chip 驻留 300ms 仍是行为计时器豁免。
- **行号口径**：本表锚点按基线 `bba9b4e` 实测（经仓内 docs 溯源表逐条复核）；skill 旧版锚点存在 +1（M:384 区）/+3（MW:1013 区）/+2（SW:724 区）/+6（MW.xaml.cs 构造区）漂移，一律不引用。
- **产品行为契约**：本 Skill 只提指针——契约全文在 fts 仓 `docs/design-contracts.md`（编号 #N 即该文件条目）。
