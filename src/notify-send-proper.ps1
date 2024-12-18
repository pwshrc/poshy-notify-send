#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
#Requires -Modules @{ ModuleName = "poshy-lucidity"; RequiredVersion = "0.4.1" }


[string] $notifysend_bin = Search-CommandPath notify-send
if ($notifysend_bin) {
    function notify-send-proper {
        param(
            [Parameter(Mandatory=$true, Position=0)]
            [string] $Title,

            [Parameter(Mandatory=$true, Position=1)]
            [string] $Message
        )
        & $notifysend_bin $Title $Message
    }
    Export-ModuleMember -Function notify-send-proper
}
