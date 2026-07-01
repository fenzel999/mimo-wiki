# mimo-wiki 安装脚本 (Windows PowerShell)
# 用法:
#   irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 | iex
#   irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 | iex; Install-MimoWiki -Global
#   irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 | iex; Install-MimoWiki -Dir "C:\Projects\my-project"

param(
    [switch]$Global,
    [string]$Dir,
    [switch]$Help
)

function Install-MimoWiki {
    param(
        [switch]$Global,
        [string]$Dir,
        [switch]$Help
    )

    if ($Help) {
        Write-Host "用法:"
        Write-Host "  irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 | iex"
        Write-Host "  irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 | iex; Install-MimoWiki -Global"
        Write-Host "  irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 | iex; Install-MimoWiki -Dir 'C:\Projects\my-project'"
        return
    }

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

    if ($Global) {
        $target = Join-Path $env:USERPROFILE ".mimocode"
    } elseif ($Dir) {
        $target = $Dir
    } else {
        $target = Get-Location
    }

    Write-Host "mimo-wiki 安装到: $target"
    Write-Host ""

    $installed = 0
    $skipped = 0

    foreach ($f in $files) {
        $dest = Join-Path $target $f

        if (Test-Path $dest) {
            Write-Host "  跳过（已存在）: $f"
            $skipped++
            continue
        }

        $destDir = Split-Path $dest -Parent
        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        try {
            Invoke-WebRequest -Uri "$base/$f" -OutFile $dest -UseBasicParsing -ErrorAction Stop
            Write-Host "  安装: $f"
            $installed++
        } catch {
            Write-Host "  失败: $f — $($_.Exception.Message)"
        }
    }

    Write-Host ""
    Write-Host "完成: $installed 已安装, $skipped 跳过"
    Write-Host ""
    Write-Host '下一步: 在 MiMo Code 中说 "帮我创建一个新的 LLM Wiki"'
}

# 如果通过 irm | iex 调用（无参数），执行默认安装
if ($Global -or $Dir -or $Help) {
    Install-MimoWiki -Global:$Global -Dir $Dir -Help:$Help
} else {
    Install-MimoWiki
}
