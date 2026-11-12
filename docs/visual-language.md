# 视觉语言（观察篇）

> **一句话定位**：以「观察者视角」从现成视觉资产提炼源项目设计的六面可感知特征（气质／密度与留白／明度关系／色彩印象／图形语言／动效特征），并为 docs/ 各篇提供「看什么」的资产索引——本篇看结构不看像素，数值权威在 `tokens/`。
> **来源**：资产＝`../assets/`（18 项，台账见 [../assets/README.md](../assets/README.md)）；文字依据＝源项目 `docs/design.md` §一/§四/§五/§六；13 张 PNG 全部经原生识图逐张核对，5 条 GIF 仅首帧观察。
> **日期**：2026-11-12　**行数预算**：≤350

**读法约定**：每条论断末尾标注来源——「图像观察·图名」＝直接看图得出的观察；「文档依据·design.md §X」＝源项目设计规范的文字叙述；两者并存时观察在前、规范佐证在后。观察与推断分开标注，不确定写不确定。文中数值均为示例值，权威路径指向 `tokens/*.tokens.json`（并行期按 TOKEN-MAP 声明路径照写）。「关联文档」为本轮并行窗口的规划路径，合并前可能尚未存在（集成窗口对账补链）。

## 一、整体气质

1. 安静的工具感：画面里没有插画、营销横幅、渐变装饰，全部像素都是界面结构件（卡片／轨／按钮／文字）；唯一的「图形」是演示图解里的标签芯片与引线。（图像观察·panel-anatomy / quicklaunch-anatomy / settings-window）
2. 轻盈来自「低对比表面阶梯＋大留白」：浅色下白卡浮在近白灰的壳上，层次差极小，面与面的区分靠细描边和浅阴影，不靠色块。（图像观察·theme-light-dark 左半；文档依据·design.md §一 表面由浅入深）
3. 克制的品牌存在感：品牌紫从不大面积铺底，只以小面积状态点出现——第一眼是「灰白的中性界面」，第二眼才读到紫色状态语言。（图像观察·settings-window / card-ai-organize-light；文档依据·design.md §一 Accent 语义分工）
4. 融入桌面而非占据桌面：窗口贴屏幕右缘、收起后只剩一条窄竖标签，保持最上层但尽量少打断工作区。（图像观察·edge-collapse-hold 首帧 / hero-loop 首帧；文档依据·design.md §五 结构不为内容让步）
5. 一致的秩序感：三行骨架（头部／内容／状态条）贯穿主面板、启动页、设置窗——标题一律左上、操作一律右上、反馈一律底部。（图像观察·panel-anatomy / quicklaunch-surface-light / settings-window；文档依据·design.md §五 布局范式索引）

## 二、密度与留白

1. 卡片「内松外紧」：内边距与水平内缩同为 12px（示例值：dimension.spacing.card-padding / dimension.spacing.card-inset），纵向卡间距仅 4px（示例值：dimension.spacing.card-gutter）——卡片彼此贴成紧凑一列，内容却离卡缘很远；直观感受是「一列白色长条，条内大量呼吸空间」。（图像观察·pinned-divider-accent-bar / card-ai-organize-light；文档依据·design.md §五 间距节奏）
2. 一卡一事的密度策略：正文单档字号（14px，示例值：typography.size.body），次级信息（备注／置顶标记）收进第二行小档（12px，示例值：typography.size.secondary）；长文截断到固定行数出省略号，绝不在列表里展开。（图像观察·card-ai-organize-light 长文卡省略号；文档依据·design.md §五 字号十档与行数钳制）
3. 瓦片面刻意低密度：每瓦只有居中图标＋名称带，网格随面板宽度铺满，无第二层信息。（图像观察·quicklaunch-surface-light / quicklaunch-anatomy；文档依据·design.md §五 拉伸填充）
4. 设置页以分组卡控密度：一张卡只回答一个问题（主题／字体／动效／置顶分隔），卡内「标签＋控件」两行，卡与卡之间留大间距。（图像观察·settings-window）
5. 头部与状态条都薄：头部一行操作按钮组、状态条单行反馈，垂直空间几乎全让给内容区。（图像观察·panel-anatomy 标注）

## 三、明度关系

1. 浅色主题「内容最亮」：窗壳（近白灰）→导航轨（深半档）→卡片（纯白）由暗到亮，卡片是画面上最亮的面；文字近黑，对比集中在卡上。（图像观察·theme-light-dark 左半 / pinned-divider-accent-bar；文档依据·design.md §一 浅色键表）
2. 深色主题保留阶梯、反转方向：壳炭黑（示例值 #202021，color.surface.window-shell 深色分支）→卡略亮一档（示例值 #2D2D2E，color.surface.card 深色分支）——卡不是纯黑也不发光，亮文字浮在两层炭灰之间。（图像观察·theme-light-dark 右半 / card-ai-organize-dark）
3. 深色分层更依赖描边与阴影：两档表面亮度差小，卡界由灰描边＋更重的阴影补足（示例值：color.shadow.card-opacity 深色 0.35、浅色 0.12）。（文档依据·design.md §一 末段；图像观察·card-ai-organize-dark 卡缘）
4. 状态不改明度结构：激活轨项、选中卡的紫底在两主题下都与所在表面同一明度带（浅紫对浅色、深蓝紫对深色），不跳出高亮块。（图像观察·theme-light-dark 两半激活轨项；文档依据·design.md §一 选中／激活键）

## 四、色彩印象

1. 单一强调紫、占比极小：九成以上画面是灰阶，紫色只出现在焦点描边、激活轨项、固定置顶图钉、强调分隔线、链接、开启态开关等「状态点」上。（图像观察·settings-window 开关与链接 / pinned-divider-accent-bar 分隔线 / card-ai-organize-light 图钉；文档依据·design.md §一 Accent 只承担选中/活动/指示/插入语义，不作装饰底色）
2. 紫色以「淡紫状态层」成族出现：激活轨项、选中卡、拖放目标都铺一层极低饱和紫底，与高饱和指示小件（图钉／环／条）同族；深色下这层变深蓝紫。（图像观察·theme-light-dark / pinned-divider-accent-bar 右轨）
3. 危险红只出现在破坏性出口：清空／退出类动作用红描边钮而非红填充大钮，普通浏览路径上见不到红。（图像观察·settings-window 右下红描边退出钮；文档依据·design.md §一 Danger 只承担破坏性语义）
4. 成功不引入新色相：成功反馈复用强调紫、失败用红、中性提示用次级灰——调色板保持「灰阶＋紫＋一点红」的三元结构。（文档依据·design.md §一 文案反馈色规则）
5. 深浅主题各自派生同族强调色：深色强调紫整体提亮一档（示例值 #9C8CFF，color.accent.default 深色分支）保证对比，观感上仍是「同一个紫」。（文档依据·design.md §一 深色键表；图像观察·quicklaunch-surface-dark 激活轨项）

## 五、图形语言

1. 圆角两档节奏：控件级小、表面级大（示例值 4px/8px：dimension.radius.control / dimension.radius.surface）——按钮、输入框方正，卡片、瓦片、对话框、窗壳同享一档圆润；「小件方正、容器柔和」。（文档依据·design.md §四 两档阶梯；图像观察·settings-window 分组卡与下拉圆角差 / quicklaunch-url-dialog-light 壳角）
2. 窗壳圆角由系统承载、内容自裁剪同值：窗口四角与内容圆角对齐，不出现双层圆角。（文档依据·design.md §四；图像观察·theme-light-dark 窗角）
3. 阶梯外小件圆角按登记制：头部钮、图钉钮、勾选圈等识别件各有登记值（示例值 7/6/5px：dimension.radius.header-action / pin-button / selection-ring），不破坏整体节奏。（文档依据·design.md §四 登记值表；图像观察·card-delete-buttons 删除钮 / card-ai-organize-light 勾选圈）
4. 1px 级低对比描边定义边界：默认浅灰描边，悬停描边加深一档而非加粗，没有粗黑框。（文档依据·design.md §一 Border/HoverBorder 键；图像观察·card-ai-organize-light）
5. 细线框单色图标语言：垃圾桶／地球／图钉／勾选圈全是线框风格、继承文字色，无彩色图标、无立体质感；瓦片居中大图标是全界面唯一的「图形主角」。（图像观察·quicklaunch-surface-light / card-delete-buttons）
6. 标注图解自成一套可复用规范：强调紫圆角芯片标签＋细引线指向真实截图，虚线表示分区边界——本仓资产复用的同一标注语言。（图像观察·panel-anatomy / quicklaunch-anatomy / card-gesture-zones / card-delete-buttons）

## 六、动效可感知特征

> **素材与局限**：本节基于 5 条 GIF 首帧（动作发生在后续帧；GIF 按 12fps 编码，时长不等于实际体感）＋源项目动效规范文字。动效数值权威在 `tokens/motion.tokens.json`，此处只描述「可感知的档位与语义」。

1. 动效整体「存在感低、服务状态」：没有循环装饰动画，一切运动都绑定一次状态转换（展开／收起／入场／拖放／删除）。（图像观察·五条 GIF 首帧均为静态构图；文档依据·design.md §六）
2. 展开／收起是核心动效：移开自动收成边缘标签、移入展开，可被驻留锁定暂停；收起带方向性出场位移（示例值 24px：dimension.offset.collapse-exit）。（图像观察·edge-collapse-hold 首帧窄标签条；文档依据·design.md §六）
3. 「悬停先揭示、点击才执行」两段式：卡片操作列（选择／删除／置顶）只在悬停时浮现——动效集中在揭示瞬间，平时画面保持干净。（图像观察·card-ai-organize-light 悬停卡有钮、未悬停卡无钮；文档依据·design.md §六）
4. 拖放有动效签名：列表内换位显示插入指示线、同位松手无线；瓦片拖动排序要求跟手无迟滞。（图像观察·quicklaunch-anatomy 标注「跟手无迟滞」；drag-reorder / multi-select-batch-pin 首帧仅拖放前置场景，标注局限；文档依据·design.md §六）
5. 入场是轻位移淡入：内容入场与分类揭示用小位移＋淡入（示例值 6px：dimension.offset.content-entrance），瓦片入场逐瓦交错——首帧无法观察此瞬间，仅规范佐证。（文档依据·design.md §五/§六）
6. 时长三档体感：快／正常／慢三档（示例值 83/167/250ms：motion.duration.fast / normal / slow）覆盖反馈与转场；受 GIF 编码限制只能给出印象级结论「动效短促、无长转场」。（文档依据·design.md §二/§六）

## 七、资产索引表（图 → 看什么 → 关联文档）

> 台账（`../assets/README.md`）管事实（来源／编码／分辨率／再生指针），本表管教学。

| 图 | 看什么 | 关联文档 |
|---|---|---|
| [panel-anatomy](../assets/panel-anatomy.png) | 三行骨架、头部操作组、默认接收标记、卡片右上操作列、状态条位置 | patterns/card、本文 §一/§二/§五 |
| [theme-light-dark](../assets/theme-light-dark.png) | 双主题表面阶梯、明度关系、激活轨项两态 | foundations/color、本文 §三/§四 |
| [quicklaunch-anatomy](../assets/quicklaunch-anatomy.png) | 瓦片结构、工具行、名称带、勾选钮、拖动排序标注 | patterns/tile、patterns/grid |
| [card-gesture-zones](../assets/card-gesture-zones.png) | 手势分区（左半编辑与送达、右半复制、右键选中） | patterns/card |
| [card-delete-buttons](../assets/card-delete-buttons.png) | 删除钮双语义、操作列布局（左列选择／右列删除／下行置顶） | patterns/card |
| [pinned-divider-accent-bar](../assets/pinned-divider-accent-bar.png) | 置顶分区、强调色分隔线、卡内外距观感、右轨激活态 | patterns/card、本文 §二/§四 |
| [card-ai-organize-light](../assets/card-ai-organize-light.png) | 悬停操作列揭示、长文截断、浅色卡观感 | patterns/card、interaction-states |
| [card-ai-organize-dark](../assets/card-ai-organize-dark.png) | 同上深色；深色描边与阴影分层 | patterns/card、本文 §三 |
| [quicklaunch-surface-light](../assets/quicklaunch-surface-light.png) | 瓦片网格铺满、图标＋名称带、右轨激活态（看瓦片区；侧栏旧标签名） | patterns/tile、patterns/grid |
| [quicklaunch-surface-dark](../assets/quicklaunch-surface-dark.png) | 深色瓦片面、亮一档瓦片、提亮强调紫 | patterns/tile、本文 §三/§四 |
| [quicklaunch-url-dialog-light](../assets/quicklaunch-url-dialog-light.png) | 对话框单壳、聚焦描边输入框、中性双钮 | patterns/dialog |
| [quicklaunch-url-dialog-dark](../assets/quicklaunch-url-dialog-dark.png) | 同上深色 | patterns/dialog |
| [settings-window](../assets/settings-window.png) | 双栏 IA、左导航激活语言、分组卡、开关／下拉控件、危险描边钮、页脚 | patterns/settings-ia、本文 §一/§四/§五 |
| [hero-loop](../assets/hero-loop.gif) | 主循环演示全链路（复制→入库→展开→拖回）；动效叙事参考 | 本文 §六（首帧＋文档） |
| [drag-reorder](../assets/drag-reorder.gif) | 拖动重排与插入指示线语义 | patterns/card（手势） |
| [multi-select-batch-pin](../assets/multi-select-batch-pin.gif) | 多选、批量置顶、整批移动 | patterns/card、interaction-states |
| [review-markdown-toggle](../assets/review-markdown-toggle.gif) | 归档视图「阅读／编辑」切换 | patterns/reading-view |
| [edge-collapse-hold](../assets/edge-collapse-hold.gif) | 自动收起／展开／驻留锁定（注意：演示自动收起，**非**停靠把手） | motion、本文 §六 |

## 八、缺口清单（登记不阻塞；补录属源项目再生纪律，本仓不新录）

**PLAN 点名七项**：

1. 停靠把手收缩态／特写（最大缺口）——edge-collapse-hold 演示自动收起，把手形态无资产（防误读注记见台账 #18）。
2. 深色主题整窗新貌——现有深色静帧止于既有双联批次，非当前版本整窗。
3. 状态覆层／紧凑弹层特写——无一图覆盖。
4. chip 过滤轨——chip 样式族无专属资产。
5. 容器变换弹层与实验开关——两范式无资产。
6. 设置实验节现貌——设置图止于外观页。
7. 阅读视图双主题静帧——只有 GIF（不入识图核对）。

**识图新发现**：

8. 侧栏／标签名旧一档资产族：panel-anatomy 标注含两处旧术语，quicklaunch-surface 双图侧栏同为旧标签名——结构有效，重录时应一并更新。（图像观察·panel-anatomy / quicklaunch-surface-light）
9. 空状态无资产：18 项中无一图展示空分类态（图标＋标题＋副文案宿主），patterns/empty-state 将无图可引。（图像观察·18 项内容清点）
10. 深色主题交互态缺失：现有深色图全为默认静帧，无悬停／选中／拖放的深色特写。（图像观察·card-ai-organize-dark / quicklaunch-surface-dark）
11. 设置窗仅浅色：无深色设置窗资产，双栏 IA 的深色观感无对照。（图像观察·settings-window）

## 九、fts 溯源

- 资产基线：fts main HEAD `bba9b4e`（1.72.0）；`docs/images/` 的录制环境（源码预览实例＋`FTS_PREVIEW_DATA_DIR`/`FTS_PREVIEW_THEME` 隔离＋两段式 GIF＋手势角标）与逐资产要点见 fts 仓 `docs/images/README.md`；`settings-window.png` 来自用户级 skill `fts-style-system/assets/`（2026-11-10 新录 1.71.0 貌，850×750；fts 仓同名图为 1020×900 旧裁）。
- 复制事实：18/18 经 `cmp` 与源逐字节一致；未重命名（源名即 `<场景>-<状态/主题>` 规范名，GIF 保留原名链接语义）。
- 编码事实：`quicklaunch-surface-light/dark.png`、`quicklaunch-url-dialog-light/dark.png` 4 项实为 JPEG 编码（PLAN §2.4 注记 3 项，#12 深色对话框为本次识图补记）；保持字节原样，转码决定移交 W3a。
- 禁入清单执行：PLAN §5.6 四组（真实个人内容双主题图、内容错位设置图、手势佐证目录、真实应用名／本机路径组）未收录。
- 文字依据出处：源项目 `docs/design.md` §一（配色体系）、§四（圆角）、§五（排版与布局）、§六（动效原则），基线 `bba9b4e`；tokens 路径按 TOKEN-MAP-V1（对账 [2026-11-fts-v1.72.0.md](../reference/extractions/2026-11-fts-v1.72.0.md)） 声明照写（并行期约定，W3a 对账兜底）。
