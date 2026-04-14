# SnapClaude Windows 安装脚本
# Usage: .\install.ps1 [all|git|node|python|vscode|claude]

param(
    [string]$Target = "all"
)

$ErrorActionPreference = "Stop"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$CoreDir = "$SCRIPT_DIR/../core"

# -------------------- 颜色 --------------------
function Write-Step($msg) { Write-Host "[STEP] $msg" -ForegroundColor Cyan }
function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Blue }
function Write-Ok($msg)   { Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Fail($msg) { Write-Host "[FAIL] $msg" -ForegroundColor Red }

# -------------------- 环境变量辅助 --------------------
function Add-ToPath($dir) {
    if (-not (Test-Path $dir)) { return }
    $dir = $dir.TrimEnd('\')
    
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if (-not $userPath) { $userPath = "" }
    
    # regex escape path for exact check
    $escapedDir = [regex]::Escape($dir)
    if ($userPath -notmatch "(^|;)$escapedDir(;|$)") {
        $newPath = "$dir;$userPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    }
    
    if ($env:Path -notmatch "(^|;)$escapedDir(|$)") {
        $env:Path = "$dir;$env:Path"
    }
}

# -------------------- 检测 --------------------
function Get-Platform {
    $arch = $env:PROCESSOR_ARCHITECTURE
    if ($arch -eq "ARM64") { return "windows-arm64" }
    return "windows-x64"
}

function Test-Command($cmd) { !!(Get-Command $cmd -ErrorAction SilentlyContinue) }

function Get-Version($cmd) {
    try {
        (& $cmd --version 2>$null | Select-Object -First 1)
    } catch { "unknown" }
}

# -------------------- 下载 --------------------
$Mirror = "https://gh-proxy.com"
$Mirror2 = "https://ghproxy.com"

function Invoke-Download($url, $dest) {
    $tmp = "$dest.tmp"
    Write-Info "下载 $([System.IO.Path]::GetFileName($dest))..."
    
    $urls = @($url)
    if ($url -match "github\.com|githubusercontent\.com") {
        $urls += "$Mirror/$url"
        $urls += "$Mirror2/$url"
    }
    
    foreach ($u in $urls) {
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $oldProgress = $ProgressPreference
            $ProgressPreference = "SilentlyContinue"
            Invoke-WebRequest -Uri $u -OutFile $tmp -UseBasicParsing
            $ProgressPreference = $oldProgress
            Move-Item $tmp $dest -Force
            Write-Ok "下载完成 ($u)"
            return $true
        } catch {
            Write-Warn "下载失败: $u"
        }
    }
    return $false
}

# -------------------- 安装 --------------------
function Install-Git {
    Write-Step "安装 Git..."
    if (Test-Command git) {
        Write-Ok "Git 已安装: $(Get-Version git)"
        return
    }

    $version = "2.43.0"
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
    $filename = "Git-${version}-${arch}-portable.exe"
    $url = "https://github.com/git-for-windows/git/releases/download/v${version}.windows.1/${filename}"
    $dest = "$env:TEMP\Git.exe"

    if (Invoke-Download $url $dest) {
        $installDir = "D:\DevEnvs"
        if (!(Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir -Force | Out-Null }
        Copy-Item $dest "$installDir\Git.exe" -Force
        
        $cmdDir = "$installDir\cmd"
        if (!(Test-Path $cmdDir)) { New-Item -ItemType Directory -Path $cmdDir -Force | Out-Null }
        Copy-Item "$installDir\Git.exe" "$cmdDir\git.exe" -Force

        $binDir = "$installDir\bin"
        if (!(Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir -Force | Out-Null }
        Copy-Item "$installDir\Git.exe" "$binDir\git.exe" -Force

        Add-ToPath $cmdDir
        Add-ToPath $binDir

        Write-Ok "Git 已安装到 $installDir"
    } else {
        Write-Fail "Git 安装失败"
    }
}

function Install-Node {
    Write-Step "安装 Node.js..."
    if (Test-Command node) {
        Write-Ok "Node.js 已安装: $(Get-Version node)"
        return
    }

    $version = "20.10.0"
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
    $filename = "node-v${version}-win-${arch}.zip"
    $url = "https://nodejs.org/dist/v${version}/${filename}"
    $dest = "$env:TEMP\node.zip"
    $extractDir = "D:\DevEnvs\nodejs"

    if (Invoke-Download $url $dest) {
        if (!(Test-Path $extractDir)) { New-Item -ItemType Directory -Path $extractDir -Force | Out-Null }
        Expand-Archive -Path $dest -DestinationPath $extractDir -Force
        $actualDir = Get-ChildItem $extractDir -Directory | Where-Object { $_.Name -match "^node-" } | Select-Object -First 1
        if ($actualDir) {
            Add-ToPath $actualDir.FullName
        }
        Remove-Item $dest -Force -ErrorAction SilentlyContinue
        Write-Ok "Node.js 已安装"
    }
}

function Install-Python {
    Write-Step "安装 Python..."
    if (Test-Command python) {
        Write-Ok "Python 已安装: $(Get-Version python)"
        return
    }

    $version = "3.11.7"
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "amd64" }
    $filename = "python-${version}-embed-${arch}.zip"
    $url = "https://www.python.org/ftp/python/${version}/${filename}"
    $dest = "$env:TEMP\python.zip"
    $extractDir = "D:\DevEnvs\Python"

    if (Invoke-Download $url $dest) {
        if (!(Test-Path $extractDir)) { New-Item -ItemType Directory -Path $extractDir -Force | Out-Null }
        Expand-Archive -Path $dest -DestinationPath $extractDir -Force
        
        # 取消注释 _pth 文件中的 import site 以支持 pip
        $pthFile = Get-ChildItem $extractDir -Filter "*._pth" | Select-Object -First 1
        if ($pthFile) {
            $content = Get-Content $pthFile.FullName
            $content = $content -replace "#import site", "import site"
            Set-Content $pthFile.FullName $content
        }

        # 下载 pip
        $pipUrl = "https://bootstrap.pypa.io/get-pip.py"
        Invoke-Download $pipUrl "$extractDir\get-pip.py" | Out-Null
        
        # 执行安装 pip
        & "$extractDir\python.exe" "$extractDir\get-pip.py" "-i" "https://pypi.tuna.tsinghua.edu.cn/simple"

        Add-ToPath $extractDir
        Add-ToPath "$extractDir\Scripts"

        Remove-Item $dest -Force -ErrorAction SilentlyContinue
        Write-Ok "Python 已安装"
    } else {
        Write-Fail "Python 下载失败"
    }
}

function Install-VSCode {
    Write-Step "安装 VSCode..."
    if (Test-Command code) {
        Write-Ok "VSCode 已安装: $(Get-Version code)"
        return
    }

    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
    $url = "https://update.code.visualstudio.com/latest/win32-$arch/stable"
    $dest = "$env:TEMP\VSCode.zip"
    $extractDir = "D:\DevEnvs\VSCode"

    if (Invoke-Download $url $dest) {
        if (!(Test-Path $extractDir)) { New-Item -ItemType Directory -Path $extractDir -Force | Out-Null }
        Expand-Archive -Path $dest -DestinationPath $extractDir -Force
        Remove-Item $dest -Force -ErrorAction SilentlyContinue
        
        Add-ToPath "$extractDir\bin"
        
        Write-Ok "VSCode 已安装到 $extractDir"
    }
}

function Install-Claude {
    Write-Step "安装 Claude Code..."

    # 先装依赖
    if (!(Test-Command git)) { Install-Git }
    if (!(Test-Command node)) { Install-Node }

    if (Test-Command claude) {
        Write-Ok "Claude Code 已安装: $(Get-Version claude)"
        return
    }

    if (!(Test-Command npm)) {
        Write-Fail "npm 未找到，Node.js 可能未正确配置"
        return
    }

    Write-Info "正在安装 @anthropic-ai/claude-code..."
    cmd /c "npm install -g @anthropic-ai/claude-code"
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "安装失败，尝试通过国内 npm 镜像加速..."
        cmd /c "npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com"
    }

    if (Test-Command claude) {
        Write-Ok "Claude Code 已安装: $(Get-Version claude)"
        Register-ClaudePlugins
    } else {
        Write-Fail "Claude Code 安装失败"
    }
}

function Register-ClaudePlugins {
    Write-Step "注册 Claude Code 插件..."

    $plugins = @("pyright", "typescript", "powershell")
    foreach ($p in $plugins) {
        Write-Info "注册 $p..."
        claude plugin install $p 2>$null 4>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-Ok "$p 已注册" } else { Write-Warn "$p 注册失败" }
    }

    # Playwright
    Write-Info "注册 Playwright..."
    claude skills add playwright 2>$null 4>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { Write-Ok "Playwright 已注册" } else { Write-Warn "Playwright 注册失败" }

    # Jupyter MCP
    Write-Info "注册 Jupyter MCP..."
    claude mcp add jupyter "http://127.0.0.1:8888/mcp" 2>$null 4>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { Write-Ok "Jupyter MCP 已注册" } else { Write-Warn "Jupyter MCP 注册失败" }

    # 跳过 onboarding
    $settingsDir = "$env:USERPROFILE\.claude"
    if (!(Test-Path $settingsDir)) { New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null }
    $settingsFile = "$settingsDir\settings.json"
    if (Test-Path $settingsFile) {
        try {
            $json = Get-Content $settingsFile -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
            $json | Add-Member -NotePropertyName "hasCompletedOnboarding" -NotePropertyValue $true -Force -ErrorAction SilentlyContinue
            $json | ConvertTo-Json -Depth 10 | Set-Content $settingsFile
        } catch {}
    } else {
        '{"hasCompletedOnboarding": true}' | Set-Content $settingsFile
    }
    Write-Ok "Onboarding 已跳过"
    Write-Ok "插件注册完成"
}

# -------------------- 主 --------------------
Write-Host ""
Write-Host "  SnapClaude (Windows $(Get-Platform))" -ForegroundColor Green
Write-Host "  ============================" -ForegroundColor Green
Write-Host ""

switch ($Target.ToLower()) {
    "all"    { Install-Git; Install-Node; Install-Python; Install-VSCode; Install-Claude }
    "git"    { Install-Git }
    "node"   { Install-Node }
    "python" { Install-Python }
    "vscode" { Install-VSCode }
    "claude" { Install-Claude }
    default  {
        Write-Host "用法: .\install.ps1 [all|git|node|python|vscode|claude]"
        Write-Host ""
        Write-Host "  all     安装全部（默认）"
        Write-Host "  git     仅安装 Git"
        Write-Host "  node    仅安装 Node.js"
        Write-Host "  python  仅安装 Python"
        Write-Host "  vscode  仅安装 VSCode"
        Write-Host "  claude  仅安装 Claude Code"
    }
}

Write-Host ""
