# Concurrency Course - Easy Launcher
# This script provides a simple menu for students

function Show-Menu {
    Clear-Host
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "  Java Concurrency Course" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Choose an option:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Start & Open Shell" -ForegroundColor Green
    Write-Host "      (Opens interactive terminal in container)"
    Write-Host ""
    Write-Host "  [2] Run Application" -ForegroundColor Green
    Write-Host "      (Builds and runs your Java code)"
    Write-Host ""
    Write-Host "  [3] Check Status" -ForegroundColor Green
    Write-Host "      (Shows if container is running)"
    Write-Host ""
    Write-Host "  [4] Stop & Cleanup" -ForegroundColor Yellow
    Write-Host "      (Stops all containers)"
    Write-Host ""
    Write-Host "  [5] Rebuild Environment" -ForegroundColor Magenta
    Write-Host "      (Use if something is broken)"
    Write-Host ""
    Write-Host "  [Q] Quit" -ForegroundColor Red
    Write-Host ""
}

function Wait-ForKey {
    Write-Host ""
    Write-Host "Press any key to continue..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

do {
    Show-Menu
    $choice = Read-Host "Enter your choice"
    
    switch ($choice.ToUpper()) {
        "1" {
            Write-Host "`nStarting shell..." -ForegroundColor Cyan
            .\scripts\course.ps1 shell
            Wait-ForKey
        }
        "2" {
            Write-Host "`nRunning application..." -ForegroundColor Cyan
            .\scripts\course.ps1 run
            Wait-ForKey
        }
        "3" {
            Write-Host "`nChecking status..." -ForegroundColor Cyan
            .\scripts\course.ps1 status
            Wait-ForKey
        }
        "4" {
            Write-Host "`nStopping containers..." -ForegroundColor Yellow
            .\scripts\course.ps1 down
            Write-Host "`nAll containers stopped!" -ForegroundColor Green
            Wait-ForKey
        }
        "5" {
            Write-Host "`nRebuilding environment..." -ForegroundColor Magenta
            Write-Host "This may take a few minutes..." -ForegroundColor Yellow
            .\scripts\course.ps1 rebuild
            Wait-ForKey
        }
        "Q" {
            Write-Host "`nGoodbye! Happy coding! 👋" -ForegroundColor Cyan
            break
        }
        default {
            Write-Host "`nInvalid choice. Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($choice.ToUpper() -ne "Q")
