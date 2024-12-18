#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function notify-send-fallback {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $Title,

        [Parameter(Mandatory=$true, Position=1)]
        [string] $Message
    )
    Write-Error "poshy-notify-send: No notification backend found. Please install one of the following, as appropriate for the platform: notify-send, wsl-notify-send, growlnotify, kdialog, notifu, terminal-notifier, or BurntToast."
}
Export-ModuleMember -Function notify-send-fallback
