param(
    [ValidateSet("up", "run", "down", "shell", "status", "rebuild", "stop-daemon")]
    [string]$cmd = "up"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Always run relative to repo root
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$composeFile = "tools/docker-compose.yml"
$weekLin = "/workspace/labs/java-concurrency/week-01-threads"

function Ensure-Docker() {
    try { docker version | Out-Null }
    catch { throw "Docker is not running. Start Docker Desktop, then retry." }
}

function RunCompose {
    $allArgs = @($args)   # ensure array
    $commandStr = ($allArgs -join " ")
    Write-Host ">> docker compose -f $composeFile $commandStr"

    $dockerArgs = @("compose", "-f", $composeFile) + $allArgs
    & docker @dockerArgs

    if ($LASTEXITCODE -ne 0) {
        throw "Compose failed: $commandStr"
    }
}


function Ensure-Up([switch]$Build) {
    if ($Build) { 
        RunCompose "up" "-d" "--build"
    }
    else { 
        RunCompose "up" "-d"
    }

    # Safe permission fix for named gradle-cache volume
    RunCompose "exec" "-u" "root" "dev" "bash" "-lc" "mkdir -p /home/vscode/.gradle && chown -R vscode:vscode /home/vscode/.gradle"

    # Delete project .gradle (wrong ownership sometimes)
    RunCompose "exec" "-u" "root" "dev" "bash" "-lc" "rm -rf $weekLin/.gradle || true"
}

switch ($cmd) {

    "up" {
        Ensure-Docker
        Ensure-Up -Build

        RunCompose "exec" "dev" "bash" "-lc" "java -version 2>&1 | head -n 2"
        RunCompose "exec" "dev" "bash" "-lc" "cd $weekLin && ./gradlew --version 2>&1 | head -n 12"

        Write-Host ""
        Write-Host "OK. Next:"
        Write-Host "  .\scripts\course.ps1 run"
        Write-Host "  .\scripts\course.ps1 shell"
        Write-Host "  .\scripts\course.ps1 down"
    }

    "rebuild" {
        Ensure-Docker
        Ensure-Up -Build
        Write-Host "Rebuild done."
    }

    "run" {
        Ensure-Docker
        Ensure-Up
        RunCompose "exec" "dev" "bash" "-lc" "cd $weekLin && ./gradlew clean run"
    }

    "shell" {
        Ensure-Docker
        Ensure-Up
        RunCompose "exec" "dev" "bash"
    }

    "status" {
        Ensure-Docker
        RunCompose "ps"
    }

    "stop-daemon" {
        Ensure-Docker
        Ensure-Up
        RunCompose "exec" "dev" "bash" "-lc" "cd $weekLin && ./gradlew --stop || true"
    }

    "down" {
        try { RunCompose "down" }
        catch { Write-Host ">> Docker not running; nothing to stop." -ForegroundColor Yellow }
    }
}
