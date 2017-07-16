<#
.SYNOPSIS
Installs a Minecraft Server

.DESCRIPTION
Installs a Minecraft Server as desribed by the provided properties file. To see
available settings, use the default.properties file. Defaults will always be
read, so you only have to add settings to your custom file which you want to
modify.

As a result you will get a server installed to the given location containing
a start script, which can be used to start the Minecraft Server.

.PARAMETER $PropertiesFile
The properties file to read the server configuration from. Defaults to
default.properties.
#>
Param(
  [parameter(
    HelpMessage="Configuration file to read properties from."
  )]
  [String]
  $PropertiesFile = $null
)
### -PropertiesFile D:\Powershell-Minecraft-Server\example.properties
### -PropertiesFile D:\Powershell-Minecraft-Server\example-forge.properties

If ([String]::IsNullOrEmpty($PropertiesFile)) {
  $PropertiesFile = "$(Join-Path $PSScriptRoot "default.properties")"
}

### ---------------------------------------------------------------------------
###   Includes
### ---------------------------------------------------------------------------

. (Join-Path $PSScriptRoot "include-utilities.ps1")
. (Join-Path $PSScriptRoot "include-configuration.ps1")
. (Join-Path $PSScriptRoot "include-install-common.ps1")
. (Join-Path $PSScriptRoot "include-install-vanilla.ps1")
. (Join-Path $PSScriptRoot "include-install-forge.ps1")

### ---------------------------------------------------------------------------
###   Main
### ---------------------------------------------------------------------------

Read-Configuration
Install-Vanilla

$ServerType = "$($global:Configuration.properties["minecraft.type"])"

switch($ServerType) {
  "vanilla" { }
  "forge" { Install-Forge }
  default {
    Log-Error "Unsupported minecraft.type = '${ServerType}'."
    Exit 1
  }
}

Write-ServerProperties
Write-Ops
Write-Eula
Write-StartPropertiesJson
Write-StartScript

Write-Host "Done at $(Get-Date -Format o)."
