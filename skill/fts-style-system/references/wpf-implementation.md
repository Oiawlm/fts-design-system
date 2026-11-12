# wpf-implementation：WPF 落地映射与陷阱库

> **定位**：新项目第 2/3/5 步在 WPF（含 WinUI 思想迁移）技术栈落地时的管线与陷阱——token 两通道、双字典分工与整本换装、镜像锁定测试断言面、动效基建三部件、十一条已验证陷阱；Web 栈对应走 CSS 变量映射（源仓 docs/adaptation/web.md）。
> **来源**：源仓 docs/adaptation/wpf.md 提炼＋skill 前身陷阱库续收（T1–T10 沿 1.71.0 登记、T11 为 1.72.0 新收）；fts 基线 1.72.0（commit `bba9b4e`）；键名与源仓 `platforms/wpf/` 镜像一致（每本 39 键＝21 画刷＋1 阴影＋17 主题不变键）。fts 锚点见 [fts-provenance.md](fts-provenance.md)。
> **日期与行数预算**：2026-11-12 重建；≤400 行（现 112 行）。按需精读，不必先读。

## 一、单一数值源管线（两通道）

```
数值源（token 常量类；词汇表对照 tokens/*.tokens.json 与 platforms/wpf/）
   ├─ 直引通道：时长/几何/不透明度 → XAML {x:Static}（编译期绑定，不随主题变）
   └─ 镜像通道：颜色/圆角/边距/字体 → 主题字典与样式资源键（运行期整本替换支持换主题）
                    ↑ 单源镜像锁定测试：断言 资源值 == 数值源
```

要点：颜色必须走资源字典（主题切换）；时长/几何/不透明度可直引常量；**两条通道都要有锁定测试兜住**；场景时长＝档位的 const 引 const（编译期锁「锚定不加档」）；公式型派生值（行高）收结果值＋注释记公式。

## 二、两本主题字典与整本换装

- 合并顺序：共享样式层（形状/字号/触发器/样式）先合并，主题颜色字典后合并；样式内一律 `{DynamicResource}` 挂色。
- 换装＝按合并索引**原位替换**整本字典（`Resources.MergedDictionaries[index] = new ResourceDictionary { Source = … }`），不重开窗口、不重刷区块；多窗共用一份窗口级/应用级资源＋统一换装入口。
- 主题来源三层：预览覆盖＞用户强制＞跟随系统（系统亮暗读系统偏好，读不到回退浅色）；恢复即移除覆盖。
- 共享画刷一律 `po:Freeze="True"`（冻结单实例，虚拟化列表不逐元素实例化）。
- 代码构建的行：`SetResourceReference`（动态引用），禁止 `FindResource/TryFindResource` 快照（反例 A15）。

## 三、陷阱库（每条都真实付过学费）

**T1 Effect 与 ClearType**：`Effect` 把整个子树渲染进中间位图并关闭亚像素文字渲染——小字号文本发糊。Effect（阴影）只放不含文字的独立层；共享冻结单实例，逐元素实例化拖垮虚拟化列表。

**T2 禁用元素不可命中**：`IsEnabled=false` 的元素不参与命中测试，点击**穿透**到下层（曾把点击穿透成误改选中的手势）。守卫用「入口守卫＋按钮恒启用＋点击无效反馈」实现；置灰只管视觉（两档 token），可见性操作走矩阵隐藏。

**T3 Freeze 与动画**：冻结的 Freezable 不可承载动画——模板内联的变换/画刷在密封期被冻结，动画赋值静默失效。需要动画的变换实例由代码创建后赋给元素。

**T4 namescope 唯一性**：`x:Name` 注册在窗口级 namescope，同窗重复名抛异常。多页内容直书叠放（不用 DataTemplate 实例化）让全部命名元素常驻同一 namescope，按名寻址/辅助功能永远可达（页切换只翻 Visibility）；代价是「共享滚动视口唯一实例」成为必然形态。

**T5 MINMAXINFO 封送**：无边框窗口限制尺寸必须处理 `WM_GETMINMAXINFO`。封送结构体必须与 Win32 **40 字节严格同构**（5×POINT×8 字节）——用 `short` 只写前 20 字节，`ptMinTrackSize/ptMaxTrackSize` 从未写入且 `handled=true` 顶掉 WPF 自填，程序化路径全绿而消息路径完全失守（「测试全绿、实机失效」）。另注意 `ptMaxPosition = 工作区原点 − 显示器原点`；尺寸按窗口 DPI 写 32 位；非有限输入回退 WPF 默认。

**T6 小字像素对齐**：默认 Ideal 布局在 ≤14px 与 150% 缩放下发虚。小字按**字号逐个点名**设 `TextRenderingMode="ClearType"`＋`TextFormattingMode="Display"`（点名 14/12/9）；16px 标题保持 Ideal（Display 反而牺牲字形质量）；中间字号是登记的暂缓项。

**T7 显式绑定不自动推回**：`UpdateSourceTrigger=Explicit` 键入后不经显式 `UpdateSource()`，提交时读模型仍是旧值（1.49.1「改名键入断链」）。显式提交型编辑器必须在提交路径统一推回；更稳的做法是提交时直接读编辑器即时文本（共享改名会话协调器先例）。

**T8 合成事件 ≠ 真实输入**：`RaiseEvent`/UIA 模拟可达而真实鼠标不可达是缺陷——WPF 输入管线与列表默认处理会吞按钮命中。关键指针路径用 Win32 消息直驱验证；「实测」优先于「合成断言」。合成隧道事件另有直接路由陷阱：Direct 路由事件 `RaiseEvent` 只触达命中元素自身——测试须合成冒泡/隧道版本事件。

**T9 位移动画按数值方向选曲线**：「`to<from` 出场加速」是**透明度语义**判据；位移抬升（Y 0→−1）数值变小、命中加速曲线——与「进入态减速」相反（实测教训，已修）。一律按**语义**选曲线（`to == 抬升值 ? EnterEasing : ExitEasing`）；缓动消费走单点工厂，禁散布曲线实例（关联反例 A22）。

**T10 动画登场基线与 FillBehavior.Stop**：`FillBehavior.Stop` 结束后属性回落基线值——动画从 0 淡入到 1 时若基线停在 0，播完整体回落隐形（把手登场淡入曾踩）。登场动画基线必须落终值（先 `SetValue(prop, 终值)` 再从 0 起播），并补「登场后 ≈终值」回归锁。

**T11 输入法组合守卫＋系统双击窗**：①文本编辑器内，全局快捷键语义（如 Esc 宿主语义）在输入法组合未结束期间必须先交给编辑器收尾，不得被全局处理器消费——否则组合被劫持丢字（守卫模式＝组合期挂起全局语义、组合结束恢复；1.72.0 六处缺口统一补齐先例）；②「双击打开」判定用系统双击时间阈值与尺寸容差（系统 API 读取），不自定时时——否则与系统设置/外设节奏不一致。

## 四、镜像锁定测试断言面

```csharp
// 数值面（STA 测试；画刷/圆角/Thickness/时长/几何/字体六类断言）
[Fact] public void BrushResources_MirrorCoreTokens()          // 画刷键逐键 == 常量
    => Assert.Equal(DesignTokens.CardHex, ReadResourceColor("CardBrush"));
[Fact] public void CornerRadiusResources_MirrorCoreTokens()   // 圆角资源＋别名（徽章==头部钮）
[Fact] public void CardFamilyThicknessResources_MirrorTokens() // 卡片族 Thickness 三资源
[Fact] public void AnimationDurations_AreSourcedFromTokens()  // 场景时长==档位别名
[Fact] public void TileGeometryResources_MirrorTokens()       // 瓦片几何/列宽镜像
[Fact] public void DefaultFontIsMirroredByResource()          // 字体串＋推导行高互锁
[Fact] public void ThemeDictionaries_ShareIdenticalKeySets()  // 双字典键集合逐键相等＋计数

// 交互状态面（独立断言面，不与镜像混写）
[Fact] public void LiftAnimationChoosesEasingBySemantics()      // 缓动按语义＋单点实例同一性
[Fact] public void DisabledOpacityConsolidatesToTwoTiers()      // 禁用两档实例化求值
[Fact] public void HoverAndPressedFollowSharedParadigms()       // hover 双轨/pressed 范式结构锁
```

断言面三原则：镜像测试锁「数值同源」；状态测试锁「范式结构」（触发器存在性/档位实例化求值）；行为语义归契约/集成测试。改任一数值源值→测试红、改回绿；新增键未同步镜像→计数断言红。

## 五、动效基建三部件（可粘贴机制骨架）

**① 淡入淡出原语（分层交叉淡入＋可中断四步）**：

```csharp
internal static DoubleAnimation CreateOpacityAnimation(double from, double to, int durationMs) =>
    new(from, to, TimeSpan.FromMilliseconds(durationMs))
    {
        EasingFunction = to < from ? ExitEasing : EnterEasing,  // 透明度语义可用数值判据（T9 边界）
        FillBehavior = FillBehavior.Stop,                       // 播完回落基线（基线已落终值）
    };
// 状态切换四步：1 清运行中动画 → 2 属性写终值 → 3 减动效立即定格返回 → 4 挂新动画
//   （SnapshotAndReplace）＋完成回调代数防掉队（重验代数与目标态才塌缩可见性）
```

**② 三次贝塞尔缓动（控制点串→缓动函数）**：控制点串进常量层，缓动实例从串构造（数值与机制同源）。实现＝对 x(u) 单调的三次贝塞尔做二分求参（24 次二分足够）再取 y；WPF 4+ 原生 `SplineEase`（ControlPoint1/2）或 Storyboard `KeySpline` 可直接承载同样数值——二选一，全项目统一，唯一实例化点。

**③ 渲染位移抬升（悬停上浮）**：

```csharp
internal static DoubleAnimation CreateLiftAnimation(double from, double to) =>
    new(from, to, TimeSpan.FromMilliseconds(DesignTokens.HoverFeedbackMs))
    {
        // 按语义不按数值方向：目的地=抬升态→减速；回落→加速（to 为负，数值判据会错配）
        EasingFunction = to == DesignTokens.CardHoverLiftPx ? EnterEasing : ExitEasing,
        FillBehavior = FillBehavior.Stop,
    };
// 作用在 RenderTransform（TranslateTransform.Y）——不参与布局、不影响命中测试
```

## 六、平台要点（材质壳/字体槽位）

- **系统材质壳**：主窗可设系统背景材质＋圆角偏好（各设一次）；前景画刷用半透明壳色 tint 键；**不透明兜底键**双用途（材质不可用回退态＋无材质截图基准）。对话框一律不用材质。
- **字体链与槽位**：界面字体链常量化＋全部动态引用一个键；行高按字体度量推导（收结果值注释公式）；用户字体覆盖走窗口级槽位（清单校验）；代码/图标字体槽位独立，不随用户字体变化。

## 七、验收自查

- ☐ token 两通道（直引＋镜像）落位；常量类外零散字面量；镜像锁定测试（数值六面＋键位计数）在跑。
- ☐ 样式层与颜色字典分离；换装＝整本替换；代码构建行动态引用零快照。
- ☐ 陷阱 T1–T11 逐条对照过实现。
- ☐ 动效三部件机制齐（可中断/基线落终值/代数防掉队/减动效定格）；缓动单点实例。
- ☐ 系统材质有不透明兜底；对话框不透明单壳；关键指针路径经真实输入验证。
