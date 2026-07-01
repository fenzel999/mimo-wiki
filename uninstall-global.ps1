# mimo-wiki 从全局卸载 (Windows PowerShell)
# 用法: irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/uninstall-global.ps1 | iex

$target = Join-Path $env:USERPROFILE ".config\mimocode"

Write-Host "从 $target 卸载 mimo-wiki"
Write-Host ""

$files = @(
    "skills/llm-wiki/references/bm25-search.js"
    "skills/llm-wiki/references/bm25.md"
    "skills/llm-wiki/references/page-types.md"
    "skills/llm-wiki/references/citations.md"
    "skills/llm-wiki/templates/schema-template.md"
    "skills/llm-wiki/templates/index-template.md"
    "skills/llm-wiki/templates/log-template.md"
    "skills/llm-wiki/SKILL.md"
    "AGENTS.md"
)

$removed = 0
foreach ($f in $files) {
    $dest = Join-Path $target $f
    if (Test-Path $dest) {
        Remove-Item $dest -Force
        Write-Host "  删除: $f"
        $removed++
    }
}

foreach ($dir in @("skills/llm-wiki/references", "skills/llm-wiki/templates", "skills/llm-wiki", "skills")) {
    $path = Join-Path $target $dir
    if ((Test-Path $path) -and ((Get-ChildItem $path -Force | Measure-Object).Count -eq 0)) {
        Remove-Item $path -Force
        Write-Host "  删除空目录: $dir"
    }
}

Write-Host ""
Write-Host "完成: 删除了 $removed 个文件"
