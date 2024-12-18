#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
#Requires -Modules @{ ModuleName = "poshy-lucidity"; RequiredVersion = "0.4.1" }


$IsWSL = (Get-Variable -Name IsWSL -ValueOnly -ErrorAction SilentlyContinue) -or (Test-Path Env:\WSL_DISTRO_NAME -ErrorAction SilentlyContinue)
[string] $wslnotifysend_bin = Search-CommandPath wsl-notify-send.exe
if ($IsWSL -and $wslnotifysend_bin) {
    function notify-send-wsl {
        param(
            [Parameter(Mandatory=$true, Position=0)]
            [string] $Title,

            [Parameter(Mandatory=$true, Position=1)]
            [string] $Message
        )
        & $wslnotifysend_bin --category \"${Env:WSL_DISTRO_NAME}\" $Title $Message
    }
    Export-ModuleMember -Function notify-send-wsl
}
