#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
#Requires -Modules @{ ModuleName = "poshy-lucidity"; RequiredVersion = "0.4.1" }


if ((-not ($Env:SSH_CONNECTION)) -and (Test-SessionInteractivity)) {
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
        Set-Alias -Name notify-send -Value notify-send-proper -Option AllScope
        Export-ModuleMember -Function notify-send-proper -Alias notify-send
        return
    }


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
        Set-Alias -Name notify-send -Value notify-send-wsl -Option AllScope
        Export-ModuleMember -Function notify-send-wsl -Alias notify-send
        return
    }


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
        Set-Alias -Name notify-send -Value notify-send-growlnotify -Option AllScope
        Export-ModuleMember -Function notify-send-growlnotify -Alias notify-send
        return
    }


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
        Set-Alias -Name notify-send -Value notify-send-kdialog -Option AllScope
        Export-ModuleMember -Function notify-send-kdialog -Alias notify-send
        return
    }


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
        Set-Alias -Name notify-send -Value notify-send-notifu -Option AllScope
        Export-ModuleMember -Function notify-send-notifu -Alias notify-send
        return
    }


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
        Set-Alias -Name notify-send -Value notify-send-terminalnotifier -Option AllScope
        Export-ModuleMember -Function notify-send-terminalnotifier -Alias notify-send
        return
    }


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
        Set-Alias -Name notify-send -Value notify-send-burnttoast -Option AllScope
        Export-ModuleMember -Function notify-send-burnttoast -Alias notify-send
        return
    }
}


if (-not (Get-Command notify-send -ErrorAction SilentlyContinue)) {
    function notify-send-fallback {
        param(
            [Parameter(Mandatory=$true, Position=0)]
            [string] $Title,

            [Parameter(Mandatory=$true, Position=1)]
            [string] $Message
        )
        if (-not (Test-SessionInteractivity)) {
            throw [System.InvalidOperationException] "notify-send requires a session with interactivity."
        } else {
            Write-Error "No notification backend found. Please install one of the following, as appropriate for the platform: notify-send, wsl-notify-send, growlnotify, kdialog, notifu, terminal-notifier, or BurntToast."
        }
    }
    Set-Alias -Name notify-send -Value notify-send-fallback -Option AllScope
    Export-ModuleMember -Function notify-send-fallback -Alias notify-send
    return
}
