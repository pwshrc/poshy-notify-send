#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
#Requires -Modules @{ ModuleName = "poshy-lucidity"; RequiredVersion = "0.4.1" }


if ((-not ($Env:SSH_CONNECTION)) -and (Test-SessionInteractivity)) {
    $active_implementations = @(Get-ChildItem -Path Function:\ | Where-Object { $_.Name -like "notify-send-*" })

    if ($active_implementations) {
        $preferred_implementation = $active_implementations | Sort-Object -Property Name | Select-Object -First 1
        Set-Alias -Name notify-send -Value $preferred_implementation.Name
    } else {
        . "$PSScriptRoot/notify-send-fallback.ps1"
        Set-Alias -Name notify-send -Value notify-send-fallback
    }
} else {
    . "$PSScriptRoot/notify-send-null.ps1"
    Set-Alias -Name notify-send -Value notify-send-null
}

Export-ModuleMember -Alias notify-send
