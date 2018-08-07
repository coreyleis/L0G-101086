# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2018 Jacob Keller. All rights reserved.

# This script is deprecated, and is in need of a replacement now that we have migrated
# to the v2 configuration format

# Terminate on all errors...
$ErrorActionPreference = "Stop"

# Load the shared module
Import-Module -Force -DisableNameChecking (Join-Path -Path $PSScriptRoot -ChildPath l0g-101086.psm1)

# Path to JSON-formatted configuration file
$config_file = "cptnfool-config.json"
$backup_file = "${config-file}.bk"

# discord_map
#
# The discord_map is a mapping of GW2 account names to discord user
# ids. It should be a hash map keyed by the GW2 account name. The
# discord user IDs are expected to be the full hiddden ID of the
# player mention as shown by typing \@discord name (for example
# "\@serenamyr#8942") into a discord channel. You can also find it
# by enabling the Developer tools configuration in Discord and then
# right clicking a player mention and selecting "Copy ID"
#
# This is expected to be a hash table

if (X-Test-Path $backup_file) {
    Read-Host -Prompt "Please remove the backup file before running this script. Press enter to exit"
    exit
}

# Load the configuration from the default file
$config = Load-Configuration $config_file 1
if (-not $config) {
    exit
}

# Check if the token has already been set
if ($config.discord_map) {
    Write-Output "A discord account map already exists."

    # offer to delete any current mappings
    $config.discord_map | Get-Member -Type NoteProperty | where { $config.discord_map."$($_.Name)" -is [string] } | ForEach-Object {
        $delete = Read-Host -Prompt "Delete mapping for $($_.Name))? (Y/N)"
        if ($delete -eq "Y") {
            $config.discord_map.PSObject.Members.Remove($_.Name)
        }
    }
}

# ask if the user wants to add more mappings
do {
    Write-Output = ""
    $add = Read-Host -Prompt "Would you like to add a new mappping? (Y/N)"
    if ($add -eq "Y") {
        Write-Output "I need a Guild Wars 2 account name and the assiocated discord id"
        Write-Output "To generate the discord id you can enter their mention into a"
        Write-Output "discord channel, prefixed by a backslash"
        Write-Output ""
        $gw2name = Read-Host -Prompt "GW2 account name"
        $discord = Read-Host -Prompt "Discord id"
        if ((-not $gw2name) -or (-not $discord)) {
            continue
        }
        $config.discord_map[$gw2name] = $discord
    }
} while ($add -eq "Y")

# Write the configuration file out
Copy-Item -Path $config_file -Destination $backup_file
$config | ConvertTo-Json -Depth 10 | Out-File -Force $config_file

Read-Host -Prompt "Configured the discord account map. Press enter to exit"
exit

