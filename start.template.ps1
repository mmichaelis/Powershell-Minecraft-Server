# 
# Template for Starting Minecraft Server
# Will be copied to Minecraft Server Folders once
# Minecraft is installed.
#

Function Forbid-RunTemplate {
  [String] $MyName = "$(Split-Path -Leaf $PSCommandpath)"

  if ($MyName -eq "start.template.ps1") {
    Write-Host "Failure: You are trying to start the template."
    Write-Host ""
    Write-Host "Please install Minecraft Server first and then"
    Write-Host "Run this script from the server directory."
    Exit 1
  }
}

Forbid-RunTemplate

[String] $InstallerDir = "$(Join-Path $PSScriptRoot ".." -Resolve)"
[String] $OutFile = Join-Path -Path "${PSScriptRoot}" -ChildPath "minecraft.out.txt"
[String] $ErrFile = Join-Path -Path "${PSScriptRoot}" -ChildPath "minecraft.err.txt"

. (Join-Path $InstallerDir "include-utilities.ps1")
. (Join-Path $InstallerDir "include-backup-world.ps1")

Function Run-Minecraft {
  $WorkingDir = "${PSScriptRoot}"
  $exeLocation = Get-Command "$($global:Configuration.java.exec)" | Select -Expand Path
  $JavaArguments = $global:Configuration.java.arguments

  Start-Process -FilePath "${exeLocation}" -WorkingDirectory "${WorkingDir}" -ArgumentList $JavaArguments -NoNewWindow -RedirectStandardError "${ErrFile}" -RedirectStandardOutput "${OutFile}" -Wait
}

Function Read-Configuration {
  $ConfigFile = Join-Path -Path "${PSScriptRoot}" -ChildPath "start-config.json"
  $global:Configuration = Read-Json "${ConfigFile}" | Convert-PSObjectToHashtable
}

Read-Configuration
Run-Minecraft


Set-Location "${PSScriptRoot}"
[String] $WorldFolder = "$($global:Configuration.backup.sourceFolder)"
[String] $BackupFolder = "$($global:Configuration.backup.targetFolder)"

Backup-World "${WorldFolder}" "${BackupFolder}" $($global:Configuration.backup.keep)
