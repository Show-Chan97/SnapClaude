# SnapClaude Windows 瀹夎鑴氭湰
# Usage: .\install.ps1 [all|git|node|python|vscode|claude]

param(
    [string]$Target = "all",
    [switch]$DebugLog
)

$ErrorActionPreference = "Stop"


# 鍔ㄦ€佹帰娴嬪熀纭€璺緞
$InstallRoot = if (Test-Path "D:\") { "D:\DevEnvs" } else { "$env:USERPROFILE\DevEnvs" }
# 纭繚璺緞涓嶄负绌?
if ($null -eq $InstallRoot -or $InstallRoot -eq "") { $InstallRoot = "C:\DevEnvs" }
if (-not (Test-Path $InstallRoot)) { New-Item -ItemType Directory -Path $InstallRoot -Force | Out-Null }

# -------------------- 棰滆壊 --------------------
function Write-Step($msg) { Write-Host "[STEP] $msg" -ForegroundColor Cyan }
function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Blue }
function Write-Ok($msg)   { Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Fail($msg) { Write-Host "[FAIL] $msg" -ForegroundColor Red }

if ($DebugLog) {
    $LogPath = "$InstallRoot\install_debug.log"
    Start-Transcript -Path $LogPath -Append
    Write-Info "璋冭瘯妯″紡宸插紑鍚紝璇︾粏瀹夎鏃ュ織灏嗚嚜鍔ㄤ繚瀛樿嚦: $LogPath"
}

# -------------------- 鐜鍙橀噺杈呭姪 --------------------
function Add-ToPath($dir) {
    if ($null -eq $dir -or $dir -eq "") { return }
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

# -------------------- 妫€娴?--------------------
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

# -------------------- 涓嬭浇 --------------------
$Mirror = "https://gh-proxy.com"
$Mirror2 = "https://ghproxy.com"

function Invoke-Download($url, $dest) {
    $tmp = "$dest.tmp"
    Write-Info "涓嬭浇 $([System.IO.Path]::GetFileName($dest))..."
    
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
            Write-Ok "涓嬭浇瀹屾垚 ($u)"
            return $true
        } catch {
            Write-Warn "涓嬭浇澶辫触: $u"
            Remove-Item $tmp -Force -ErrorAction SilentlyContinue
        }
    }
    return $false
}

# -------------------- 瀹夎 --------------------
function Install-Git {
    Write-Step "瀹夎 Git..."
    if (Test-Command git) {
        Write-Ok "Git 宸插畨瑁? $(Get-Version git)"
        return
    }

    $version = "2.43.0"
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "64-bit" }
    $filename = "PortableGit-${version}-${arch}.7z.exe"
    $url = "https://github.com/git-for-windows/git/releases/download/v${version}.windows.1/${filename}"
    $dest = "$env:TEMP\$filename"

    if (Invoke-Download $url $dest) {
        $installDir = "$InstallRoot\Git"
        if (!(Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir -Force | Out-Null }
        
        Write-Info "姝ｅ湪鎻愬彇 Git 鍒?$installDir ..."
        Start-Process -FilePath $dest -ArgumentList "-y","-o`"$installDir`"" -WindowStyle Hidden -Wait
        
        $cmdDir = "$installDir\cmd"
        $binDir = "$installDir\bin"

        Add-ToPath $cmdDir
        Add-ToPath $binDir

        Write-Ok "Git 宸插畨瑁呭埌 $installDir"
    } else {
        Write-Fail "Git 瀹夎澶辫触"
    }
}

function Install-Node {
    Write-Step "瀹夎 Node.js..."
    if (Test-Command node) {
        Write-Ok "Node.js 宸插畨瑁? $(Get-Version node)"
        return
    }

    $version = "20.10.0"
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
    $filename = "node-v${version}-win-${arch}.zip"
    $url = "https://nodejs.org/dist/v${version}/${filename}"
    $dest = "$env:TEMP\node.zip"
    $extractDir = "$InstallRoot\nodejs"

    if (Invoke-Download $url $dest) {
        if (!(Test-Path $extractDir)) { New-Item -ItemType Directory -Path $extractDir -Force | Out-Null }
        Expand-Archive -Path $dest -DestinationPath $extractDir -Force
        $actualDir = Get-ChildItem $extractDir -Directory | Where-Object { $_.Name -match "^node-" } | Select-Object -First 1
        if ($actualDir) {
            Add-ToPath $actualDir.FullName
        }
        Remove-Item $dest -Force -ErrorAction SilentlyContinue
        Write-Ok "Node.js 宸插畨瑁?
    }
}

function Install-Python {
    Write-Step "瀹夎 Python..."
    if (Test-Command python) {
        Write-Ok "Python 宸插畨瑁? $(Get-Version python)"
        return
    }

    $version = "3.11.7"
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "amd64" }
    $filename = "python-${version}-embed-${arch}.zip"
    $url = "https://www.python.org/ftp/python/${version}/${filename}"
    $dest = "$env:TEMP\python.zip"
    $extractDir = "$InstallRoot\Python"

    if (Invoke-Download $url $dest) {
        if (!(Test-Path $extractDir)) { New-Item -ItemType Directory -Path $extractDir -Force | Out-Null }
        Expand-Archive -Path $dest -DestinationPath $extractDir -Force
        
        # 鍙栨秷娉ㄩ噴 _pth 鏂囦欢涓殑 import site 浠ユ敮鎸?pip
        $pthFile = Get-ChildItem $extractDir -Filter "*._pth" | Select-Object -First 1
        if ($pthFile) {
            $content = Get-Content $pthFile.FullName
            $content = $content -replace "#import site", "import site"
            Set-Content $pthFile.FullName $content
        }

        # 涓嬭浇 pip
        $pipUrl = "https://bootstrap.pypa.io/get-pip.py"
        Invoke-Download $pipUrl "$extractDir\get-pip.py" | Out-Null
        
        # 鎵ц瀹夎 pip
        & "$extractDir\python.exe" "$extractDir\get-pip.py" "-i" "https://pypi.tuna.tsinghua.edu.cn/simple"

        Add-ToPath $extractDir
        Add-ToPath "$extractDir\Scripts"

        Remove-Item $dest -Force -ErrorAction SilentlyContinue
        Write-Ok "Python 宸插畨瑁?
    } else {
        Write-Fail "Python 涓嬭浇澶辫触"
    }
}

function Install-VSCode {
    Write-Step "瀹夎 VSCode..."
    if (Test-Command code) {
        Write-Ok "VSCode 宸插畨瑁? $(Get-Version code)"
        return
    }

    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
    $url = "https://update.code.visualstudio.com/latest/win32-$arch-archive/stable"
    $dest = "$env:TEMP\VSCode.zip"
    $extractDir = "$InstallRoot\VSCode"

    if (Invoke-Download $url $dest) {
        if (!(Test-Path $extractDir)) { New-Item -ItemType Directory -Path $extractDir -Force | Out-Null }
        Expand-Archive -Path $dest -DestinationPath $extractDir -Force
        Remove-Item $dest -Force -ErrorAction SilentlyContinue
        
        Add-ToPath "$extractDir\bin"
        
        Write-Ok "VSCode 宸插畨瑁呭埌 $extractDir"
    }
}

function Install-Claude {
    Write-Step "瀹夎 Claude Code..."

    # 鍏堣渚濊禆
    if (!(Test-Command git)) { Install-Git }
    if (!(Test-Command node)) { Install-Node }

    if (Test-Command claude) {
        Write-Ok "Claude Code 宸插畨瑁? $(Get-Version claude)"
        return
    }

    if (!(Test-Command npm)) {
        Write-Fail "npm 鏈壘鍒帮紝Node.js 鍙兘鏈纭厤缃?
        return
    }

    Write-Info "姝ｅ湪瀹夎 @anthropic-ai/claude-code..."
    & "$env:SystemRoot\System32\cmd.exe" /c "npm install -g @anthropic-ai/claude-code"
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "瀹夎澶辫触锛屽皾璇曢€氳繃鍥藉唴 npm 闀滃儚鍔犻€?.."
        & "$env:SystemRoot\System32\cmd.exe" /c "npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com"
    }

    # 灏濊瘯纭繚 global npm 鐩綍瀛樺湪浜?PATH 鍙橀噺
    try {
        $npmPrefix = & "$env:SystemRoot\System32\cmd.exe" /c "npm config get prefix" | Out-String
        if ($npmPrefix) {
            $npmPrefix = $npmPrefix.Trim()
            Add-ToPath $npmPrefix
        }
    } catch {}

    if (Test-Command claude) {
        Write-Ok "Claude Code 宸插畨瑁? $(Get-Version claude)"
        Register-ClaudePlugins
    } else {
        Write-Fail "Claude Code 瀹夎澶辫触"
    }
}

function Register-ClaudePlugins {
    Write-Step "娉ㄥ唽 Claude Code 鎻掍欢..."

    $oldErr = $ErrorActionPreference
    $ErrorActionPreference = "Continue"

    # 浼樺厛璺宠繃 onboarding 宸ヤ綔娴侊紝闃叉绗竴娆¤繍琛?claude CLI 琚簰鍔ㄦ彁绀哄崱姝诲け璐?
    Write-Info "鍒濆鍖?Claude Code 閰嶇疆..."
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
    Write-Ok "Onboarding 宸茶烦杩?

    # Jupyter MCP
    Write-Info "娉ㄥ唽 Jupyter MCP..."
    claude mcp add jupyter "http://127.0.0.1:8888/mcp"
    if ($LASTEXITCODE -eq 0) { Write-Ok "Jupyter MCP 宸叉敞鍐? } else { Write-Warn "Jupyter MCP 娉ㄥ唽澶辫触" }

    $ErrorActionPreference = $oldErr
    Write-Ok "鎻掍欢娉ㄥ唽瀹屾垚"
}

# -------------------- 涓?--------------------
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
        Write-Host "鐢ㄦ硶: .\install.ps1 [all|git|node|python|vscode|claude]"
        Write-Host ""
        Write-Host "  all     瀹夎鍏ㄩ儴锛堥粯璁わ級"
        Write-Host "  git     浠呭畨瑁?Git"
        Write-Host "  node    浠呭畨瑁?Node.js"
        Write-Host "  python  浠呭畨瑁?Python"
        Write-Host "  vscode  浠呭畨瑁?VSCode"
        Write-Host "  claude  浠呭畨瑁?Claude Code"
    }
}

Write-Host ""
