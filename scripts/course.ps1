param(
  [ValidateSet("up","run","down","shell","status")]
  [string]$cmd = "up"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Always run relative to repo root
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$compose = "docker compose -f tools/docker-compose.yml"

function Run($s) {
  Write-Host ">> $s"
  iex $s
}

function Ensure-Docker() {
  try { Run "docker version | Out-Null" } catch {
    throw "Docker is not running. Start Docker Desktop, then retry."
  }
}

switch ($cmd) {

  "up" {
    Ensure-Docker
    Run "$compose up -d --build"

    # One-time permission fix for the named volume (safe to repeat)
    Run "$compose exec -u root dev bash -lc `"mkdir -p /home/vscode/.gradle && chown -R vscode:vscode /home/vscode/.gradle`""

    # Basic diagnostics
    Run "$compose exec dev bash -lc `"java -version`""
    Run "$compose exec dev bash -lc `"cd /workspace/labs/java-concurrency/week-01-threads && ./gradlew --version`""

    Write-Host ""
    Write-Host "OK. Next:"
    Write-Host "  .\scripts\course.ps1 run"
    Write-Host "  .\scripts\course.ps1 shell"
    Write-Host "  .\scripts\course.ps1 down"
  }

  "run" {
    Ensure-Docker
    Run "$compose exec dev bash -lc `"cd /workspace/labs/java-concurrency/week-01-threads && ./gradlew run`""
  }

  "shell" {
    Ensure-Docker
    Run "$compose exec dev bash"
  }

  "status" {
    Ensure-Docker
    Run "$compose ps"
  }

  "down" {
    Ensure-Docker
    Run "$compose down"
  }
}
