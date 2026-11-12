# 动效（Motion）

> **一句话定位**：动效体系的普适规则——时长档位制、按语义选缓动、编排纪律（可中断/意图事务/交错入场）、窗口级例外通道与减动效统一退化；数值只是示例，权威快照在 `tokens/motion.tokens.json`。**来源**：源项目 1.72.0 基线（commit `bba9b4e`）设计规范动效章＋动画原语/放置动画服务源码，经 TOKEN-MAP-V1 §3.3 映射（对账见 [reference/extractions/2026-11-fts-v1.72.0.md](../reference/extractions/2026-11-fts-v1.72.0.md)）。**日期**：2026-11-12。**行数预算**：≤400 行（现 149 行）。

交互状态（hover/pressed/禁用/focus）的类型学与图层结构见 [interaction-states.md](interaction-states.md)；范式篇（[peek-dock.md](patterns/peek-dock.md)、[container-transform.md](patterns/container-transform.md)、[tile.md](patterns/tile.md)）是本篇规则的具体落位。

## 一、档位（时长阶梯）

三档取值可整体替换（示例值来自 Win11 Fluent 官方时长表），档位思想不变：任何场景时长必须**落档或登记**，禁止第四档散值。

| 档 | token 路径 | 示例值 | 典型场景 |
|---|---|---|---|
| 快 | `motion.duration.fast` | 83ms | 按压反馈、贴边把手登场淡入、减动效纯淡出 |
| 中 | `motion.duration.normal` | 167ms | 悬停反馈、面板展开内容入场、贴边收起出场（加速曲线） |
| 慢 | `motion.duration.slow` | 250ms | 标准控件动画、启动确认脉冲、新条目落位、贴边展开入场（减速曲线） |

**场景时长登记表**（新场景从三档起步，不为凑值引入新档）：

| 场景 | token 路径 | 示例值 | 性质 |
|---|---|---|---|
| 面板展开内容入场 | `motion.duration.panel-expand` | 167ms | 中档别名（锚定不加档） |
| 面板切换内容过渡 | `motion.duration.panel-switch` | 140ms | 场景原始值（快于展开档的轻过渡） |
| 面板收起出场 | `motion.duration.panel-collapse-exit` | 200ms | 场景原始值（不对称登记例外，§二） |
| 分类/分组揭示 | `motion.duration.category-reveal` | 120ms | 场景原始值 |
| 显隐淡入淡出 | `motion.duration.fade-visibility` | 120ms | 场景原始值 |
| 删除反馈 | `motion.duration.delete-feedback` | 120ms | 场景原始值 |
| 悬停反馈 | `motion.duration.hover-feedback` | 167ms | 中档别名 |
| 按压反馈 | `motion.duration.press-feedback` | 83ms | 快档别名 |
| 减动效纯淡出 | `motion.duration.reduced-fade` | 83ms | 快档别名 |
| 条目入场交错步进 | `motion.duration.stagger-step` | 40ms | 节奏值（非档位，与封顶规则绑定，§三） |
| 拖放目标撤离保持窗 | `motion.duration.drop-target-hold` | 120ms | 场景原始值（覆盖手抖频率，真离开无感知迟滞） |
| 启动确认 | `motion.duration.launch-confirm` | 250ms | 慢档别名 |
| 新条目落位 | `motion.duration.item-landing` | 250ms | 慢档别名 |
| 启动后排队收起延迟 | `motion.duration.launch-collapse-delay` | 250ms | 慢档别名（时序性延迟，减动效保留，§五） |
| 启动重入门闩 | `motion.duration.launch-reentry-latch` | 500ms | 编排门闩（同窗第二击不重复派发，非视觉档） |
| 瓦片入场交错步进 | `motion.duration.tile-stagger-step` | 40ms | stagger-step 别名 |

规则要点：

1. **新场景锚定既有档**：直接等值（启动确认＝慢档）或复用档＋既有曲线（贴边收起＝中档＋加速、展开＝慢档＋减速），无新档无新曲线。
2. **行为计时器豁免**：意图窗 60ms（贴边展开驻留重验，§三）、chip 驻留计数 300ms、状态保持 4s、反馈复位 1.6s 等是**时序编排值非视觉档**，不设 token——豁免必须成文登记（源项目登记于设计规范豁免表），禁止静默字面量。
3. **独立时长组是极少数契约化例外**（下），不是加档后门。

### 独立时长组（教学案例：容器变换弹层）

容器变换弹层（container-transform overlay；源项目为二维码放大层）一组专用：

| 环节 | token 路径 | 示例值 |
|---|---|---|
| 入场 | `motion.qr.zoom-in` | 450ms |
| 收回 | `motion.qr.zoom-out` | 250ms |
| 文字淡入起点 | `motion.qr.text-fade-in-begin` | 270ms（≈60% 入场进度，落位时可读） |
| 文字淡入时长 | `motion.qr.text-fade-in` | 180ms |
| 文字收回先隐 | `motion.qr.text-fade-out` | 90ms |
| 缩略图防双影淡出 | `motion.qr.thumb-fade` | 150ms |
| 缩略图回显起点 | `motion.qr.thumb-reveal-begin` | 180ms |
| 收回交接段 | `motion.qr.handover-fade` | 70ms（派生＝收回−回显起点；源项目生产代码零消费的文档性常量） |
| 入场专用曲线 | `motion.easing.qr-zoom-in` | cubic-bezier(0.32, 0.72, 0, 1) |
| 收回专用曲线 | `motion.easing.qr-zoom-out` | cubic-bezier(0.25, 0.1, 0.25, 1) |

三个教学要点：**为何例外**——容器变换是多动画同帧编排（矩形插值是结构性质，§三），三档的「单值单曲线」模型装不下它的编排包络；**如何登记**——整组契约化登记并给出外部数值依据（组内曲线为 iOS 转场测量近似/系统默认曲线，数值考据见 [container-transform.md](patterns/container-transform.md)）；**边界在哪**——不进三档、不被三档外场景借用，新增独立组必须给出同等依据。全仓目前仅此一组。

## 二、缓动（按语义选曲线）

| 语义 | token 路径 | 示例值 | 观感 |
|---|---|---|---|
| 进入某视觉态（淡入/抬升/入场/展开） | `motion.easing.enter` | cubic-bezier(0,0,0,1)（减速） | 快出缓停 |
| 离开某视觉态（淡出/回落/出场/收缩） | `motion.easing.exit` | cubic-bezier(1,0,1,1)（加速） | 缓出快收 |
| 减弱动效 | —（退化为 linear 或直接定格） | — | §五 |

1. **选择规则＝语义，不是数值方向**。判据是「目的地进入视觉态还是离开视觉态」。「`to < from` 用加速」只是**透明度语义**下恰好成立的判据（淡出数值必变小）；位移抬升（如 0→−1px）数值同样变小，套用即错配（源项目曾实测与宣称相反并修正为按目标态判别）。教训成文：缓动判据写进规范时必须给反例。
2. **缓动单点实例**：全部动效经统一缓动工厂/单一实例消费（桌面端：由 token 构建的共享缓动对象；Web 端：CSS 变量直用 `cubic-bezier()` 函数），禁止散布 new 曲线实例；专用曲线经同一工厂的 token 参数指定，不新增散布实例。
3. **不对称原则**：出场快于入场（观感上收尾不拖）。登记例外：面板展开 167ms／收起 200ms——收起慢于展开，属收起节奏的场景登记值（不是新档）；例外按场景登记并标注，不泛化。
4. **专用曲线组例外登记**：容器变换两条组内曲线（§一）不并入通用两曲线；新增专用曲线须随独立时长组一并契约化登记。

## 三、编排（时序、微交互与可中断性）

**可中断动画四要点**（全部动效的默认实现纪律）：

1. **新状态先复位终值**：先清挂起动画、把属性写定到新终值、再挂新动画——动画永不承载终值语义，用户不必等动画播完（桌面端：清动画→写终值→再挂新动画；Web 端：先设目标样式再播放过渡）。
2. **动画结束回落属性值**（停止填充语义）：终值已由第 1 步写定，避免填充值与属性值双账本。登场基线注意：动画自 0 登场时基线必须落在终值而非起点，否则回落 0 整体隐形（源项目贴边把手登场淡入曾踩此回归）。
3. **新动画替换在途动画**（快照替换语义）：不叠加、不排队。
4. **隐藏回调防陈旧**：显隐管理为每次隐藏记代数，完成回调校验代数与当前状态，陈旧回调不执行。

**入场事件区分与交错**：

- 只有**真正的新增项**（新卡、新瓦片）才播入场动画；重排、图标回填、改名、撤销恢复一律不播——「表面展开的交错重播」与「新增项落位」是两件事。
- 交错入场：步长 40ms（示例值：`motion.duration.stagger-step`）带封顶 `min(i, 8)`（封顶值登记为文档性 token `motion.stagger.tile-cap`；源项目封顶逻辑为字面量实现，引用时标注）——第 9 项起同帧出现，长列表尾部不罚等待。
- 位移幅度分族：卡片 6px（`dimension.offset.content-entrance`）、瓦片 8px（`dimension.offset.tile-entrance`）——同机制不同量级。

**悬停意图事务**（hover 触发激活级动作时）：布防 timer → 到期**重验指针仍在目标内**才提交，离开即取消；迟到旧离开不取消已被取代的新意图。防扫边误触由事务重验达成，不另设防抖层。

- 两例：贴边把手展开意图窗 60ms（行为计时器豁免，§一）、chip 驻留计数 300ms。
- 结构性前提：悬停只做纯视觉预览，激活属点击——hover 直接触发激活级内容切换是反模式。

**容器级非线性先例**（容器变换弹层）：大位移/形变不走纯淡入。动画对象＝外层整卡（含框飞行、方→矩形形变），四动画同帧启动（矩形插值的结构性质）；文字后段浮现；缩略图防双影淡出。收回＝对齐落位回显：缩略图在容器接近落位尺寸后才回显，交接段两元素线性交叉、合成存在感恒≈1，无台阶/空窗/双影。独立时长组＋专用曲线（§一/§二）。完整配方见 [container-transform.md](patterns/container-transform.md)。

## 四、例外通道（窗口级连续迁移）

**恒定几何是默认铁律**：窗口状态迁移**一次矩形变更到位**（单次系统放置调用应用终态＋窗口消息守卫拦截中间矩形），观察到的每个窗口矩形 ∈ {初始, 终态}；禁止区域裁剪伪装，禁止用动效/延迟/隐藏窗口装饰性掩盖中间态。

**唯一例外通道**＝经唯一放置动画服务的连续受控迁移（源项目首例＝边缘 Peek 整窗同尺寸纯平移）。五条边界：

1. **单一矩形权威**：动画期间几何权威归动画服务；任何外部放置入口必须先取消（一次放置调用到达动画终态）再应用新放置。
2. **逐帧单调**：缓动单调 ⇒ 物理域取整后非严格单调，无来回抖动。
3. **终态唯一**：首帧立即应用、末帧精确落在终态；完成回调在终态落位后发出。
4. **可中断可重定向**：重定向捕获当前实时进度（按时间戳采样，非末帧值）为新起点，时长按剩余距离比例重映射、封顶满时长，**禁原点重放**——收缩途中指针追入把手即从当前进度反转展开。
5. **减动效直达**：减弱动效全链跳到终态（§五），例外通道不豁免减动效。

例外必须**契约化登记**而非散布：锁定测试断言单一权威/单调/终态唯一，可注入时钟（生产＝渲染帧时钟，测试＝手动推帧）让动画可逐帧断言。时长/缓动全部复用既有 token（收起 167ms 加速出场、展开 250ms 减速入场），例外通道不产生新档新曲线。范式细节见 [peek-dock.md](patterns/peek-dock.md)。

## 五、减动效（统一退化口径）

1. **触发同一开关**：系统「减弱动效」与用户在设置关闭动效**同键**——桌面端用户覆盖直接写进系统动画键资源、恢复即移除；Web 端由 `prefers-reduced-motion` 媒体查询统一承载（映射见 [adaptation/web.md](adaptation/web.md)）。全部动效消费同一开关，不允许只关一半。
2. **退化规则**：运动型动效取消（保留状态终值）→ 83ms 纯淡出（示例值：`motion.duration.reduced-fade`）或立即定格终值；缓动退化为 linear；**时序性延迟保留**（如启动后排队收起 250ms 是时序编排非动效）；窗口级动画（§四）全链直达终态。
3. **恢复即移除覆盖**：重新跟随系统键，不留残余状态。

## 六、原则（评审基准）

1. 进入减速、出场加速，退出比进入快；登记例外（面板展开/收起不对称）按场景标注，不泛化不加档。
2. 动效可中断、可重定向：新动画必须先复位终值；不得让用户等动画播完。
3. 动效不阻断命中测试；**永不作传达信息的唯一载体**（失败态闪烁必须转向常显态，反例见 [tile.md](patterns/tile.md)）。
4. 减弱动效统一退化口径（纯淡出或定格）；时序性延迟保留。
5. 状态迁移的视觉交接防闪烁机制（收起交接等）不被动画破坏。
6. 图标资产取自开源图标库（MIT）几何重绘，不随应用分发字体文件（许可纪律）。

评审口径：新动效逐条对照 §一档位表（无第四档）、§二曲线表（无数值判据）、§三四要点（可中断）、§四（不新增例外通道）、§五（有退化路径）；任一不满足即回设计。

## 附：fts 溯源

> 源项目＝悬浮中转站（fts），基线 commit `bba9b4e`（1.72.0）；行号基于该基线实测（2026-11-12 逐条抽查通过）。数值映射见 TOKEN-MAP-V1 §3.3，对账 [reference/extractions/2026-11-fts-v1.72.0.md](../reference/extractions/2026-11-fts-v1.72.0.md)。

| 规则/事实 | fts 锚点 |
|---|---|
| 时长三档 83/167/250 | `src/FloatingTransferStation.Core/Design/DesignTokens.cs:56-58` |
| 场景时长族（别名＋原始值＋启动族＋交错） | `DesignTokens.cs:61-70`、`:75`（撤离保持，契约 #51）、`:121-129`（启动确认/落位/收起延迟/重入门闩/瓦片交错） |
| 三档官方出处登记 | `docs/design.md` §二首段（63-66） |
| 两条通用缓动字面串 | `DesignTokens.cs:140-141` |
| 缓动单点实例（token→共享缓动对象） | `src/FloatingTransferStation/Views/FadeAnimation.cs:15-18` |
| 缓动按语义不按数值方向（2026-11-08 修正） | `src/FloatingTransferStation/Views/LiftAnimation.cs:49`；透明度语义数值判据（仅该语义合法）`FadeAnimation.cs:98` |
| 可中断四要点（快照替换/停止填充/代数防陈旧） | `FadeAnimation.cs:15`、`:95-99`；`docs/design.md:91`（契约 #41） |
| 贴边收起＝中档＋加速、展开＝慢档＋减速 | `src/FloatingTransferStation/Views/MainWindow.EdgeHide.cs:144`、`:317` |
| 展开意图窗 60ms（行为计时器豁免） | `DesignTokens.cs:86`；`MainWindow.xaml.cs:250-253`（timer 布防）；豁免表 `docs/design.md:228` |
| chip 驻留 300ms 计数 | `MainWindow.SubgroupRail.cs:26-30`（注释） |
| 容器变换独立时长组＋专用曲线（契约 #24） | `DesignTokens.cs:102-118`；`docs/design.md:87`、`:91` |
| 例外通道五条款＋迁移原子性铁律 | `docs/design.md:172-173`；`src/FloatingTransferStation/Services/WindowPlacementAnimator.cs:59-65`（契约注释）、`:113-118`（Redirect 禁原点重放）、`:156-161`（Cancel 先到终态） |
| 例外通道锁定测试＋可注入时钟 | `tests/FloatingTransferStation.Tests/MainWindowInteractionTests.VisualLifecycle.cs:1031`（`PlacementAnimation_SingleAuthorityMonotonicTerminalUnique`） |
| 减动效同键覆盖/移除 | `src/FloatingTransferStation/Views/MainWindow.Settings.cs:432-436` |
| 动效原则与豁免登记（含收起驻留终态口径） | `docs/design.md` §六（211-235）、`:228` |
