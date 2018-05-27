# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2018 Jacob Keller. All rights reserved.

# This script is used to ease the burden of generating a gw2raidar token. Feel free
# to use https://www.gw2raidar.com/api/v2/swagger instead, if you do not trust
# this script with your username and password.

# Terminate on all errors...
$ErrorActionPreference = "Stop"

# Path to JSON-formatted configuration file
$config_file = "l0g-101086-config.json"
$backup_file = "${config_file}.bk"

# emoji_map
#
# The emoji data is a map which stores the specific discord ID that maps to the emoji
# that you wish to display for each boss. This can be found by typing "\emoji" into
# a discord channel, and should return a link similar to <emoji123456789> which you
# need to place into a hash map keyed by the boss name.

# Test a path for existence, safe against $null
Function X-Test-Path($path) {
    return $(try { Test-Path $path.trim() } catch { $false })
}

# Make sure the configuration file exists
if (-not (X-Test-Path $config_file)) {
    Read-Host -Prompt "Unable to locate the configuration file. Copy and edit the sample configuration? Press enter to exit"
    exit
}

if (X-Test-Path $backup_file) {
    Read-Host -Prompt "Please remove the backup file before running this script. Press enter to exit"
    exit
}

$config = Get-Content -Raw -Path $config_file | ConvertFrom-Json

# Allow path configurations to contain %UserProfile%, replacing them with the environment variable
$config | Get-Member -Type NoteProperty | where { $config."$($_.Name)" -is [string] } | ForEach-Object {
    $config."$($_.Name)" = ($config."$($_.Name)").replace("%UserProfile%", $env:USERPROFILE)
}

# Check if the token has already been set
if ($config.emoji_map) {
    try {
        [ValidateSet('Y','N')]$continue = Read-Host -Prompt "An emoji map appears to already be configured. Comtinue? (Y/N)"
    } catch {
        # Just exit on an invalid response
        exit
    }
    if ($continue -ne "Y") {
        exit
    }
}

$emoji_map = @{"Mursaat Overseer"="";
               "Samarog"="";
               "Slothasor"="";
               "Sabetha"="";
               "Dhuum"="";
               "Gorseval"="";
               "Xera"="";
               "Soulless Horror"="";
               "Cairn"="";
               "Keep Construct"="";
               "Matthias"="";
               "Deimos"="";
               "Vale Guardian"=""}

Write-Output "Fill in the discord emoji id you would like to use for each boss."
Write-Output "To generate this, type \:emoji: ino a channel of your server."
Write-Output ""

$emoji_map.GetEnumerator() | Sort-Object -Property { $_.Key } | ForEach-Object {
    $emoji_map[$_.Key] = Read-Host -Prompt "$($_.Key)?"
}

# Store the new map into the configuration
$config.emoji_map = $emoji_map

# Write the configuration file out
Copy-Item -Path $config_file -Destination $backup_file
$config | ConvertTo-Json -Depth 10 | Out-File -Force $config_file

Read-Host -Prompt "Configured the emoji map. Press enter to exit"
exit

