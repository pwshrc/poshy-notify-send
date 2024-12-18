#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
#Requires -Modules @{ ModuleName = "poshy-lucidity"; RequiredVersion = "0.4.1" }


[string] $notifu_bin = Search-CommandPath notifu
if ($notifu_bin) {
    function notify-send-notifu {
        param(
            [Parameter(Mandatory=$true, Position=0)]
            [string] $Title,

            [Parameter(Mandatory=$true, Position=1)]
            [string] $Message,

            [Parameter(Mandatory=$false, Position=2)]
            [ValidateRange(1, [int]::MaxValue)]
            [int] $TimeoutSeconds = 5
        )
        [int] $timeoutMilliseconds = $TimeoutSeconds * 1000
        & $notifu_bin /m $Message /p $Title /d $timeoutMilliseconds
    }
    Export-ModuleMember -Function notify-send-notifu
}
