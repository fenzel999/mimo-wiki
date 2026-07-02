# mimo-wiki 安装/卸载 (Windows PowerShell)
#
# 安装（交互选择位置）:
#   irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 | iex
#
# 指定参数跳过交互:
#   irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 | iex -args '-Local'
#   irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 | iex -args '-Global'
#
# 卸载:
#   irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 | iex -args '-Uninstall'
#   irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 | iex -args '-Uninstall','-Local'
#   irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 | iex -args '-Uninstall','-Global'

param(
    [switch]$Local,
    [switch]$Global,
    [switch]$Uninstall
)

$repo = "fenzel999/mimo-wiki"
$branch = "master"
$base = "https://raw.githubusercontent.com/$repo/$branch"

$files = @(
    "AGENTS.md"
    "skills/llm-wiki/SKILL.md"
    "skills/llm-wiki/templates/schema-template.md"
    "skills/llm-wiki/templates/index-template.md"
    "skills/llm-wiki/templates/log-template.md"
    "skills/llm-wiki/references/bm25-search.js"
    "skills/llm-wiki/references/bm25.md"
    "skills/llm-wiki/references/page-types.md"
    "skills/llm-wiki/references/citations.md"
)

$action = if ($Uninstall) { "uninstall" } else { "install" }

# ─── 未指定则交互 ──────────────────────────────────────────
if (-not ($Local -or $Global)) {
    $currentDir = (Get-Location).Path
    $globalDir = Join-Path $env:USERPROFILE ".config\mimocode"
    $actionName = if ($Uninstall) { "Uninstaller" } else { "Installer" }

    Write-Host "========================================================"
    Write-Host "  mimo-wiki $actionName"
    Write-Host "========================================================"
    Write-Host ""
    Write-Host "  1) Current project → $currentDir"
    Write-Host "  2) All projects    → $globalDir"
    Write-Host ""
    $choice = Read-Host "  Choice [1/2]"

    switch ($choice) {
        "1" { $Local = $true }
        "2" { $Global = $true }
        default {
            Write-Host "  Invalid: $choice (1=project, 2=global)"
            exit 1
        }
    }

    if ($Uninstall) {
        $label = if ($Local) { $currentDir } else { $globalDir }
        $confirm = Read-Host "  Confirm uninstall $label ? [y/N]"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Host "  Cancelled"
            exit 0
        }
    }
}

# ─── 目标路径 ──────────────────────────────────────────────
if ($Global) {
    $target = Join-Path $env:USERPROFILE ".config\mimocode"
    $wikiPath = Join-Path $target "wiki"
} else {
    $target = Get-Location
    $wikiPath = Join-Path $target "wiki"
}

# ─── 安装 ──────────────────────────────────────────────────
function Install-MimoWiki {
    Write-Host "Installing mimo-wiki to: $target"
    Write-Host ""
    $installed = 0
    $skipped = 0

    foreach ($f in $files) {
        $dest = Join-Path $target $f
        if (Test-Path $dest) {
            Write-Host "  Skip (exists): $f"
            $skipped++
            continue
        }
        $destDir = Split-Path $dest -Parent
        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        try {
            Invoke-WebRequest -Uri "$base/$f" -OutFile $dest -UseBasicParsing -ErrorAction Stop
            Write-Host "  Install: $f"
            $installed++
        } catch {
            Write-Host "  Fail: $f — $($_.Exception.Message)"
        }
    }

    Write-Host ""
    Write-Host "Done: $installed installed, $skipped skipped"
    Write-Host ""
    Write-Host "Wiki data will be at: $wikiPath"
    Write-Host ""
    Write-Host 'Next: say "帮我创建一个新的 LLM Wiki" in MiMo Code'
}

# ─── 卸载 ──────────────────────────────────────────────────
function Uninstall-MimoWiki {
    Write-Host "Uninstalling mimo-wiki from: $target"
    Write-Host ""
    $removed = 0

    for ($i = $files.Count - 1; $i -ge 0; $i--) {
        $dest = Join-Path $target $files[$i]
        if (Test-Path $dest) {
            Remove-Item $dest -Force
            Write-Host "  Delete: $($files[$i])"
            $removed++
        }
    }

    foreach ($dir in @("skills/llm-wiki/references", "skills/llm-wiki/templates", "skills/llm-wiki", "skills")) {
        $path = Join-Path $target $dir
        if ((Test-Path $path) -and ((Get-ChildItem $path -Force | Measure-Object).Count -eq 0)) {
            Remove-Item $path -Force
            Write-Host "  Delete dir: $dir"
        }
    }

    Write-Host ""
    Write-Host "Done: $removed files deleted"
    Write-Host "Note: wiki data ($wikiPath) not removed — delete manually if needed"
}

switch ($action) {
    "install"   { Install-MimoWiki }
    "uninstall" { Uninstall-MimoWiki }
}