#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


if (-not (Get-Module BurntToast -ErrorAction SilentlyContinue)) {
    if (Get-Module -ListAvailable BurntToast) {
        Import-Module BurntToast
    }
}
if (Get-Module BurntToast -ErrorAction SilentlyContinue) {
    function notify-send-burnttoast {
        param(
            [Parameter(Mandatory=$true, Position=0)]
            [string] $Title,

            [Parameter(Mandatory=$true, Position=1)]
            [string] $Message,

            [Parameter(Mandatory=$false, Position=2)]
            [ValidateRange(1, [int]::MaxValue)]
            [int] $TimeoutSeconds = 5
        )
        [DateTime] $expiry = (Get-Date).AddSeconds($TimeoutSeconds)
        New-BurntToastNotification -Text @($Title, $Message) -ExpirationTime $expiry
    }
    Export-ModuleMember -Function notify-send-burnttoast
}
