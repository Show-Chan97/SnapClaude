# core/status.ps1 - Windows 状态查看

function Test-Command($cmd) { !!(Get-Command $cmd -ErrorAction SilentlyContinue) }
function Get-Version($cmd) {
    try { & $cmd --version 2>$null | Select-Object -First 1 } catch { "unknown" }
}

$tools = @{
    "Git"         = "git"
    "Node.js"     = "node"
    "Python"      = "python"
    "VSCode"      = "code"
    "Claude Code" = "claude"
}

Write-Host ""
Write-Host "  SnapClaude 环境状态" -ForegroundColor Green
Write-Host "  ==================="
Write-Host ""

foreach ($tool in $tools.Keys) {
    $cmd = $tools[$tool]
    if (Test-Command $cmd) {
        $ver = Get-Version $cmd
        Write-Host ("  {0,-12} {1}  {2}" -f $tool, "[OK]", $ver) -ForegroundColor Green
    } else {
        Write-Host ("  {0,-12} {1}  未安装" -f $tool, "[FAIL]") -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "  运行 just install-all 安装全部" -ForegroundColor Yellow
Write-Host ""
