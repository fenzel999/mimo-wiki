# mimo-wiki 全局安装 (Windows PowerShell)
# 用法: irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install-global.ps1 | iex

$repo = "fenzel999/mimo-wiki"
$branch = "master"
$base = "https://raw.githubusercontent.com/$repo/$branch"
$target = Join-Path $env:USERPROFILE ".config\mimocode"

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

Write-Host "mimo-wiki 全局安装到: $target"
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
