#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
#Requires -Modules @{ ModuleName = "poshy-lucidity"; RequiredVersion = "0.4.1" }


[string] $kdialog_bin = Search-CommandPath kdialog
if ($kdialog_bin) {
    function notify-send-kdialog {
        param(
            [Parameter(Mandatory=$true, Position=0)]
            [string] $Title,

            [Parameter(Mandatory=$true, Position=1)]
            [string] $Message,

            [Parameter(Mandatory=$false, Position=2)]
            [ValidateRange(1, [int]::MaxValue)]
            [int] $TimeoutSeconds = 5
        )
        & $kdialog_bin --title $Title --passivepopup $Message $TimeoutSeconds
    }
    Export-ModuleMember -Function notify-send-kdialog
}
