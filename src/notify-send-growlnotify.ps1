#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
#Requires -Modules @{ ModuleName = "poshy-lucidity"; RequiredVersion = "0.4.1" }


[string] $growlnotify_bin = Search-CommandPath growlnotify
if ($growlnotify_bin) {
    function notify-send-growlnotify {
        param(
            [Parameter(Mandatory=$true, Position=0)]
            [string] $Title,

            [Parameter(Mandatory=$true, Position=1)]
            [string] $Message
        )
        & $growlnotify_bin -m $Message $Title
    }
    Export-ModuleMember -Function notify-send-growlnotify
}
