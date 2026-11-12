# validate-tokens.ps1 —— tokens/（DTCG）↔ platforms/wpf/（XAML）↔ platforms/web/（CSS）三方对账锁
# 用法：powershell -ExecutionPolicy Bypass -File scripts/validate-tokens.ps1
# 退出码：0＝全部一致；1＝任何差异/计数不符/结构缺失。
# 约定口径（唯一，不依赖第三方工具）：
#   - 别名 {a.b.c} 逐跳展开；深色解析＝将别名路径中 `.light.` 替换为 `.dark.`（TOKEN-MAP-V1 §二.2）。
#   - 计数目标来自 TOKEN-MAP-V1 §六（结构目标，非数值硬编码）：DTCG 152（69/29/36/18，别名 32 计入）
#     ↔ XAML 39×2（21 画刷＋1 阴影＋17 主题不变）↔ CSS :root 106（色 primitive 46 不出变量）。
#   - 映射表（XAML 键 ↔ DTCG 路径、Thickness 组合规则）即「锁」的定义：键改名/值漂移未经上游同步即失败。
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$diffs = New-Object System.Collections.Generic.List[string]
function Add-Diff([string]$s) { $script:diffs.Add($s) | Out-Null }

# ---------- 1. 解析 DTCG 四文件并展平 ----------
function Flatten-Group($node, [string]$prefix, $inheritedType, $map) {
    foreach ($p in $node.PSObject.Properties) {
        if ($p.Name.StartsWith('$')) { continue }
        $child = $p.Value
        $path = if ($prefix) { "$prefix.$($p.Name)" } else { $p.Name }
        $names = @($child.PSObject.Properties.Name)
        if ($names -contains '$value') {
            $ttype = $inheritedType
            if ($names -contains '$type') { $ttype = $child.'$type' }
            $map[$path] = @{ Value = $child.'$value'; Type = $ttype }
        } else {
            $gtype = $inheritedType
            if ($names -contains '$type') { $gtype = $child.'$type' }
            Flatten-Group $child $path $gtype $map
        }
    }
}

$groups = @('color', 'dimension', 'motion', 'typography')
$all = @{}          # 路径 -> @{Value;Type}
$perFileCount = @{}
foreach ($group in $groups) {
    $path = Join-Path $root "tokens\$group.tokens.json"
    if (-not (Test-Path $path)) { Add-Diff "缺 DTCG 文件: tokens/$group.tokens.json"; continue }
    $map = @{}
    $json = Get-Content -Raw -Encoding UTF8 $path | ConvertFrom-Json
    Flatten-Group $json '' $null $map
    $perFileCount[$group] = $map.Count
    foreach ($k in $map.Keys) { $all[$k] = $map[$k] }
}

# ---------- 2. 别名解析（浅色/dark 位置替换两条通道）----------
function Resolve-Token([string]$path, [bool]$dark) {
    $visited = @{}
    $cur = $path
    while ($true) {
        if ($visited.ContainsKey($cur)) { throw "别名循环: $cur" }
        $visited[$cur] = $true
        if (-not $script:all.ContainsKey($cur)) { throw "未知 token 路径: $cur" }
        $t = $script:all[$cur]
        if ($t.Value -is [string] -and $t.Value -match '^\{(.+)\}$') {
            $cur = if ($dark) { $Matches[1] -replace '\.light\.', '.dark.' } else { $Matches[1] }
        } else { return $t }
    }
}
$aliasCount = @($all.Keys | Where-Object { $all[$_].Value -is [string] -and $all[$_].Value -match '^\{.+\}$' }).Count

# ---------- 3. 值格式化与归一 ----------
function Format-Num([object]$n) {
    if ($n -is [double] -or $n -is [single]) { return $n.ToString([System.Globalization.CultureInfo]::InvariantCulture) }
    return "$n"
}
function Normalize-Css([string]$s) {
    ($s.Trim() -replace ',\s*', ',') -replace '\s+', ' '
}
function Get-PxNum([string]$s) { [double]($s -replace 'px$', '') }

function Hex-To-Rgb([string]$hex) {
    $h = $hex.TrimStart('#')
    return @([Convert]::ToInt32($h.Substring(0, 2), 16), [Convert]::ToInt32($h.Substring(2, 2), 16), [Convert]::ToInt32($h.Substring(4, 2), 16))
}
# 阴影折叠为 box-shadow 值（TOKEN-MAP §二.4 字面格式「0 2px 8px 0 rgba(...)」：x/spread 当前恒 0 不带单位，
# y/blur 带 px；不透明度由 shadow-*-opacity 提供，不折叠进色值）
function Fold-Shadow($shadowToken, [string]$opacityPath, [bool]$dark) {
    $o = Format-Num (Resolve-Token $opacityPath $dark).Value
    $rgb = Hex-To-Rgb $shadowToken.Value.color
    $xs = Format-Num (Get-PxNum $shadowToken.Value.x)
    $ys = Format-Num (Get-PxNum $shadowToken.Value.y)
    $bs = Format-Num (Get-PxNum $shadowToken.Value.blur)
    $sps = Format-Num (Get-PxNum $shadowToken.Value.spread)
    return "$xs ${ys}px ${bs}px $sps rgba($($rgb[0]),$($rgb[1]),$($rgb[2]),$o)"
}

# CSS 期望值（分支解析后格式化）
function Get-CssExpected([string]$path, [bool]$dark) {
    $t = Resolve-Token $path $dark
    switch ($t.Type) {
        'color'       { return [string]$t.Value }
        'dimension'   { return [string]$t.Value }
        'duration'    { return [string]$t.Value }
        'fontFamily'  { return [string]$t.Value }
        'number'      { return Format-Num $t.Value }
        'fontWeight'  { return Format-Num $t.Value }
        'cubicBezier' { return 'cubic-bezier(' + (($t.Value | ForEach-Object { Format-Num $_ }) -join ',') + ')' }
        'shadow'      {
            if ($path -ne 'color.shadow.card') { throw "未定义折叠规则的 shadow token: $path" }
            return Fold-Shadow $t "$path-opacity" $dark
        }
        default { throw "未知类型 $($t.Type)（$path）" }
    }
}

# ---------- 4. 解析两本 XAML ----------
function Read-XamlDict([string]$path) {
    if (-not (Test-Path $path)) { throw "缺 XAML 文件: $path" }
    $doc = New-Object System.Xml.XmlDocument
    $doc.Load($path)
    $xns = 'http://schemas.microsoft.com/winfx/2006/xaml'
    $dict = @{}
    foreach ($n in $doc.DocumentElement.ChildNodes) {
        if ($n.NodeType -ne 'Element') { continue }
        $key = $n.GetAttribute('Key', $xns)
        if (-not $key) { continue }
        $entry = @{ Kind = $n.LocalName; Text = $n.InnerText.Trim() }
        if ($n.HasAttribute('Color')) { $entry.Color = $n.GetAttribute('Color') }
        if ($n.HasAttribute('Left')) { $entry.L = [double]$n.GetAttribute('Left') }
        if ($n.HasAttribute('Top')) { $entry.T = [double]$n.GetAttribute('Top') }
        if ($n.HasAttribute('Right')) { $entry.R = [double]$n.GetAttribute('Right') }
        if ($n.HasAttribute('Bottom')) { $entry.B = [double]$n.GetAttribute('Bottom') }
        if ($n.HasAttribute('Opacity')) { $entry.Opacity = [double]$n.GetAttribute('Opacity') }
        if ($n.HasAttribute('BlurRadius')) { $entry.Blur = [double]$n.GetAttribute('BlurRadius') }
        if ($n.HasAttribute('ShadowDepth')) { $entry.Depth = [double]$n.GetAttribute('ShadowDepth') }
        if ($n.HasAttribute('Direction')) { $entry.Direction = [double]$n.GetAttribute('Direction') }
        $dict[$key] = $entry
    }
    return $dict
}

# ---------- 5. 锁：XAML 键 ↔ DTCG 路径映射与 Thickness 组合规则 ----------
$brushMap = [ordered]@{
    'WindowShellBrush'          = 'color.material.window-shell-tint'
    'WindowShellOpaqueBrush'    = 'color.surface.window-shell'
    'DialogSurfaceBrush'        = 'color.surface.dialog'
    'TabRailBrush'              = 'color.surface.tab-rail'
    'CardBrush'                 = 'color.surface.card'
    'BorderBrush'               = 'color.border.default'
    'PrimaryTextBrush'          = 'color.text.primary'
    'SecondaryTextBrush'        = 'color.text.secondary'
    'AccentBrush'               = 'color.accent.default'
    'DangerBrush'               = 'color.danger.default'
    'HeaderBrush'               = 'color.surface.header'
    'HoverSurfaceBrush'         = 'color.interaction.hover-surface'
    'HoverBorderBrush'          = 'color.border.hover'
    'SelectedCardBrush'         = 'color.interaction.selected-card-surface'
    'SelectedCardBorderBrush'   = 'color.interaction.selected-card-border'
    'ActiveCategoryBrush'       = 'color.interaction.active-category'
    'DropTargetBrush'           = 'color.interaction.drop-target'
    'ScrollThumbBrush'          = 'color.scrollbar.thumb'
    'ScrollThumbHoverBrush'    = 'color.scrollbar.thumb-hover'
    'StatusSurfaceBrush'        = 'color.surface.status'
    'OnAccentBrush'             = 'color.text.on-accent'
}
$radiusMap = [ordered]@{
    'ControlCornerRadius'            = 'dimension.radius.control'
    'SurfaceCornerRadius'            = 'dimension.radius.surface'
    'CardCornerRadius'               = 'dimension.radius.card'
    'ShellCornerRadius'              = 'dimension.radius.shell'
    'HeaderActionCornerRadius'       = 'dimension.radius.header-action'
    'PinButtonCornerRadius'          = 'dimension.radius.pin-button'
    'SelectionRingCornerRadius'      = 'dimension.radius.selection-ring'
    'SelectedCountBadgeCornerRadius' = 'dimension.radius.selected-count-badge'
}
$simpleMap = [ordered]@{
    'InterfaceFontFamily'      = @{ Path = 'typography.family.ui'; Kind = 'FontFamily' }
    'CardOperationColumnWidth' = @{ Path = 'dimension.size.card-operation-column'; Kind = 'GridLength' }
    'CardTextLineHeight'       = @{ Path = 'typography.line-height.body'; Kind = 'Double' }
    'CardTextPreviewMaxHeight' = @{ Path = 'typography.clamp.body-preview-height'; Kind = 'Double' }
    'CardNoteMaxHeight'        = @{ Path = 'typography.clamp.note-preview-height'; Kind = 'Double' }
}
# Thickness 组合规则（元素=token 路径或字面量数值；CardRootBoundaryMargin 上距 10＝源项目登记字面量，TOKEN-MAP §五）
$thicknessMap = [ordered]@{
    'CardPadding'                = @{ L = 'dimension.spacing.card-padding'; T = 'dimension.spacing.card-padding'; R = 'dimension.spacing.card-padding'; B = 'dimension.spacing.card-padding' }
    'CardRootMargin'             = @{ L = 'dimension.spacing.card-inset';   T = 'dimension.spacing.card-gutter';  R = 'dimension.spacing.card-inset';  B = 'dimension.spacing.card-gutter' }
    'CardRootBoundaryMargin'     = @{ L = 'dimension.spacing.card-inset';   T = '10';                              R = 'dimension.spacing.card-inset';  B = 'dimension.spacing.card-gutter' }
    'CardTextReservedRightInset' = @{ L = '0';                              T = '0';                               R = 'dimension.spacing.card-text-reserved-right'; B = '0' }
}
$expectedXamlKeys = @($brushMap.Keys) + @('CardShadowEffect') + @($radiusMap.Keys) + @($simpleMap.Keys) + @($thicknessMap.Keys)

function Get-TokenNum([string]$pathOrLiteral, [bool]$dark) {
    if ($pathOrLiteral -match '^\d+(\.\d+)?$') { return [double]$pathOrLiteral }
    $t = Resolve-Token $pathOrLiteral $dark
    if ($t.Value -is [string]) { return Get-PxNum $t.Value }
    return [double](Format-Num $t.Value)
}

function Compare-XamlDict($dict, [bool]$dark, [string]$name) {
    if ($dict.Count -ne 39) { Add-Diff "[$name] 键数 $($dict.Count) ≠ 39" }
    $expected = $expectedXamlKeys | Sort-Object
    $actual = $dict.Keys | Sort-Object
    $drift = Compare-Object $expected $actual
    if ($drift) { Add-Diff "[$name] 键集与映射表不符: $(($drift | ForEach-Object { '{0}({1})' -f $_.InputObject, $_.SideIndicator }) -join ' ')" }
    foreach ($k in $brushMap.Keys) {
        if (-not $dict.Contains($k)) { continue }
        $want = ([string](Resolve-Token $brushMap[$k] $dark).Value).ToUpperInvariant()
        $got = $dict[$k].Color.ToUpperInvariant()
        if ($want -ne $got) { Add-Diff "[$name] ${k}: 期望 $want 实得 $got（↔ $($brushMap[$k])）" }
    }
    # 阴影：对象参数与不透明度分列比对（Direction 270°→y+2、spread 无 WPF 对应恒 0＝结构常量）
    if ($dict.Contains('CardShadowEffect')) {
        $sh = (Resolve-Token 'color.shadow.card' $dark).Value
        $op = [double](Format-Num (Resolve-Token 'color.shadow.card-opacity' $dark).Value)
        $e = $dict['CardShadowEffect']
        if ($e.Blur -ne (Get-PxNum $sh.blur)) { Add-Diff "[$name] CardShadowEffect.BlurRadius $($e.Blur) ≠ $($sh.blur)" }
        if ($e.Depth -ne (Get-PxNum $sh.y)) { Add-Diff "[$name] CardShadowEffect.ShadowDepth $($e.Depth) ≠ $($sh.y)" }
        if ($e.Direction -ne 270) { Add-Diff "[$name] CardShadowEffect.Direction $($e.Direction) ≠ 270（结构常量）" }
        if ($e.Color.ToUpperInvariant() -ne ([string]$sh.color).ToUpperInvariant()) { Add-Diff "[$name] CardShadowEffect.Color $($e.Color) ≠ $($sh.color)" }
        if ([math]::Abs($e.Opacity - $op) -gt 0.0001) { Add-Diff "[$name] CardShadowEffect.Opacity $($e.Opacity) ≠ $op" }
    }
    foreach ($k in $radiusMap.Keys) {
        if (-not $dict.Contains($k)) { continue }
        $want = Get-TokenNum $radiusMap[$k] $dark
        if ([double]$dict[$k].Text -ne $want) { Add-Diff "[$name] ${k}: 期望 $want 实得 $($dict[$k].Text)（↔ $($radiusMap[$k])）" }
    }
    foreach ($k in $simpleMap.Keys) {
        if (-not $dict.Contains($k)) { continue }
        $m = $simpleMap[$k]
        if ($dict[$k].Kind -ne $m.Kind) { Add-Diff "[$name] ${k} 类型 $($dict[$k].Kind) ≠ $($m.Kind)" }
        $t = Resolve-Token $m.Path $dark
        if ($m.Kind -eq 'FontFamily') {
            if ((Normalize-Css $dict[$k].Text) -ne (Normalize-Css ([string]$t.Value))) { Add-Diff "[$name] ${k}: 期望 $($t.Value) 实得 $($dict[$k].Text)" }
        } else {
            $wantNum = if ($t.Value -is [string]) { Get-PxNum $t.Value } else { [double](Format-Num $t.Value) }
            if ([double]$dict[$k].Text -ne $wantNum) { Add-Diff "[$name] ${k}: 期望 $($t.Value) 实得 $($dict[$k].Text)（↔ $($m.Path)）" }
        }
    }
    foreach ($k in $thicknessMap.Keys) {
        if (-not $dict.Contains($k)) { continue }
        $r = $thicknessMap[$k]
        foreach ($side in 'L', 'T', 'R', 'B') {
            $want = Get-TokenNum $r[$side] $dark
            if ([math]::Abs([double]$dict[$k][$side] - $want) -gt 0.0001) { Add-Diff "[$name] ${k}.$($side) : 期望 $want 实得 $($dict[$k][$side])（↔ $($r[$side])）" }
        }
    }
}

$light = Read-XamlDict (Join-Path $root 'platforms\wpf\DesignTheme.Light.xaml')
$darkDict = Read-XamlDict (Join-Path $root 'platforms\wpf\DesignTheme.Dark.xaml')
Compare-XamlDict $light $false 'XAML.Light'
Compare-XamlDict $darkDict $true 'XAML.Dark'
# 主题不变 17 键两本必须同值
foreach ($k in (@($radiusMap.Keys) + @($simpleMap.Keys) + @($thicknessMap.Keys))) {
    $a = $light[$k]; $b = $darkDict[$k]
    $av = if ($a.ContainsKey('Text')) { $a.Text } else { '' }
    $bv = if ($b.ContainsKey('Text')) { $b.Text } else { '' }
    $same = ($av -eq $bv) -and ($a.L -eq $b.L) -and ($a.T -eq $b.T) -and ($a.R -eq $b.R) -and ($a.B -eq $b.B)
    if (-not $same) { Add-Diff "[XAML] 主题不变键 $k 两本异值（Light/Dark）" }
}

# ---------- 6. 解析 tokens.css（选择器块→变量表）----------
function Read-CssBlocks([string]$path) {
    if (-not (Test-Path $path)) { throw "缺 CSS 文件: $path" }
    $text = (Get-Content -Raw -Encoding UTF8 $path) -replace '(?s)/\*.*?\*/', ''
    $blocks = @{}
    $stack = New-Object System.Collections.ArrayList
    $pos = 0
    while ($pos -lt $text.Length) {
        $open = $text.IndexOf('{', $pos); $close = $text.IndexOf('}', $pos)
        if ($open -ge 0 -and ($close -lt 0 -or $open -lt $close)) {
            [void]$stack.Add($text.Substring($pos, $open - $pos).Trim())
            $pos = $open + 1
        } elseif ($close -ge 0) {
            $body = $text.Substring($pos, $close - $pos)
            $key = ($stack -join ' > ')
            $vars = @{}
            foreach ($m in [regex]::Matches($body, '(?m)^\s*(--[\w-]+)\s*:\s*([^;]+);')) { $vars[$m.Groups[1].Value] = $m.Groups[2].Value }
            if ($vars.Count -gt 0) { $blocks[$key] = $vars }
            if ($stack.Count -gt 0) { $stack.RemoveAt($stack.Count - 1) | Out-Null }
            $pos = $close + 1
        } else { break }
    }
    return $blocks
}
$css = Read-CssBlocks (Join-Path $root 'platforms\web\tokens.css')

# :root ＝106 个（全部非色 primitive token 的浅色解析值）
$expectedRoot = @{}
foreach ($p in $all.Keys) {
    if ($p.StartsWith('color.light.') -or $p.StartsWith('color.dark.')) { continue }
    $expectedRoot[$p.Replace('.', '-').Insert(0, '--')] = $p
}
if (-not $css.Contains(':root')) { Add-Diff '[CSS] 缺 :root 块' }
else {
    $rootVars = $css[':root']
    if ($rootVars.Count -ne 106) { Add-Diff "[CSS] :root 变量数 $($rootVars.Count) ≠ 106" }
    foreach ($e in @($rootVars.Keys | Where-Object { -not $expectedRoot.ContainsKey($_) })) { Add-Diff "[CSS] :root 多余变量 $e" }
    foreach ($name in $expectedRoot.Keys) {
        if (-not $rootVars.ContainsKey($name)) { Add-Diff "[CSS] :root 缺变量 $name（↔ $($expectedRoot[$name])）"; continue }
        $want = Normalize-Css (Get-CssExpected $expectedRoot[$name] $false)
        $got = Normalize-Css $rootVars[$name]
        if ($want -ne $got -and $want.ToUpperInvariant() -ne $got.ToUpperInvariant()) { Add-Diff "[CSS] $name : 期望 $want 实得 $got" }
    }
}
# dark 双块（手动 [data-theme="dark"] 与自动跟随媒体块）＝23 个语义色深色解析值
$semanticColorPaths = @($all.Keys | Where-Object { $_ -match '^color\.' -and $_ -notmatch '^color\.(light|dark)\.' } | Sort-Object)
if ($semanticColorPaths.Count -ne 23) { Add-Diff "[DTCG] 语义色 token 数 $($semanticColorPaths.Count) ≠ 23" }
$darkBlocks = @('[data-theme="dark"]', '@media (prefers-color-scheme: dark) > :root:not([data-theme="light"])')
foreach ($bk in $darkBlocks) {
    if (-not $css.Contains($bk)) { Add-Diff "[CSS] 缺块 $bk"; continue }
    $vars = $css[$bk]
    if ($vars.Count -ne 23) { Add-Diff "[CSS] 块 $bk 变量数 $($vars.Count) ≠ 23" }
    foreach ($p in $semanticColorPaths) {
        $name = $p.Replace('.', '-').Insert(0, '--')
        if (-not $vars.ContainsKey($name)) { Add-Diff "[CSS] 块 $bk 缺变量 $name"; continue }
        $want = Normalize-Css (Get-CssExpected $p $true)
        $got = Normalize-Css $vars[$name]
        if ($want -ne $got -and $want.ToUpperInvariant() -ne $got.ToUpperInvariant()) { Add-Diff "[CSS] 块 $bk ${name} : 期望 $want 实得 $got" }
    }
}

# ---------- 7. 计数核对（TOKEN-MAP §六 结构目标）----------
$targets = @{ color = 69; dimension = 29; motion = 36; typography = 18 }
foreach ($g in $targets.Keys) {
    $got = if ($perFileCount.ContainsKey($g)) { $perFileCount[$g] } else { '缺失' }
    if ($got -ne $targets[$g]) { Add-Diff "[DTCG] $g.tokens.json token 数 $got ≠ $($targets[$g])" }
}
$total = ($perFileCount.Values | Measure-Object -Sum).Sum
if ($total -ne 152) { Add-Diff "[DTCG] token 总数 $total ≠ 152" }
if ($aliasCount -ne 32) { Add-Diff "[DTCG] 别名 token 数 $aliasCount ≠ 32" }
$brushCount = @($light.Values | Where-Object { $_.Kind -eq 'SolidColorBrush' }).Count
$effectCount = @($light.Values | Where-Object { $_.Kind -eq 'DropShadowEffect' }).Count
$invariantCount = $light.Count - $brushCount - $effectCount
if ($brushCount -ne 21 -or $effectCount -ne 1 -or $invariantCount -ne 17) { Add-Diff "[XAML] Light 构成 画刷$brushCount/阴影$effectCount/不变$invariantCount ≠ 21/1/17" }

# ---------- 8. 报告与退出 ----------
Write-Output '=== fts-design-system tokens 三方对账（validate-tokens.ps1）==='
Write-Output ("DTCG : color={0} dimension={1} motion={2} typography={3} 总计={4}（别名 {5}）" -f $perFileCount['color'], $perFileCount['dimension'], $perFileCount['motion'], $perFileCount['typography'], $total, $aliasCount)
Write-Output ("XAML : Light={0} Dark={1}（画刷 {2}＋阴影 {3}＋主题不变 {4}）" -f $light.Count, $darkDict.Count, $brushCount, $effectCount, $invariantCount)
$rootN = if ($css.Contains(':root')) { $css[':root'].Count } else { 0 }
$darkN = if ($css.Contains('[data-theme="dark"]')) { $css['[data-theme="dark"]'].Count } else { 0 }
$mediaN = if ($css.Contains($darkBlocks[1])) { $css[$darkBlocks[1]].Count } else { 0 }
Write-Output ("CSS  : :root={0}｜[data-theme=""dark""]={1}｜media-dark={2}" -f $rootN, $darkN, $mediaN)
Write-Output ("差异清单：{0} 条" -f $diffs.Count)
foreach ($d in $diffs) { Write-Output "  - $d" }
if ($diffs.Count -eq 0) { Write-Output '结果：PASS——DTCG 152（69/29/36/18）↔ XAML 39×2 ↔ CSS 106 三方一致'; exit 0 }
Write-Output '结果：FAIL——见上方差异清单'; exit 1
