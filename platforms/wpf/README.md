# platforms/wpf——WPF 主题字典镜像

> 两本可 Merge 的 `ResourceDictionary`（浅色/深色各一），由 `tokens/` DTCG 数值投影而来，
> 与源项目（fts 基线 bba9b4e，v1.72.0）现行键名一致。`scripts/validate-tokens.ps1` 对账锁互锁。

## 文件

- `DesignTheme.Light.xaml` / `DesignTheme.Dark.xaml`：各 39 键＝21 画刷＋1 卡片阴影（主题相关，两本异值）
  ＋17 主题不变资源（圆角/厚度/字体/行高/列宽，两本同值）。共享画刷已 `po:Freeze`。

## 用法

1. **合并到窗口级 MergedDictionaries**：在窗口（或 App）`Resources.MergedDictionaries` 中按主题合并其中一本：

   ```xml
   <Window.Resources>
     <ResourceDictionary>
       <ResourceDictionary.MergedDictionaries>
         <ResourceDictionary Source="pack://application:,,,/YourAssembly;component/Themes/DesignTheme.Light.xaml" />
       </ResourceDictionary.MergedDictionaries>
     </ResourceDictionary>
   </Window.Resources>
   ```

2. **引用一律 `DynamicResource`**：`Background="{DynamicResource CardBrush}"`、
   `CornerRadius="{DynamicResource CardCornerRadius}"`——动态引用是整本替换即时生效的前提。

3. **双主题整本替换**：运行时切换主题＝在窗口资源集合中用另一本字典整体替换这一本
   （同键位两套值），全部 `DynamicResource` 消费者即时换肤。推荐源项目的管理器模式：
   一个 `DesignThemeManager` 单例持有当前主题名（light/dark），切换时对每个已注册窗口
   执行「移除旧字典→合并新字典」，并把主题名持久化到用户偏好，启动时按持久值初始化；
   窗口注册在其构造/加载时完成。字典内不放任何控件样式——纯值资源，样式留在各窗口/样式字典。

## 约定

- 阴影不透明度不折叠进颜色：`CardShadowEffect` 的 `Opacity` 属性即 `color.*.shadow-opacity`。
- `CardRootBoundaryMargin` 上距 10 为源项目登记字面量（置顶分隔节奏），随 Thickness 整体照抄，不拆 token。
- 键名/数值改动须先改 `tokens/`（唯一上游）再重新投影，脚本对账不通过即禁止提交。
