# sync-skill.ps1 —— skill/fts-style-system/ → 用户级 skills 目录 的幂等部署
# 用法：
#   powershell -ExecutionPolicy Bypass -File scripts/sync-skill.ps1 -DryRun   # 预演（不写目标、不备份）
#   powershell -ExecutionPolicy Bypass -File scripts/sync-skill.ps1           # 实际部署（先备份后镜像）
# 可选参数：-Source <目录>（默认 <仓根>\skill\fts-style-system）、-Target <目录>（默认 %USERPROFILE%\.zcode\skills\fts-style-system）。
# 行为：部署＝先把现有目标目录完整备份到 %TEMP%\fts-style-system-backup-<时间戳>，再 robocopy /MIR 镜像
#   （可重入：重复运行结果一致，多出的备份目录按时间戳区分）；部署后输出清单并核对源/目标一致。
# 退出码：0＝成功（预演通过 / 部署且校验一致）；1＝源缺失或结构不完整；2＝备份失败；3＝robocopy 失败；4＝部署后校验不一致。
[CmdletBinding()]
param(
    [switch]$DryRun,
    [string]$Source,
    [string]$Target
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $Source) { $Source = Join-Path (Join-Path $repoRoot 'skill') 'fts-style-system' }
if (-not $Target) { $Target = Join-Path (Join-Path $env:USERPROFILE '.zcode\skills') 'fts-style-system' }

# ---------- 0. 源校验 ----------
if (-not (Test-Path (Join-Path $Source 'SKILL.md'))) {
    Write-Output "[FAIL] 源缺失：$Source\SKILL.md 不存在（应在仓内 scripts\ 下运行，或用 -Source 指定）"
    exit 1
}
$sourceSkillLines = @(Get-Content -LiteralPath (Join-Path $Source 'SKILL.md')).Count
if ($sourceSkillLines -gt 300) {
    Write-Output "[FAIL] 源 SKILL.md $sourceSkillLines 行 > 300 行预算，拒绝部署"
    exit 1
}

# ---------- 1. 清单函数（源/目标同口径） ----------
function Get-Manifest {
    param([string]$Dir)
    $skillMd = Join-Path $Dir 'SKILL.md'
    $refsDir = Join-Path $Dir 'references'
    $assetsDir = Join-Path $Dir 'assets'
    $all = @(Get-ChildItem -LiteralPath $Dir -Recurse -File)
    $refs = @(); $assets = @()
    if (Test-Path $refsDir)   { $refs = @(Get-ChildItem -LiteralPath $refsDir -File) }
    if (Test-Path $assetsDir) { $assets = @(Get-ChildItem -LiteralPath $assetsDir -File) }
    $lines = 0
    if (Test-Path $skillMd) { $lines = @(Get-Content -LiteralPath $skillMd).Count }
    [pscustomobject]@{
        TotalFiles = $all.Count
        SkillLines = $lines
        References = $refs.Count
        Assets     = $assets.Count
    }
}

function Show-Manifest {
    param([string]$Label, $Manifest)
    Write-Output ("  {0,-6} 文件总数 {1}｜SKILL.md {2} 行｜references {3} 件｜assets {4} 件" -f `
        $Label, $Manifest.TotalFiles, $Manifest.SkillLines, $Manifest.References, $Manifest.Assets)
}

$sourceManifest = Get-Manifest -Dir $Source
if ($DryRun) {
    Write-Output "=== DRY-RUN（预演，不写目标、不备份）==="
    Write-Output "源：$Source"
    Show-Manifest -Label '源' -Manifest $sourceManifest
    Write-Output "目标：$Target"
    if (Test-Path $Target) {
        Show-Manifest -Label '目标(现)' -Manifest (Get-Manifest -Dir $Target)
    } else {
        Write-Output '  目标(现) 不存在（部署将全新创建）'
    }
    Write-Output '将执行：robocopy /MIR（镜像=复制新增/覆盖变更/删除目标多余项）'
    Write-Output '=== DRY-RUN 结束：预演通过 ==='
    exit 0
}

# ---------- 2. 备份现有目标 ----------
if (Test-Path $Target) {
    $beforeFiles = @(Get-ChildItem -LiteralPath $Target -Recurse -File).Count
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = Join-Path $env:TEMP "fts-style-system-backup-$stamp"
    if (Test-Path $backup) { $backup = "$backup-$([guid]::NewGuid().ToString('N').Substring(0,6))" }
    Copy-Item -LiteralPath $Target -Destination $backup -Recurse
    $backedUp = @(Get-ChildItem -LiteralPath $backup -Recurse -File).Count
    if ($backedUp -ne $beforeFiles) {
        Write-Output "[FAIL] 备份不完整：目标 $beforeFiles 件 vs 备份 $backedUp 件（$backup）——已中止，未动目标"
        exit 2
    }
    Write-Output "备份：$Target（$beforeFiles 件）→ $backup"
} else {
    Write-Output "目标不存在，无需备份：$Target"
}

# ---------- 3. robocopy 镜像 ----------
robocopy $Source $Target /MIR /R:2 /W:1 /NP /NFL /NDL | Out-Null
$rc = $LASTEXITCODE
if ($rc -ge 8) {
    Write-Output "[FAIL] robocopy 退出码 $rc（≥8 为失败）——目标可能不完整，可从上面的备份恢复"
    exit 3
}
Write-Output "robocopy /MIR 完成（退出码 $rc：0=无变更〔幂等命中〕，1=有复制，<8 均为成功）"

# ---------- 4. 部署后校验 ----------
$targetManifest = Get-Manifest -Dir $Target
$ok = $true
if ($targetManifest.TotalFiles -ne $sourceManifest.TotalFiles) { $ok = $false }
if ($targetManifest.SkillLines -ne $sourceManifest.SkillLines) { $ok = $false }
if ($targetManifest.References -ne $sourceManifest.References) { $ok = $false }
if ($targetManifest.Assets -ne $sourceManifest.Assets)         { $ok = $false }
if ($targetManifest.SkillLines -gt 300)                        { $ok = $false }

Write-Output '=== 部署清单 ==='
Show-Manifest -Label '源' -Manifest $sourceManifest
Show-Manifest -Label '目标' -Manifest $targetManifest
if (-not $ok) {
    Write-Output '[FAIL] 部署后校验不一致（文件数/行数/references/assets）'
    exit 4
}
Write-Output '校验一致：文件总数、SKILL.md 行数（≤300）、references 件数、assets 件数 全部与源相同'
Write-Output '=== 部署成功 ==='
exit 0
