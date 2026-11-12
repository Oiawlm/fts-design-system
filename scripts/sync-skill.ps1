# sync-skill.ps1 —— skill/fts-style-system/ → 本机全部 AI 编码代理 skills 目录 的幂等多目标部署
# 用法：
#   powershell -ExecutionPolicy Bypass -File scripts/sync-skill.ps1            # 探测本机全部 agent skills 目录并部署
#   powershell -ExecutionPolicy Bypass -File scripts/sync-skill.ps1 -DryRun    # 预演（不写目标、不备份）
#   powershell -ExecutionPolicy Bypass -File scripts/sync-skill.ps1 -Targets "C:\a\.claude\skills;C:\b\.codex\skills"  # 显式目标根
# 可选参数：-Source <目录>（默认 <仓根>\skill\fts-style-system）；-Targets <目标根数组>（分号分隔，每项部署到 <目标根>\fts-style-system）。
# 探测（无 -Targets 时）：~/.zcode、~/.codex、~/.claude、~/.cursor、~/.gemini 各自 skills 子目录（父目录存在即纳入）；
#   ~/.agents/skills 厂商中立目录无条件纳入（不存在则部署时创建）。
# 行为（每目标独立）：备份 %TEMP%\fts-style-system-backup-<目标根目录名>-<yyyyMMdd-HHmmss> → robocopy /MIR 镜像 → 源/目标清单核对
#   （可重入：重复运行结果一致，多出的备份目录按时间戳区分）。
# 退出码：0＝全部目标成功；1＝源校验失败 / 未探测到任何 agent / -Targets 解析为空；2＝备份失败；3＝robocopy 失败；
#   4＝部署后校验不一致；5＝部分或混合失败（全部目标败于同一阶段时按该阶段码 2/3/4 退出），末尾输出逐目标 PASS/FAIL 明细。
[CmdletBinding()]
param(
    [switch]$DryRun,
    [string]$Source,
    [string[]]$Targets
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $Source) { $Source = Join-Path (Join-Path $repoRoot 'skill') 'fts-style-system' }

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

# ---------- 2. 目标探测：输出「纳入/跳过」明细 ----------
function Get-SkillRoots {
    $roots = @()
    foreach ($agent in @('.zcode', '.codex', '.claude', '.cursor', '.gemini')) {
        $agentDir = Join-Path $env:USERPROFILE $agent
        if (Test-Path $agentDir) {
            $roots += (Join-Path $agentDir 'skills')
            Write-Host "  纳入：~/$agent 存在 → ~/$agent/skills"
        } else {
            Write-Host "  跳过：~/$agent 不存在"
        }
    }
    $neutral = Join-Path $env:USERPROFILE '.agents\skills'
    $roots += $neutral
    if (Test-Path $neutral) { Write-Host '  纳入：~/.agents/skills 厂商中立目录（无条件）' }
    else { Write-Host '  纳入：~/.agents/skills 厂商中立目录（无条件，现不存在，部署时创建）' }
    return $roots
}

if ($Targets) {
    $skillRoots = @($Targets | ForEach-Object { $_ -split ';' } | ForEach-Object { $_.Trim().TrimEnd('\') } | Where-Object { $_ })
    if ($skillRoots.Count -eq 0) {
        Write-Output '[FAIL] -Targets 解析后为空（分号分隔目标根，例："C:\a\.claude\skills;C:\b\.codex\skills"）'
        exit 1
    }
    Write-Output "=== 目标（-Targets 显式指定，$($skillRoots.Count) 个目标根）==="
    foreach ($r in $skillRoots) { Write-Output "  显式：$r" }
} else {
    Write-Output '=== 目标探测（本机 agent skills 目录）==='
    $skillRoots = @(Get-SkillRoots)
    if ($skillRoots.Count -eq 0) {
        Write-Output '[FAIL] 未探测到任何 agent skills 目录——用 -Targets 显式指定，例："C:\a\.claude\skills;C:\b\.codex\skills"'
        exit 1
    }
}

# ---------- 3. DryRun：只读预演 ----------
if ($DryRun) {
    Write-Output '=== DRY-RUN（预演，不写目标、不备份、不建目录）==='
    Write-Output "源：$Source"
    Show-Manifest -Label '源' -Manifest $sourceManifest
    foreach ($root in $skillRoots) {
        $t = Join-Path $root 'fts-style-system'
        Write-Output "目标：$t"
        if (Test-Path $t) { Show-Manifest -Label '目标(现)' -Manifest (Get-Manifest -Dir $t) }
        else { Write-Output '  目标(现) 不存在（部署将全新创建）' }
    }
    Write-Output '每目标将执行：备份现有目标（如有）→ robocopy /MIR（复制新增/覆盖变更/删除目标多余项）→ 清单核对'
    Write-Output "=== DRY-RUN 结束：预演通过（$($skillRoots.Count) 个目标）==="
    exit 0
}

# ---------- 4. 逐目标部署：备份 → 镜像 → 校验 ----------
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$results = @()
$stageNames = @{ 2 = '备份'; 3 = 'robocopy 镜像'; 4 = '部署后校验' }

foreach ($root in $skillRoots) {
    $label = ((Split-Path -Leaf (Split-Path -Parent $root)) -replace '[:\\/]', '-')
    $target = Join-Path $root 'fts-style-system'
    Write-Output "--- 目标 [$label] $target ---"

    # 4.1 备份（目标根不存在则创建；目标存在则完整备份）——失败类 2
    try {
        if (-not (Test-Path $root)) { New-Item -ItemType Directory -Path $root -Force | Out-Null }
        if (Test-Path $target) {
            $beforeFiles = @(Get-ChildItem -LiteralPath $target -Recurse -File).Count
            $backup = Join-Path $env:TEMP "fts-style-system-backup-$label-$stamp"
            if (Test-Path $backup) { $backup = "$backup-$([guid]::NewGuid().ToString('N').Substring(0,6))" }
            Copy-Item -LiteralPath $target -Destination $backup -Recurse
            $backedUp = @(Get-ChildItem -LiteralPath $backup -Recurse -File).Count
            if ($backedUp -ne $beforeFiles) {
                Write-Output "[FAIL] 备份不完整：目标 $beforeFiles 件 vs 备份 $backedUp 件（$backup）——本目标中止，未动目标"
                $results += [pscustomobject]@{ Label = $label; Target = $target; Stage = 2 }
                continue
            }
            Write-Output "备份：$target（$beforeFiles 件）→ $backup"
        } else {
            Write-Output '目标不存在，无需备份（将全新创建）'
        }
    } catch {
        Write-Output "[FAIL] 备份异常：$($_.Exception.Message)——本目标中止，未动目标"
        $results += [pscustomobject]@{ Label = $label; Target = $target; Stage = 2 }
        continue
    }

    # 4.2 robocopy 镜像——失败类 3
    robocopy $Source $target /MIR /R:2 /W:1 /NP /NFL /NDL | Out-Null
    $rc = $LASTEXITCODE
    if ($rc -ge 8) {
        Write-Output "[FAIL] robocopy 退出码 $rc（≥8 为失败）——本目标可能不完整，可从备份恢复"
        $results += [pscustomobject]@{ Label = $label; Target = $target; Stage = 3 }
        continue
    }
    Write-Output "robocopy /MIR 完成（退出码 $rc：0=无变更〔幂等命中〕，1=有复制，<8 均为成功）"

    # 4.3 部署后校验——失败类 4
    $targetManifest = $null
    try {
        $targetManifest = Get-Manifest -Dir $target
        $ok = ($targetManifest.TotalFiles -eq $sourceManifest.TotalFiles) -and
              ($targetManifest.SkillLines -eq $sourceManifest.SkillLines) -and
              ($targetManifest.References -eq $sourceManifest.References) -and
              ($targetManifest.Assets -eq $sourceManifest.Assets) -and
              ($targetManifest.SkillLines -le 300)
    } catch {
        $ok = $false
    }
    if ($targetManifest) { Show-Manifest -Label '目标' -Manifest $targetManifest }
    if (-not $ok) {
        Write-Output '[FAIL] 部署后校验不一致（文件数/行数/references/assets）'
        $results += [pscustomobject]@{ Label = $label; Target = $target; Stage = 4 }
        continue
    }
    Write-Output '校验一致：文件总数、SKILL.md 行数（≤300）、references 件数、assets 件数 全部与源相同'
    $results += [pscustomobject]@{ Label = $label; Target = $target; Stage = 0 }
}

# ---------- 5. 汇总与退出码聚合 ----------
Write-Output '=== 逐目标结果 ==='
foreach ($r in $results) {
    if ($r.Stage -eq 0) { Write-Output "  [PASS] $($r.Label)：$($r.Target)" }
    else { Write-Output "  [FAIL] $($r.Label)（$($stageNames[[int]$r.Stage])失败）：$($r.Target)" }
}
$failures = @($results | Where-Object { $_.Stage -ne 0 })
if ($failures.Count -eq 0) {
    Write-Output "=== 部署成功：$($results.Count)/$($results.Count) 目标 PASS ==="
    exit 0
}
if ($failures.Count -eq $results.Count) {
    $stages = @($failures | ForEach-Object { [int]$_.Stage } | Select-Object -Unique)
    if ($stages.Count -eq 1) { Write-Output "=== 部署失败：全部目标败于$($stageNames[$stages[0]]) ==="; exit $stages[0] }
}
Write-Output "=== 部署失败：$($failures.Count)/$($results.Count) 目标 FAIL（明细见上）==="
exit 5
