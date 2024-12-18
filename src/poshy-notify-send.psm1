#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


. "$PSScriptRoot/notify-send-burnttoast.ps1"

. "$PSScriptRoot/notify-send-growlnotify.ps1"

. "$PSScriptRoot/notify-send-kdialog.ps1"

. "$PSScriptRoot/notify-send-notifu.ps1"

. "$PSScriptRoot/notify-send-proper.ps1"

. "$PSScriptRoot/notify-send-terminalnotifier.ps1"

. "$PSScriptRoot/notify-send-wsl.ps1"


. "$PSScriptRoot/_export_alias.ps1"
