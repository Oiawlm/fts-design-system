# 资产台账（assets/）

> **一句话定位**：本目录 18 项视觉资产的唯一台账——来源、编码与分辨率、内容一句话、关联文档与再生指针；只管资产事实，一切数值权威在 `tokens/`（此处零数值复制）。
> **来源**：PLAN-V1 §2.4 资产清单（`handoff/2026-11-11-bootstrap/PLAN-V1.md`）；两组源＝fts 仓 `docs/images/`（基线 `bba9b4e`，2026-11-04 批次录制）与用户级 skill `fts-style-system/assets/`（仅 `settings-window.png`，2026-11-10 新录）。
> **日期**：2026-11-12

## 事实约定

- **命名规范**：`<范式或场景>-<状态/主题>.png` 风格；本批 18 项源名即规范名，复制未重命名；GIF 保留原名链接语义（README 门面引用不因改名断链）。
- **字节原样**：18/18 经 `cmp` 与源逐字节一致（含下表 4 项 JPEG 编码文件——`.png` 扩展保持原样，转码决定移交集成窗口）。
- **只消费不新录**：本仓不录制新资产；再生一律回 fts 仓按其 `docs/images/README.md` 执行（源码构建预览实例＋`FTS_PREVIEW_DATA_DIR`/`FTS_PREVIEW_THEME` 环境变量隔离＋两段式 GIF 编码＋左下角手势角标；标注图解走真实截图＋标注脚本）。禁止随手截图补图。
- **禁入清单已执行**：真实个人内容双主题图、内容错位的深色设置图、手势交换佐证目录、含真实应用名/本机路径的发现选择器与插件区图均未收录。
- **识图核对**：13 张 PNG 全部经原生识图逐张核对（GIF 不参与识图核对，按首帧观察单独标注）；逐张记录见主检出 `handoff/2026-11-11-bootstrap/REPORT-E5.md` §三。

## 台账（18 行）

| # | 文件 | 来源 | 编码·分辨率 | 内容一句话 | 关联文档（规划路径） | 再生指针 |
|---|---|---|---|---|---|---|
| 1 | panel-anatomy.png | fts docs/images（2026-11-04 批次） | PNG RGBA 1100×1090 | 面板展开态结构标注图解：头部按钮组/分类标签/默认接收标记/卡片右上按钮/状态条；标签含两处旧术语（贴边隐藏、复盘），结构有效 | docs/visual-language.md §一/§五；docs/patterns/card.md | fts docs/images/README.md（预览实例＋标注脚本） |
| 2 | theme-light-dark.png | fts docs/images（2026-11-04 批次） | PNG RGBA 880×848 | 同一展开面板浅/深双联，悬停操作钮两主题均可见；深色整窗唯一静帧 | docs/foundations/color.md；docs/visual-language.md §三 | fts docs/images/README.md（`-Theme dark` 重启同种子实例） |
| 3 | quicklaunch-anatomy.png | fts docs/images（2026-11-04 批次） | PNG RGBA 1100×1090 | 启动页布局图解：工具行/发现预留位/瓦片/名称带/勾选钮/拖动排序七条标注；桌面壁纸入画 | docs/patterns/tile.md；docs/patterns/grid.md | fts docs/images/README.md（预览实例＋标注脚本） |
| 4 | card-gesture-zones.png | fts docs/images（2026-11-04 批次） | PNG RGBA 940×430 | 卡片左右两半手势分区图解（虚线分界；边缘环带归左半） | docs/patterns/card.md | fts docs/images/README.md（标注脚本） |
| 5 | card-delete-buttons.png | fts docs/images（2026-11-04 批次） | PNG RGBA 860×470 | 删除钮双语义 4× 放大图解（左键可撤销/右键永久；左列选择、右列删除、下行置顶） | docs/patterns/card.md | fts docs/images/README.md（标注脚本） |
| 6 | pinned-divider-accent-bar.png | fts docs/images（2026-11-02 批次） | PNG RGBA 418×640 | 置顶区与普通区之间通栏强调色分隔线（四样式之一）；右轨激活态与计数徽章入画 | docs/patterns/card.md；docs/foundations/color.md | fts docs/images/README.md（置顶分隔四样式族） |
| 7 | card-ai-organize-light.png | fts docs/images（2026-11-02 批次） | PNG RGBA 418×640 | 浅色：悬停卡浮现右上操作列（选择圈＋删除＋置顶）与长文截断卡 | docs/patterns/card.md；docs/interaction-states.md | fts docs/images/README.md（AI 整理族） |
| 8 | card-ai-organize-dark.png | fts docs/images（2026-11-02 批次） | PNG RGBA 418×640 | 同上场景深色主题：炭灰分层卡、亮一档文字 | docs/patterns/card.md；docs/foundations/color.md | 同上 |
| 9 | quicklaunch-surface-light.png | fts docs/images（2026-11-02 批次） | **JPEG 编码、.png 扩展** 627×960 | 启动瓦片面浅色：工具行「＋添加」、2×3 瓦片（线框图标＋名称带）、右轨激活态；侧栏为旧标签名，看瓦片区 | docs/patterns/tile.md；docs/patterns/grid.md | fts docs/images/README.md（启动页录制节） |
| 10 | quicklaunch-surface-dark.png | fts docs/images（2026-11-02 批次） | **JPEG 编码、.png 扩展** 627×960 | 同上深色：瓦片比壳亮一档、激活轨项深紫底 | 同上 | 同上 |
| 11 | quicklaunch-url-dialog-light.png | fts docs/images（2026-11-02 批次） | **JPEG 编码、.png 扩展** 540×267 | 添加网页地址对话框浅色：不透明单壳、聚焦紫描边输入框、取消/添加双中性钮 | docs/patterns/dialog.md | fts docs/images/README.md（启动页对话框节） |
| 12 | quicklaunch-url-dialog-dark.png | fts docs/images（2026-11-02 批次） | **JPEG 编码、.png 扩展** 540×267 | 同上深色（PLAN 台账注记为「—」，实为 JPEG 编码，本次补记） | docs/patterns/dialog.md；docs/foundations/color.md | 同上 |
| 13 | settings-window.png | skill assets（2026-11-10 新录 1.71.0 貌） | PNG RGBA 850×750 | 设置窗双栏 IA：左导航激活态（浅紫底＋左缘紫条）＋右侧分组白卡（主题/字体/动效开关/置顶分隔）；页脚版本字样旧一档，结构一致 | docs/patterns/settings-ia.md | fts docs/images/README.md（设置节；fts 仓同名图为 1020×900 旧裁，重录以此为准） |
| 14 | hero-loop.gif | fts docs/images（2026-11-04 批次） | GIF 720×364 | 主循环演示：网页选段复制→入库→悬停展开→拖卡片回投放框（角标标注手势）；GIF 不入识图核对，仅首帧观察（演示前置场景） | README 门面；docs/visual-language.md §六 | fts docs/images/README.md（逐资产要点 hero-loop 行） |
| 15 | drag-reorder.gif | fts docs/images（2026-11-04 批次） | GIF 540×700 | 分类内拖动重排：换位显示插入指示线、同位松手无指示线（角标分段）；仅首帧观察 | docs/patterns/card.md（手势）；docs/visual-language.md §六 | 同上 drag-reorder 行 |
| 16 | multi-select-batch-pin.gif | fts docs/images（2026-11-04 批次） | GIF 540×1040 | 右键多选三卡→头部图钉批量置顶→整批拖到目标分类（角标分段）；仅首帧观察 | docs/patterns/card.md；docs/interaction-states.md | 同上 multi-select-batch-pin 行 |
| 17 | review-markdown-toggle.gif | fts docs/images（2026-11-04 批次） | GIF 540×880 | 归档视图「阅读/编辑」切换 Markdown 渲染（角标分段）；仅首帧观察 | docs/patterns/reading-view.md | 同上 review-markdown-toggle 行 |
| 18 | edge-collapse-hold.gif | fts docs/images（2026-11-04 批次） | GIF 190×1040 | 移开收起→移入展开→保持展开开/关（原速基准）；演示自动收起，**非**停靠把手特写（防误读注记）；仅首帧观察（收起态窄标签条） | docs/motion.md；docs/visual-language.md §六 | 同上 edge-collapse-hold 行 |
