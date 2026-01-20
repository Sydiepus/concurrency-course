# Fix Gradle Wrapper for Offline / Classroom Use
# - Forces all gradle-wrapper.properties to use local Gradle zip
# - Adds SHA256 verification
# - Removes broken multi-line or remote URLs
# - Safe to run multiple times

$ErrorActionPreference = "Stop"

$GRADLE_ZIP_PATH = "file:/workspace/tools/gradle/gradle-8.10.2-bin.zip"
$GRADLE_SHA256 = "31c55713e40233a8303827ceb42ca48a47267a0ad4bab9177123121e71524c26"

Write-Host "🔧 Fixing Gradle wrappers (offline mode)...`n"

# Find all gradle-wrapper.properties files
$wrappers = Get-ChildItem -Path . -Recurse -Filter "gradle-wrapper.properties"

if ($wrappers.Count -eq 0) {
    Write-Host "⚠️  No gradle-wrapper.properties files found."
    exit 0
}

foreach ($file in $wrappers) {
    Write-Host "→ Processing $($file.FullName)"

    $lines = Get-Content $file.FullName

    # Remove any existing distributionUrl or distributionSha256Sum
    $lines = $lines | Where-Object {
        $_ -notmatch '^distributionUrl=' -and
        $_ -notmatch '^distributionSha256Sum='
    }

    $fixed = @()
    $inserted = $false

    foreach ($line in $lines) {
        $fixed += $line

        # Insert after distributionBase if present
        if (-not $inserted -and $line -match '^distributionBase=') {
            $fixed += "distributionUrl=$GRADLE_ZIP_PATH"
            $fixed += "distributionSha256Sum=$GRADLE_SHA256"
            $inserted = $true
        }
    }

    # If distributionBase wasn't found, prepend
    if (-not $inserted) {
        $fixed = @(
            "distributionUrl=$GRADLE_ZIP_PATH"
            "distributionSha256Sum=$GRADLE_SHA256"
        ) + $fixed
    }

    Set-Content -Encoding ascii -Path $file.FullName -Value $fixed
}

Write-Host "`n✅ Gradle wrappers fixed."
Write-Host "   • Offline Gradle enabled"
Write-Host "   • SHA256 verification enforced"
Write-Host "   • Safe for Docker / classrooms"
Write-Host "`nNext step: docker compose up -d --build`n"
