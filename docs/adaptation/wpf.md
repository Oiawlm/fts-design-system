# wpf：WPF/桌面栈落地指南

> **一句话定位**：[adoption-workflow.md](adoption-workflow.md) 步 2/3/5 在 WPF 栈的投影——可粘贴改造的最小骨架三件（token 常量层＋双主题字典＋单源镜像锁定测试）与动效基建移植清单，另有系统材质壳/字体槽位/输入守卫等平台要点（§五）。
> **来源**：skill「fts-style-system」references/wpf-implementation.md（直系前身）＋fts 源码取证（锚点总表见 §七）；键名与 `platforms/wpf/` 镜像一致（映射权威 TOKEN-MAP-V1）。Web 栈对应投影见 [web.md](web.md)。
> **日期**：2026-11-11　**行数预算**：≤420 行

## 一、管线总览

token 从数值源到 UI 有两条通道，镜像锁定测试兜底：

```text
数值源（token 常量类；词汇表对照 tokens/*.tokens.json）
   ├─ 直引通道：时长/几何/不透明度 → XAML {x:Static}（编译期绑定，不随主题变）
   └─ 镜像通道：颜色/圆角/边距/字体 → 主题字典与样式资源键（运行期整本替换支持换主题）
                    ↑ 单源镜像锁定测试：断言 资源值 == 数值源
```

- 本仓参照物：`tokens/*.tokens.json`＝词汇表；`platforms/wpf/DesignTheme.Light|Dark.xaml`＝双字典镜像（每本 39 键＝21 Brush＋1 Effect＋17 主题不变键）；`scripts/validate-tokens.ps1`＝仓级对账。
- 下文骨架为「新项目最小可运行子集」：数值全部是示例值（括注 token 路径），键名与 `platforms/wpf/` 一致以便对照。

## 二、token 层最小骨架

### 2.1 常量类（数值唯一源）

```csharp
using System.Windows.Media;

namespace YourApp.Design;

/// <summary>设计 token 唯一数值源。资源字典与测试引用这些值。
/// 数值为示例值（来源路径见各注释）；全量词汇表对照 tokens/*.tokens.json。</summary>
public static class DesignTokens
{
    // ── 动效时长三档（motion.duration.*）──
    public const int FastDurationMs = 83;      // motion.duration.fast
    public const int NormalDurationMs = 167;   // motion.duration.normal
    public const int SlowDurationMs = 250;     // motion.duration.slow

    // ── 场景时长＝档位别名（const 引 const，编译期锁等值）──
    public const int HoverFeedbackMs = NormalDurationMs;  // motion.duration.hover-feedback
    public const int PressFeedbackMs = FastDurationMs;    // motion.duration.press-feedback
    public const int FadeVisibilityMs = 120;              // motion.duration.fade-visibility

    // ── 缓动两条（motion.easing.*，三次贝塞尔控制点串）──
    public const string EnterEasingKeySpline = "0,0,0,1";  // 进入态减速
    public const string ExitEasingKeySpline = "1,0,1,1";   // 离开态加速

    // ── 圆角（dimension.radius.*；同值不同名不合并）──
    public const double ControlCornerRadiusPx = 4;  // 控件档
    public const double SurfaceCornerRadiusPx = 8;  // 表面档
    public const double ShellCornerRadius = 8;      // 主壳（独立身份 token）

    // ── 间距/位移（dimension.spacing.* / dimension.offset.*）──
    public const double CardInsetPx = 12;     // dimension.spacing.card-inset
    public const double CardGutterPx = 4;     // dimension.spacing.card-gutter
    public const double CardPaddingPx = 12;   // dimension.spacing.card-padding
    public const double CardHoverLiftPx = -1; // dimension.offset.card-hover-lift（负值＝上浮）

    // ── 禁用不透明度两档（motion.opacity.*）──
    public const double ControlDisabledOpacity = 0.4;
    public const double CardDisabledOpacity = 0.6;

    // ── 颜色（浅色 #RRGGBB；深色同键位第二套。全量对照 color.light.* / color.dark.*）──
    public const string WindowShellHex = "#F7F8FA";       // color.light.window-shell
    public const string WindowShellDarkHex = "#202021";   // color.dark.window-shell
    public const string CardHex = "#FFFFFF";              // color.light.card
    public const string CardDarkHex = "#2D2D2E";          // color.dark.card
    public const string PrimaryTextHex = "#1D1D1F";       // color.light.text-primary
    public const string PrimaryTextDarkHex = "#FFFFFF";   // color.dark.text-primary
    public const string AccentHex = "#6D5DFB";            // color.light.accent
    public const string AccentDarkHex = "#9C8CFF";        // color.dark.accent
    public const string BorderHex = "#E2E5EA";            // color.light.border
    public const string BorderDarkHex = "#414143";        // color.dark.border
    public const string HoverSurfaceHex = "#F4F5F7";      // color.light.hover-surface
    public const string HoverSurfaceDarkHex = "#343436";  // color.dark.hover-surface

    // ── 字体（typography.family.ui；行高推导见 §五.2）──
    public const string InterfaceFontFamily = "Microsoft YaHei UI, Microsoft YaHei";

    public static Color ToColor(string hex) => (Color)ColorConverter.ConvertFromString(hex);
}
```

要点：①常量类只持值与别名，场景时长＝档位的 const 引用（编译期锁「锚定不加档」）；②深色同键位第二套常量，命名后缀 Dark；③公式型派生值（行高等）不设别名——收结果值＋注释记公式（DTCG 无公式层）。

### 2.2 双主题字典

`Themes/DesignTheme.Light.xaml`（示例子集；Dark 同键位换值）：

```xml
<ResourceDictionary xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
                    xmlns:po="http://schemas.microsoft.com/winfx/2006/xaml/presentation/options">
  <!-- 主题相关键：两本异值（对照 platforms/wpf/DesignTheme.Light.xaml） -->
  <SolidColorBrush x:Key="WindowShellOpaqueBrush" Color="#F7F8FA" po:Freeze="True" />
  <SolidColorBrush x:Key="CardBrush" Color="#FFFFFF" po:Freeze="True" />
  <SolidColorBrush x:Key="PrimaryTextBrush" Color="#1D1D1F" po:Freeze="True" />
  <SolidColorBrush x:Key="AccentBrush" Color="#6D5DFB" po:Freeze="True" />
  <SolidColorBrush x:Key="BorderBrush" Color="#E2E5EA" po:Freeze="True" />
  <SolidColorBrush x:Key="HoverSurfaceBrush" Color="#F4F5F7" po:Freeze="True" />
  <!-- 主题不变键：两本同值（直引通道者不产键） -->
  <CornerRadius x:Key="ControlCornerRadius">4</CornerRadius>
  <CornerRadius x:Key="SurfaceCornerRadius">8</CornerRadius>
  <CornerRadius x:Key="ShellCornerRadius">8</CornerRadius>
  <CornerRadius x:Key="HeaderActionCornerRadius">7</CornerRadius>
  <CornerRadius x:Key="SelectedCountBadgeCornerRadius">7</CornerRadius> <!-- 别名＝头部操作档 -->
  <Thickness x:Key="CardRootMargin">12,4,12,4</Thickness>
  <Thickness x:Key="CardPadding">12</Thickness>
</ResourceDictionary>
```

- 共享画刷一律 `po:Freeze="True"`：冻结单实例，虚拟化列表不逐元素实例化。
- 键名照 `platforms/wpf/` 镜像约定：画刷键＝语义角色名（CardBrush/PrimaryTextBrush/…），圆角键＝场景名（ControlCornerRadius/SurfaceCornerRadius/…）。
- 样式层（形状/字号/触发器/样式）放独立共享字典，颜色全部 `{DynamicResource}` 挂键，样式里不写字面色。

### 2.3 窗口级合并与整本替换

```xml
<Window …>
  <Window.Resources>
    <ResourceDictionary>
      <ResourceDictionary.MergedDictionaries>
        <ResourceDictionary Source="/YourApp;component/Themes/SharedStyles.xaml" />
        <ResourceDictionary Source="/YourApp;component/Themes/DesignTheme.Light.xaml" />
      </ResourceDictionary.MergedDictionaries>
    </ResourceDictionary>
  </Window.Resources>
</Window>
```

```csharp
using System;
using System.Windows;

public enum DesignTheme { Light, Dark }

public static class DesignThemeManager
{
    /// <summary>整本替换主题字典：按合并索引原位换，不重开窗、不逐键刷新。</summary>
    public static void Apply(Window window, DesignTheme theme)
    {
        var source = new Uri(
            $"/YourApp;component/Themes/DesignTheme.{(theme == DesignTheme.Dark ? "Dark" : "Light")}.xaml",
            UriKind.Relative);
        for (var index = 0; index < window.Resources.MergedDictionaries.Count; index++)
        {
            var original = window.Resources.MergedDictionaries[index].Source?.OriginalString;
            if (original is null ||
                !original.Replace('\\', '/').Contains("DesignTheme.", StringComparison.Ordinal))
            {
                continue;  // 跳过共享样式层等非主题字典
            }

            if (string.Equals(original.Replace('\\', '/'), source.OriginalString, StringComparison.Ordinal))
            {
                return;    // 已是目标主题
            }

            window.Resources.MergedDictionaries[index] = new ResourceDictionary { Source = source };
            return;
        }
    }
}
```

- 合并顺序：共享样式先、主题色字典后（同键后者优先，主题色可覆盖）。
- 主题来源三层：预览覆盖＞用户强制＞跟随系统（系统亮暗读系统偏好，读不到回退浅色）；恢复即移除覆盖。
- 多窗共用一份窗口级/应用级资源＋统一换装入口，避免多窗各持一套字典。

### 2.4 引用纪律：动态引用 vs 快照反例

```csharp
// ✅ 动态引用：主题切换后自动跟随
row.SetResourceReference(Control.BackgroundProperty, "CardBrush");

// ❌ 快照反例：拿到的是当时实例，换主题后停在旧色
row.Background = (Brush)row.FindResource("CardBrush");
```

- XAML 内一律 `{DynamicResource}`（样式与布局两侧）；`{StaticResource}` 只允许用于主题不变键且在锁定测试覆盖内。
- 代码构建的行是重灾区：任何「取资源实例赋属性」都是快照，改 `SetResourceReference`。

## 三、单源镜像锁定测试骨架

STA 单元测试断言「字典键值 == 常量」（MSTest 示例；xUnit 用 StaFact 同构）：

```csharp
using System.Windows;
using System.Windows.Media;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using YourApp.Design;

namespace YourApp.Tests;

[TestClass]
public sealed class DesignTokensMirrorTests
{
    private static ResourceDictionary LoadTheme(string name) =>
        new() { Source = new Uri($"/YourApp;component/Themes/DesignTheme.{name}.xaml", UriKind.Relative) };

    private static void AssertBrush(ResourceDictionary theme, string themeName, string key, string expectedHex) =>
        Assert.AreEqual(
            DesignTokens.ToColor(expectedHex),
            ((SolidColorBrush)theme[key]).Color,
            $"{themeName} 字典 {key} 必须镜像常量 {expectedHex}。");

    [STATestMethod]  // MSTest 3.x；WPF 资源须在 STA 线程访问
    public void DesignTokens_AreMirroredByWpfBrushResources()
    {
        var light = LoadTheme("Light");
        AssertBrush(light, "Light", "CardBrush", DesignTokens.CardHex);
        AssertBrush(light, "Light", "PrimaryTextBrush", DesignTokens.PrimaryTextHex);
        AssertBrush(light, "Light", "AccentBrush", DesignTokens.AccentHex);
        AssertBrush(light, "Light", "BorderBrush", DesignTokens.BorderHex);
        AssertBrush(light, "Light", "HoverSurfaceBrush", DesignTokens.HoverSurfaceHex);

        var dark = LoadTheme("Dark");
        AssertBrush(dark, "Dark", "CardBrush", DesignTokens.CardDarkHex);
        AssertBrush(dark, "Dark", "PrimaryTextBrush", DesignTokens.PrimaryTextDarkHex);
    }

    [STATestMethod]
    public void DesignTokens_AreMirroredByWpfCornerRadiusResources()
    {
        var theme = LoadTheme("Light");
        Assert.AreEqual(new CornerRadius(DesignTokens.ControlCornerRadiusPx),
            (CornerRadius)theme["ControlCornerRadius"], "控件档（dimension.radius.control）。");
        Assert.AreEqual(new CornerRadius(DesignTokens.SurfaceCornerRadiusPx),
            (CornerRadius)theme["SurfaceCornerRadius"], "表面档（dimension.radius.surface）。");
        // 别名锁定：徽章圆角＝头部操作档（dimension.radius.selected-count-badge 为别名）
        Assert.AreEqual((CornerRadius)theme["HeaderActionCornerRadius"],
            (CornerRadius)theme["SelectedCountBadgeCornerRadius"], "徽章必须与头部操作钮同档。");
    }

    [STATestMethod]
    public void ThemeDictionaries_ShareIdenticalKeySets()
    {
        var light = LoadTheme("Light");
        var dark = LoadTheme("Dark");
        Assert.AreEqual(light.Keys.Count, dark.Keys.Count, "双主题必须同键位（键数一致）。");
        foreach (string key in light.Keys)
        {
            Assert.IsTrue(dark.Contains(key), $"Dark 字典缺键 {key}。");
        }
    }
}
```

断言面三原则：

1. 镜像测试锁「数值同源」：资源==常量、别名==目标键、双字典同键位、键数计数（Thickness/字体同法扩断言）。
2. 交互状态另立断言面：档位实例化求值（禁用两档、hover 双轨结构），不与镜像混写。
3. 行为语义归契约/集成测试，不塞进镜像测试。

## 四、动效基建移植要点

移植原则：机制照搬、数值重新推导、不整文件复制（本节代码为节选，完整机制锚点见 §七）。

### 4.1 淡入淡出原语（分层交叉淡入）

```csharp
// 核心：透明度语义——淡出（to<from）用加速曲线，淡入用减速曲线
internal static DoubleAnimation CreateOpacityAnimation(double from, double to, int durationMs) =>
    new(from, to, TimeSpan.FromMilliseconds(durationMs))
    {
        EasingFunction = to < from ? ExitEasing : EnterEasing,  // 单点缓动实例
        FillBehavior = FillBehavior.Stop,                       // 播完回落基线
    };

// 状态切换四步（可中断；节选）
private static void ApplyState(UIElement element, bool isActive, bool animationsEnabled)
{
    var targetOpacity = isActive ? 1d : 0d;
    var current = element.Opacity;
    element.BeginAnimation(UIElement.OpacityProperty, null);    // 1 清运行中动画（可中断）
    element.SetValue(UIElement.OpacityProperty, targetOpacity); // 2 基线落终值（Stop 的前提）
    if (!animationsEnabled)
    {
        return;                                                 // 3 减动效：立即定格，不挂动画
    }

    var animation = CreateOpacityAnimation(current, targetOpacity, GetDurationMs(element));
    // 4 延迟收起须「代数防掉队」：完成回调里重验「本代计数一致＋仍处目标态」才塌缩可见性
    //   （generation 计数器比对；防旧动画 Completed 把新状态误隐藏），然后：
    element.BeginAnimation(UIElement.OpacityProperty, animation, AnimationHandoffBehavior);
}
```

移植清单（淡入淡出原语）：

1. `HandoffBehavior.SnapshotAndReplace`——新动画直接替换运行中动画，不排队。
2. `FillBehavior.Stop`＋基线落终值——登场动画若基线停在 0，播完回落即「播完隐形」。
3. 代数计数防掉队——动画完成回调重验代数与目标态，才执行延迟动作（塌缩/清理）。
4. 减动效开关——关闭时不挂动画、立即定格终值；显隐管理同步退化为直接塌缩/展开。
5. 缓动单点——EnterEasing/ExitEasing 全项目唯一实例化点，散布即反例。

### 4.2 三次贝塞尔缓动（控制点串 → 缓动函数）

```csharp
using System.Globalization;
using System.Windows.Media.Animation;

/// <summary>以三次贝塞尔控制点表达的缓动函数（从 token 串构造，单点实例纪律）。</summary>
internal sealed class SplineEase : IEasingFunction
{
    private readonly double _x1, _y1, _x2, _y2;

    private SplineEase(double x1, double y1, double x2, double y2) =>
        (_x1, _y1, _x2, _y2) = (x1, y1, x2, y2);

    public static SplineEase FromToken(string token)  // "x1,y1,x2,y2"＝DesignTokens 缓动常量
    {
        var p = token.Split(',');
        return new SplineEase(
            double.Parse(p[0], CultureInfo.InvariantCulture),
            double.Parse(p[1], CultureInfo.InvariantCulture),
            double.Parse(p[2], CultureInfo.InvariantCulture),
            double.Parse(p[3], CultureInfo.InvariantCulture));
    }

    public double Ease(double t) =>
        t <= 0 ? 0 : t >= 1 ? 1 : SampleY(SolveParameter(t));

    private double SolveParameter(double x)  // x(u) 单调：24 次二分已足够精确
    {
        var (low, high) = (0d, 1d);
        for (var i = 0; i < 24; i++)
        {
            var mid = (low + high) / 2;
            if (SampleX(mid) < x) { low = mid; } else { high = mid; }
        }
        return (low + high) / 2;
    }

    private double SampleX(double u) =>
        3 * (1 - u) * (1 - u) * u * _x1 + 3 * (1 - u) * u * u * _x2 + u * u * u;

    private double SampleY(double u) =>
        3 * (1 - u) * (1 - u) * u * _y1 + 3 * (1 - u) * u * u * _y2 + u * u * u;
}
```

要点：控制点串进常量层，缓动实例从串构造——数值与机制同源。WPF 4+ 原生 `System.Windows.Media.Animation.SplineEase`（ControlPoint1/2）或 Storyboard 的 `KeySpline` 可直接承载同样数值；自建 FromToken 版的价值＝常量串到实例的单一构造路径。二选一，全项目统一。

### 4.3 渲染位移抬升（悬停上浮）

```csharp
internal static DoubleAnimation CreateLiftAnimation(double from, double to) =>
    new(from, to, TimeSpan.FromMilliseconds(DesignTokens.HoverFeedbackMs))
    {
        // 缓动按语义不按数值方向：目的地=抬升态→减速；回落常态→加速。
        // 位移值为负（如 -1），「to<from」数值判据会把抬升错配加速曲线。
        EasingFunction = to == DesignTokens.CardHoverLiftPx
            ? FadeAnimation.EnterEasing
            : FadeAnimation.ExitEasing,
        FillBehavior = FillBehavior.Stop,
    };
```

要点：①作用在 `RenderTransform`（TranslateTransform.Y）——渲染位移不参与布局、不影响命中测试；②状态切换同款四步（清动画→落终值→挂新动画→代数防掉队）；③抬升量常量化（`dimension.offset.card-hover-lift`），禁散布字面量。

### 4.4 移植清单总表

| 部件 | 必搬机制 | 数值来源（示例） |
|---|---|---|
| 淡入淡出原语 | SnapshotAndReplace／基线落终值／代数防掉队／减动效定格 | durationMs←`motion.duration.fade-visibility` |
| 贝塞尔缓动 | FromToken 构造＋二分求解＋单点实例 | 控制点串←`motion.easing.enter` / `motion.easing.exit` |
| 渲染位移抬升 | RenderTransform＋按语义选曲线 | 时长←`motion.duration.hover-feedback`；幅值←`dimension.offset.card-hover-lift` |

## 五、平台补充要点

### 5.1 系统材质壳（system-material shell）

- 主窗可用系统背景材质（如 Mica）：经系统窗口属性接口各设一次「背景材质类型」与「圆角偏好」；窗口前景画刷用半透明壳色键（`color.material.window-shell-tint`／`WindowShellBrush`，示例值 #CCF7F8FA）。
- 不透明兜底键（`color.surface.window-shell`／`WindowShellOpaqueBrush`）双用途：材质不可用/回退态壳色，与无材质截图/测试基准。
- 对话框一律不用材质：不透明单壳（`color.surface.dialog`／`DialogSurfaceBrush`），圆角阴影交系统渲染；禁「透明背景＋边距挤圆角＋手工阴影」三件套。

### 5.2 字体链与槽位覆盖

- 界面字体链常量化（`typography.family.ui`／`InterfaceFontFamily`），全部窗口/样式动态引用这一个键；行高按字体度量推导（示例：正文行高＝ceil(字号×字体系数＋额外行距)），收结果值并注释公式。
- 用户字体覆盖走槽位：界面槽位＝用户值；代码/图标字体槽位独立，不随用户字体变化（图标字形尺寸也独立于文本字号档）。

### 5.3 输入与窗口消息陷阱（两条）

- **输入法组合守卫**：文本编辑器内，全局快捷键语义（如 Esc 宿主语义）在输入法组合未结束期间必须先交给编辑器收尾，不得被全局处理器消费——否则组合被劫持丢字。守卫模式＝组合期挂起全局语义、组合结束恢复。
- **系统双击窗判定**：判断「双击打开」用系统双击时间阈值与系统双击尺寸容差（系统 API 读取），不自定时常——否则与系统设置/外设节奏不一致。

## 六、验收自查

- ☐ token 两通道（直引＋镜像）落位；常量类外零散字面量；镜像锁定测试（画刷/圆角/同键位/计数）在 CI 跑。
- ☐ 样式层与颜色字典分离；换装＝整本替换；代码构建行动态引用零快照。
- ☐ 动效三部件机制齐（可中断／基线落终值／代数防掉队／减动效定格）；缓动单点实例。
- ☐ 阴影/效果不进文字子树；共享冻结单实例。
- ☐ 显隐走可见性塌缩＋统一显隐管理，不用纯透明度隐藏。
- ☐ 系统材质有不透明兜底；对话框不透明单壳。
- ☐ 关键指针路径经真实输入验证（不止合成事件）。

## 七、fts 溯源

| 本文元素 | fts 锚点（基线 bba9b4e，1.72.0） |
|---|---|
| §一管线与 §二.1 常量类结构 | `src/FloatingTransferStation.Core/Design/DesignTokens.cs`（112 常量；三档 :56-58；缓动 :140-141；场景别名＝const 引 const） |
| §二.2 字典键名与冻结 | `Resources/DesignTheme.Light|Dark.xaml`（各 22 x:Key；共享画刷 po:Freeze）；本仓镜像 `platforms/wpf/`（39 键/本，TOKEN-MAP §二.3） |
| §二.3 整本替换／三层来源／系统探测 | `Services/DesignThemeManager.cs:24-52`（合并索引原位替换）、:54-75（系统亮暗偏好，读不到回退浅色） |
| §二.4 快照反例 | skill 反例库 A15（代码构建行快照画刷） |
| §三 锁定测试 | `tests/FloatingTransferStation.Tests/MainWindowInteractionTests.DesignTokens.cs:13-92`（STA 画刷/圆角断言）、:79-82（徽章别名断言）；交互状态断言面＝同目录 ButtonStates 测试 |
| §四.1 原语 | `Views/FadeAnimation.cs:15`（SnapshotAndReplace）、:95-100（构造）、:99（FillBehavior.Stop）、:124-170（状态切换四步＋代数防掉队） |
| §四.2 贝塞尔 | `Views/FadeAnimation.cs:183-252`（SplineEase：FromToken＋24 次二分求解） |
| §四.3 抬升 | `Views/LiftAnimation.cs:14-17`（时长/幅值常量化）、:43-51（按语义选缓动，「to<from」缺陷修复注记 :46-48）、:75-93（渲染位移） |
| §五.1 材质壳 | `Services/DwmWindowEffects.cs:11-32`（材质属性与回退）；对话框不用材质＝`DesignTheme.Light.xaml:6-8` 注释（Issue #186 D8 修订） |
| §五.2 字体槽位 | `Views/InterfaceFontManager.cs:21-116`（槽位解析与清单校验）；行高推导＝`Resources/MainWindowStyles.xaml:36` 注释 |
| §五.3 守卫/双击窗 | `Views/ImeCompositionGuard.cs`（契约 #63，commit 0d3ae51）；`Views/DoubleClickWindow.cs:9-34`（GetDoubleClickTime＋SM_CX/CYDOUBLECLK 容差） |
| 陷阱库全集 | skill references/wpf-implementation.md T1–T10（本文只收 E6 任务面新增的输入守卫与双击窗两条） |
