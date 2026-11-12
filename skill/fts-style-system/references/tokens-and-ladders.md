# tokens-and-ladders：语义 token 体系与档位表

> **定位**：新项目第 2 步「建 token 层」的照搬蓝本——DTCG 语义键分组、双主题同键位、各类档位表与判定规则、收/不收判据；数值全部为**示例值**（括注 token 路径），权威快照在源仓 `tokens/*.tokens.json`（152 token）。
> **来源**：源仓 docs/foundations/ 四篇（color/typography/shape-and-spacing/elevation-and-material）提炼；fts 基线 1.72.0（commit `bba9b4e`）。fts 锚点见 [fts-provenance.md](fts-provenance.md)。
> **日期与行数预算**：2026-11-12 重建；≤400 行（现 146 行）。按需精读，不必先读。

## 一、语义键分组与命名法

键名按**用途/角色**命名，不按外观命名（反例：`gray-700`、`blue-500`——换主题即失义）。DTCG 分组（token 路径前缀）与示例键：

| 分组 | 示例键 | 用途 |
|---|---|---|
| color.surface.* | window-shell / tab-rail / card / header / status / dialog | 窗壳、导航轨、卡片与输入框底、头部、状态浮层、对话框壳 |
| color.material.* | window-shell-tint | 系统材质壳的半透明色调（约 80% alpha） |
| color.border.* | default / hover | 通用描边、悬停描边（密集控件只换边） |
| color.text.* | primary / secondary / on-accent | 主文字；次文字（兼任次级图标前景与灰态环）；强调色上的前景 |
| color.accent.default | — | 只承担「选中/活动/焦点/置顶指示/拖放插入/链接/成功反馈」，**禁止作装饰底色** |
| color.danger.default | — | 只承担破坏性语义（清空/删除/退出/失败） |
| color.interaction.* | hover-surface / selected-card-surface / selected-card-border / active-category / drop-target | 悬停表面、选中底、选中描边、活动层（活动导航＋按下态）、拖放落点层 |
| color.scrollbar.* | thumb / thumb-hover | 滚动条滑块与悬停 |
| color.shadow.* | card / card-opacity | 阴影对象与不透明度（色与不透明度分列，不折叠 alpha） |
| dimension.radius.* | control / surface / card / shell / header-action / pin-button / selection-ring | 圆角档位与登记册（§三） |
| dimension.spacing.* | card-inset / card-gutter / card-padding / reading-block-gap … | 结构性间距（§四） |
| dimension.offset.* | content-entrance / collapse-exit / card-hover-lift / tile-hover-lift | 动效位移（不是布局间距） |
| dimension.tile.* / size.* | width / height / gutter / pitch / min-columns … | 组件几何族与结构小件 |
| motion.duration.* / easing.* / opacity.* / scale.* | fast / normal / slow；enter / exit；control-disabled / card-disabled；tile-press | 动效档位（详见 [motion.md](motion.md)） |
| typography.* | size.* / family.ui / family.code / line-height.body / weight.emphasis | 排版档位（§五） |

要点：
- **语义分工三原则**：中性面只走灰阶（表面层级靠明度由浅入深，不靠色相）；强调色只承担指示语义；危险色只承担破坏性语义。
- **双层结构**：primitive 层持原始值（浅/深各一组 `color.light.*`/`color.dark.*`），semantic 层按用途命名、值指向 primitive；UI 只消费语义层。深色解析＝别名路径 light→dark 替换（机器可校验）。
- **同值不同名不合并**：两键当前值相同但语义身份不同（如强调色前景与卡片底色恰同白），保持独立键位——合并即冻结耦合。
- **交互状态色是独立键**：禁止用临时透明度叠加拼凑交互态（半透明黑罩＝幽灵色，深浅主题下不可控）。
- **文案反馈色约定**：成功＝强调色、失败＝危险色、中性提示＝次级文字色——三键复用，不为反馈场景新造颜色。
- **配色豁免清单机制**：主题不变量与材质层不入主题键但必须成文登记（示例：扫码面恒白〔可扫性是物理约束〕、材质层 tint、独立工具底色、结构性透明）；豁免是登记制不是自由区。

## 二、双主题与换装

- 两本主题字典（Light/Dark）**同键位**（键集合逐键相等），由主题管理器**整本替换**（按合并索引原位换字典，不重开窗口）；共享样式层（形状/字号/触发器）独立于颜色字典，不复制两份。
- 主题来源优先级：预览覆盖＞用户强制＞跟随系统；强制模式不响应系统亮暗广播；恢复即移除覆盖。
- 深色不是「反色」：强调色提亮一档保对比（示例 `#6D5DFB`→`#9C8CFF`）、危险色降饱和提亮、表面压暗留阶（示例壳 `#202021`→卡 `#2D2D2E`），阴影加深（不透明度浅 0.12→深 0.35）。
- **动态引用纪律**：代码构建的 UI 一律活解析引用（桌面端 `SetResourceReference`/动态资源语义，Web 端 CSS 变量），禁止查找后快照持有——主题切换后停旧色是典型缺陷（反例 A15）。

## 三、圆角（两档阶梯＋判定规则＋登记册）

**判定规则按元素类型二分**——「这个元素是**手**（动作）还是**托盘**（承载）」：输入/动作类控件＝控件档；承载内容的表面＝表面档；不按视觉大小调。

| 档 | 示例值 | 用途 | token 路径 |
|---|---|---|---|
| 控件档 | 4 | 输入框、按钮、下拉、行内编辑器、菜单行、类型 chip、名称带 | dimension.radius.control |
| 表面档 | 8 | 卡片、瓦片、弹窗壳、主壳（系统裁剪与内容自裁剪同值）、标签容器、放大层 | dimension.radius.surface（card/shell 为独立身份同值键） |

登记册（识别元素保留原值、逐个登记、不入阶梯；同样以资源引用消费）：

| 键 | 示例值 | 用途 |
|---|---|---|
| header-action | 7 | 头部操作钮；选中计数徽章为同值别名（selected-count-badge） |
| pin-button | 6 | 置顶钮、卡片图标钮族、瓦片右键菜单行 |
| selection-ring | 5 | 选择环——卡/瓦片勾选钮、选择器、类型 chip 共用 |

**派生三族规则**（成文不入档，结果值不是档位例外）：胶囊/圆形＝高的一半（开关轨道/滑钮、圆角标）；线状件＝宽的一半（滑块悬停层、导航指示条、停靠把手竖条 1.5、分隔线 0.5）；内层＝外层−描边（卡片填充层 8−1=7）。小件家族同值点名登记：chip 容器族「6 容器＋5 激活层」配对，不复用他族 token（值同也不共用——语义族不相属）。**零引用的废弃 token 及时删除**。

## 四、间距与位移（收/不收判据）

**收（token 化）**：结构性常量——同一数值在多个结构场景重复且语义同质：

| 键 | 示例值 | token 路径 |
|---|---|---|
| 表面水平内缩 | 12 | dimension.spacing.card-inset |
| 表面纵向沟槽 | 4 | dimension.spacing.card-gutter |
| 表面内边距 | 12 | dimension.spacing.card-padding |
| 瓦片视口上下内衬 | 8 | dimension.spacing.launcher-viewport-inset（吸收渲染变换溢出，护首/末行圆角） |
| 操作列宽 | 30 | dimension.size.card-operation-column |
| 正文排他内缩 | 64＝2×30＋4 | dimension.spacing.card-text-reserved-right（**派生公式唯一来源**，不得写死第二份） |
| 阅读块距/代码内边距/引用条宽 | 6 / 8 / 3 | dimension.spacing.reading-* |

**不收（约定成文）**：语义异质的常规 margin（元素横向间距 8、标题缩进 24）——强行 token 化造成键位爆炸负收益，写进节奏表即可。

- **位移与间距分立**：入场位移 6（content-entrance）、瓦片入场位移 8（tile-entrance）、出场位移 24（collapse-exit）、卡片悬停抬升 −1 / 瓦片 −2（对仗、各自成键）是**动效位移**——渲染位移承载（不参与布局、不影响命中），不混入布局间距。
- **结构性尺寸不是设计 token**：窗宽、轨道宽、面板宽、设置窗几何、子分组轨高 36 等属结构层常量（信息架构），与设计 token（视觉语言）分仓；**结构不为内容让步**（不为长内容加宽结构）。

## 五、字号与排版（7 基础档＋3 阅读档）

| 档 | 示例值 | 用途 | token 路径 |
|---|---|---|---|
| 徽标 | 9 | 徽标计数（像素对齐） | typography.size.badge |
| 辅助 | 11 | 辅助说明、瓦片名、选择器副题 | typography.size.caption |
| 次级 | 12 | 状态文本、备注、菜单行、提示行（像素对齐） | typography.size.secondary |
| 界面 | 13 | 设置行、导航、下拉、搜索 chip | typography.size.ui |
| 正文 | 14 | 卡片正文（显示/编辑两态同源；像素对齐） | typography.size.body |
| 标题 | 16 | 窗标题、设置窗标题 | typography.size.title |
| 阅读 H1–H3 | 20 / 17 / 15 | 阅读视图三级标题 | typography.size.reading-h1/2/3 |

- **H4–H6＝正文字号＋强调权重**，不设第二份正文字号（防档位膨胀）。
- **行高由字体度量推导**：`行高 = ceil(字号 × 链首字体 LineSpacing ＋ 额外行距)`（示例正文 19＝ceil(14×1.27＋1)，typography.line-height.body）；行数上限随行高等比派生（预览高＝行高×上限），换字体自动放大，不手拍第二份。
- **字重单档**：全项目仅一档强调权重（SemiBold 600，typography.weight.emphasis）——标题/激活态/选中段；无 Bold、无 Light；层级靠字号与次级文字色。
- **字体族链**：界面字体是链式串「UI 变体优先＋完整版回退」，全项目唯一一份字面量＋镜像互锁；用户换字体走**窗口级槽位覆盖**（族＋行高族四键注入，系统字体清单校验，未知名回落默认）；**独立功能字体不随界面字体变**：图标字体与代码字体各自声明来源（系统必装链＋回退），不随应用分发字体文件。
- **像素对齐点名制**：小字号逐面点名像素对齐渲染（示例点名 14/12/9；16px 保持默认渲染）——按字号逐个登记，不全局一刀切。

## 六、阴影与材质

- **阴影隔离第一法则**：投影永不进入承载文字的子树（特效会把子树渲染进中间位图并关闭亚像素文字渲染——正文发糊主因）；标准解法＝三层结构（根容器无效果／阴影层同形状不透明底＋共享投影、不承载内容不参与命中／内容面禁止携带效果）。
- **共享冻结单一实例**：同类表面共用一枚冻结投影资源，不逐元素实例化（虚拟化列表性能前提）；悬停「抬升」用渲染位移表达，**不实时改投影参数**。
- **双主题阴影参数差异化**：几何参数（偏移/模糊）两主题同值，色与不透明度分档（示例浅 0.12/深 0.35，color.shadow.card-opacity）；海拔克制——一档卡片海拔足够，层级感由表面明度阶承担。
- **系统材质壳（可选）**：主窗可用系统背景材质＋半透明壳色调（color.material.window-shell-tint）＋系统圆角；**材质不可用必须回退不透明壳色**（回退是设计内第一公民路径）。
- **对话框不用材质**：不透明对话框表面（color.surface.dialog）＋系统级圆角与阴影唯一来源；禁止假圆角三件套（透明背景＋margin 挤圆角＋手工阴影）。
- **壳圆角同值自裁剪**：窗壳圆角由系统承载，内容层以同值自裁剪保证渲染一致；不设第二个壳圆角数值。

## 七、可复制骨架（伪代码；WPF 全骨架见 [wpf-implementation.md](wpf-implementation.md)）

```csharp
// 唯一数值源（常量类；词汇表对照 tokens/*.tokens.json）
public static class DesignTokens
{
    public const int FastDurationMs = 83, NormalDurationMs = 167, SlowDurationMs = 250; // 示例值
    public const double ControlCornerRadiusPx = 4, SurfaceCornerRadiusPx = 8;
    public const double ControlDisabledOpacity = 0.4, CardDisabledOpacity = 0.6;
    public const string CardHex = "#FFFFFF", CardDarkHex = "#2D2D2E"; // 双主题同键位两套
    public const int HoverFeedbackMs = NormalDurationMs; // 场景时长＝档位别名（const 引 const，编译期锁等值）
}
```

```xml
<!-- 主题字典（Light/Dark 同键位，整本替换） -->
<SolidColorBrush x:Key="CardBrush" Color="#FFFFFF" po:Freeze="True" />
<DropShadowEffect x:Key="CardShadowEffect" BlurRadius="8" ShadowDepth="2" Direction="270"
                  Opacity="0.12" Color="#1D1D1F" po:Freeze="True" />
<!-- 样式层引用：{DynamicResource CardBrush}；时长/不透明度可直引常量 -->
```

```csharp
// 镜像锁定测试 —— 防副本漂移（断言面详见 wpf-implementation.md §四）
[Fact] public void BrushResources_MirrorCoreTokens() =>
    Assert.Equal(DesignTokens.CardHex, ReadResourceColor("CardBrush"));
```

## 八、验收自查

- ☐ 键名按用途命名；primitive 持值、semantic 别名；深色解析可机器校验。
- ☐ 语义分工三原则成立（中性灰阶/Accent 指示/Danger 破坏）；豁免清单登记在册。
- ☐ 浅/深两本字典键集合逐键相等（计数断言）；代码构建行零快照引用。
- ☐ 圆角两档判定＋登记册＋派生三族成文；第三档即漂移。
- ☐ 间距按「结构性 vs 语义性」判收；避让预留是派生公式唯一来源；结构尺寸与 token 分仓。
- ☐ 字号档位封闭；行高公式推导；字重单档；像素对齐点名登记。
- ☐ 阴影隔离三层结构＋共享冻结；双主题阴影分档；弹窗单壳＋材质回退。
- ☐ 镜像锁定测试在跑，UI 层无第二字面量。
