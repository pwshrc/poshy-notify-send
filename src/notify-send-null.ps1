#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function notify-send-null {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $Title,

        [Parameter(Mandatory=$true, Position=1)]
        [string] $Message
    )
}
Export-ModuleMember -Function notify-send-null
