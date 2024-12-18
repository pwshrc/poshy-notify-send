#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
#Requires -Modules @{ ModuleName = "poshy-lucidity"; RequiredVersion = "0.4.1" }


[string] $terminalnotifier_bin = Search-CommandPath terminal-notifier
if ($terminalnotifier_bin) {
    # for macOS, output is "app ID, window ID" (com.googlecode.iterm2, 116)
    function get-current-appid-windowid-pair {
        if (Test-Command osascript) {
            return (osascript -e 'tell application (path to frontmost application as text) to get the {id, id of front window}' 2> $null)
        } elseif (Test-Command xprop) {
            [string] $xpropResult = (xprop -root _NET_ACTIVE_WINDOW 2> $null)
            return ($xpropResult.Trim() -split ' ')[5]
        } else {
            [int] $unixEpochSeconds = (Get-Date -UFormat %s)
            return $unixEpochSeconds
        }
    }

    function ensure-current-appid-windowid-pair {
        Set-Variable -Name notifysend_appid_windowid_pair -Value (get-current-appid-windowid-pair)
    }

    Set-Variable -Name notifysend_appid_windowid_pair_retrieval_job -Value (
        Start-Job -ScriptBlock ${function:ensure-current-appid-windowid-pair}
    ) -Scope Global -Option AllScope

    function notify-send-terminalnotifier {
        param(
            [Parameter(Mandatory=$true, Position=0)]
            [string] $Title,

            [Parameter(Mandatory=$true, Position=1)]
            [string] $Message
        )
        if (-not $Global:notifysend_appid_windowid_pair) {
            Receive-Job -Job $Global:notifysend_appid_windowid_pair_retrieval_job -Keep
        }
        [string] $term_id = (
            $Global:notifysend_appid_windowid_pair -split ',' | Select-Object -First 1
        )
        if (-not $term_id) {
            switch ($Env:TERM_PROGRAM) {
                'iTerm.app' { $term_id='com.googlecode.iterm2' }
                'Apple_Terminal' { $term_id='com.apple.terminal' }
            }
        }

        if (-not $term_id) {
            & $terminalnotifier_bin -message $Message -title $Title | Out-Null
        } else {
            & $terminalnotifier_bin -message $Message -title $Title -activate "$term_id" -sender "$term_id" | Out-Null
        }
    }
    Export-ModuleMember -Function notify-send-terminalnotifier
}
