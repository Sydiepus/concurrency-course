param([switch]$SkipWSL)

$ErrorActionPreference = "Continue"

$composeFile = "tools/docker-compose.yml"
$weekWin = "labs/java-concurrency/week-01-threads"
$weekLin = "/workspace/labs/java-concurrency/week-01-threads"

# ---------------- state ----------------
$script:ready = $true
$script:firstFail = $null
$script:checkNum = 0

# ---------------- ui helpers ----------------
function Ok($m) { Write-Host "   $m" -ForegroundColor Green }
function Fail($m) { Write-Host "   $m" -ForegroundColor Red }
function Info($m) {
    if ([string]::IsNullOrWhiteSpace($m)) { $m = "(no output)" }
    Write-Host "     $m" -ForegroundColor Cyan
}
function Check($name) {
    $script:checkNum++
    Write-Host "[$script:checkNum] $name..." -ForegroundColor Yellow
}
function MarkFail($name) {
    if (-not $script:firstFail) { $script:firstFail = $name }
    $script:ready = $false
}

# ---------------- header ----------------
Clear-Host
Write-Host "" -ForegroundColor Cyan
Write-Host "  Concurrency Course - System Doctor       " -ForegroundColor Cyan
Write-Host "" -ForegroundColor Cyan
Write-Host ""
Write-Host "This tool checks if your environment is ready for the course." -ForegroundColor White
Write-Host "Location: $((Get-Location).Path)" -ForegroundColor Gray
Write-Host ""

# 1) Docker CLI
Check "Docker CLI"
try {
    $output = docker --version 2>&1
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) { $exitCode = 0 }
    $r = @{ code = $exitCode; out = ($output | Out-String).Trim() }
}
catch {
    $r = @{ code = 1; out = $_.Exception.Message }
}

if ($r.code -eq 0 -and $r.out -match "Docker version") {
    Ok "Docker CLI is installed"
    Info $r.out
}
else {
    Fail "Docker CLI not found"
    Info $r.out
    Info "Fix: Install Docker Desktop from https://docker.com"
    Info "      Then restart PowerShell"
    MarkFail "Docker CLI"
}

# 2) Docker daemon
Check "Docker Daemon"
try {
    $output = docker version 2>&1
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) { $exitCode = 0 }
    $r = @{ code = $exitCode; out = ($output | Out-String).Trim() }
}
catch {
    $r = @{ code = 1; out = $_.Exception.Message }
}

if ($r.code -eq 0 -and $r.out -match "Server:") {
    Ok "Docker daemon is running"
}
else {
    Fail "Docker daemon not reachable"
    Info "Fix: Start Docker Desktop and wait until it shows 'Running'"
    Info "      You should see the Docker icon in your system tray"
    MarkFail "Docker daemon"
}

# 3) Docker Compose
Check "Docker Compose"
try {
    $output = docker compose version 2>&1
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) { $exitCode = 0 }
    $r = @{ code = $exitCode; out = ($output | Out-String).Trim() }
}
catch {
    $r = @{ code = 1; out = $_.Exception.Message }
}

if ($r.code -eq 0 -and $r.out -match "Docker Compose version") {
    Ok "Docker Compose is available"
    Info $r.out
}
else {
    Fail "Docker Compose not available"
    Info "Fix: Update Docker Desktop (Compose is included)"
    MarkFail "Docker Compose"
}

# 4) WSL2 optional (info only)
if (-not $SkipWSL) {
    Check "WSL2 (optional)"
    try {
        $output = wsl -l -v 2>&1
        $exitCode = $LASTEXITCODE
        if ($null -eq $exitCode) { $exitCode = 0 }
        if ($exitCode -eq 0 -and ($output | Out-String) -match "\s2\s") {
            Ok "WSL2 is installed (recommended for better performance)"
        }
        else {
            Info "WSL2 not detected (this is okay - Docker can run without it)"
        }
    }
    catch {
        Info "WSL2 not detected (this is okay - Docker can run without it)"
    }
}

# 5) Files exist
Check "Required Files"

if (Test-Path $composeFile) {
    Ok "Found $composeFile"
}
else {
    Fail "Missing $composeFile"
    Info "Fix: Make sure you're running this from the repository root"
    MarkFail "compose file missing"
}

if (Test-Path ".devcontainer/Dockerfile") {
    Ok "Found .devcontainer/Dockerfile"
}
else {
    Fail "Missing .devcontainer/Dockerfile"
    Info "Fix: Restore from git: git checkout .devcontainer/Dockerfile"
    MarkFail "dockerfile missing"
}

if (Test-Path $weekWin) {
    Ok "Found $weekWin"
}
else {
    Fail "Missing $weekWin"
    Info "Fix: Repository may be incomplete or you're in the wrong folder"
    MarkFail "week-01 missing"
}

# Stop early if basics failed
if (-not $script:ready) {
    Write-Host ""
    Write-Host "" -ForegroundColor Red
    Write-Host "              SETUP INCOMPLETE              " -ForegroundColor Red
    Write-Host "" -ForegroundColor Red
    Write-Host ""
    Fail "Environment is NOT ready"
    Info "First problem found: $($script:firstFail)"
    Write-Host ""
    Info "After fixing the issues above, run the doctor again:"
    Info "  .\scripts\doctor.ps1"
    Write-Host ""
    exit 1
}

# 6) Start dev container
Check "Building and Starting Container"
Write-Host "    (This may take a few minutes on first run...)" -ForegroundColor Gray
try {
    $output = docker compose -f $composeFile up -d --build 2>&1
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) { $exitCode = 0 }
    $r = @{ code = $exitCode; out = ($output | Out-String).Trim() }
}
catch {
    $r = @{ code = 1; out = $_.Exception.Message }
}

if ($r.code -eq 0) {
    Ok "Container started successfully"
}
else {
    Fail "Failed to start container"
    Info "Fix: Try cleaning and rebuilding:"
    Info "      docker compose -f $composeFile down"
    Info "      docker compose -f $composeFile build --no-cache"
    MarkFail "compose up"
}

# 7) Java in container
Check "Java Installation"
try {
    $output = docker compose -f $composeFile exec -T dev java -version 2>&1
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) { $exitCode = 0 }
    $r = @{ code = $exitCode; out = ($output | Out-String).Trim() }
}
catch {
    $r = @{ code = 1; out = $_.Exception.Message }
}

if ($r.code -eq 0 -and $r.out -match "openjdk") {
    Ok "Java is working inside container"
    $firstLine = ($r.out -split "`n")[0]
    Info $firstLine
}
else {
    Fail "Java not working in container"
    Info "Fix: Rebuild the container:"
    Info "      docker compose -f $composeFile down"
    Info "      docker compose -f $composeFile up -d --build"
    MarkFail "java"
}

# 8) Fix gradle permissions
Check "Setting up Gradle"
try {
    docker compose -f $composeFile exec -T -u root dev bash -c "mkdir -p /home/vscode/.gradle && chown -R vscode:vscode /home/vscode/.gradle" 2>&1 | Out-Null
    Ok "Gradle permissions configured"
}
catch {
    Info "Could not set Gradle permissions (may not be critical)"
}

# 9) Gradle wrapper - FIXED CHECK
Check "Gradle Build System"

# First, fix gradlew permissions as root
try {
    docker compose -f $composeFile exec -T -u root dev bash -c "cd $weekLin && chmod +x gradlew" 2>&1 | Out-Null
}
catch {
    # Ignore permission fix errors
}

try {
    # Now run gradle as regular user
    $output = docker compose -f $composeFile exec dev bash -c "cd $weekLin && ./gradlew --version 2>&1" 2>&1
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) { $exitCode = 0 }
    $outStr = ($output | Out-String).Trim()
    
    # Check for both Gradle version pattern AND successful exit code
    if ($exitCode -eq 0 -and ($outStr -match "Gradle\s+[\d\.]+" -or $outStr -match "------------------------------------------------------------")) {
        Ok "Gradle is working correctly"
        # Extract and show the Gradle version line
        $gradleLine = ($outStr -split "`n" | Where-Object { $_ -match "^Gradle\s+[\d\.]+" } | Select-Object -First 1)
        if ($gradleLine) { 
            Info $gradleLine.Trim()
        }
        else {
            Info "Gradle wrapper is functional"
        }
    }
    else {
        Fail "Gradle not working properly"
        if ($outStr) {
            Info "Output: $outStr"
        }
        Info "Exit code: $exitCode"
        Info "Fix: Clean the Gradle cache and try again:"
        Info "      docker compose -f $composeFile exec -u root dev bash -c 'rm -rf $weekLin/.gradle'"
        Info "      .\scripts\doctor.ps1"
        MarkFail "gradle wrapper"
    }
}
catch {
    Fail "Gradle check failed with exception"
    Info $_.Exception.Message
    MarkFail "gradle wrapper"
}

# Final summary
Write-Host ""
Write-Host "" -ForegroundColor $(if ($script:ready) { "Green" } else { "Red" })
Write-Host "                  SUMMARY                   " -ForegroundColor $(if ($script:ready) { "Green" } else { "Red" })
Write-Host "" -ForegroundColor $(if ($script:ready) { "Green" } else { "Red" })
Write-Host ""

if ($script:ready) {
    Write-Host "   All checks passed! Your environment is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Run the course launcher:" -ForegroundColor White
    Write-Host "     .\start.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  2. Or use individual commands:" -ForegroundColor White
    Write-Host "     .\scripts\course.ps1 shell   # Open shell" -ForegroundColor Cyan
    Write-Host "     .\scripts\course.ps1 run     # Run your code" -ForegroundColor Cyan
    Write-Host "     .\scripts\course.ps1 down    # Stop everything" -ForegroundColor Cyan
    Write-Host ""
}
else {
    Write-Host "   Some checks failed" -ForegroundColor Red
    Write-Host ""
    Info "First problem: $($script:firstFail)"
    Write-Host ""
    Info "After fixing the issues, run the doctor again:"
    Info "  .\scripts\doctor.ps1"
    Write-Host ""
    exit 1
}
