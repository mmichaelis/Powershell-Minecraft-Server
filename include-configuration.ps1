Function Read-Configuration {
  $global:Configuration = Read-Json "$(Get-ConfigFile("config.json"))" | Convert-PSObjectToHashtable

  [Hashtable] $DefaultProperties = Read-Properties "$(Get-ConfigFile("default.properties"))"
  [Hashtable] $UserProperties
  If ([String]::IsNullOrEmpty($PropertiesFile)) {
    $UserProperties = @{}
  } Else {
    $UserProperties = Read-Properties "$(Get-AbsolutePath("${PropertiesFile}"))"
  }
  [Hashtable] $Properties = Merge-Hashtables $DefaultProperties $UserProperties
  
  $MinecraftVersion = Resolve-MinecraftVersion $Properties["minecraft.version"]
  $Properties["minecraft.version"] = $MinecraftVersion
  
  $ForgeVersion = Resolve-ForgeVersion $Properties["forge.version"] $MinecraftVersion
  $Properties["forge.version"] = $ForgeVersion
  
  $global:Configuration.Add("properties", $Properties)
  
  Update-ConfigurationMinecraftInstallation
  Update-ConfigurationForgeInstallation
}

Function Update-ConfigurationMinecraftInstallation {
  $InstallDir = Join-Path -Path "${PSScriptRoot}" -ChildPath "$($global:Configuration.properties["install.dir"])"
  $Version = "$($global:Configuration.properties["minecraft.version"])"
  $JarName="minecraft_server.${Version}.jar"
  $DownloadUrl = "$($global:Configuration.minecraft.download.baseUrl)/${Version}/${JarName}"
  $DownloadTarget = Join-Path -Path "${InstallDir}" -ChildPath "${JarName}"
  $ServerProperties = Join-Path -Path "${InstallDir}" -ChildPath "server.properties"
  $OpsFile = Join-Path -Path "${InstallDir}" -ChildPath "ops.txt"
  $EulaFile = Join-Path -Path "${InstallDir}" -ChildPath "eula.txt"
  $StartProperties = Join-Path -Path "${InstallDir}" -ChildPath "start-config.json"

  # Expects that paths are already pre-defined in config.json
  $global:Configuration.minecraft.exec.jar.name = "$JarName"
  $global:Configuration.minecraft.exec.jar.dir = "$InstallDir"
  $global:Configuration.minecraft.exec.jar.fullPath = "$DownloadTarget"
  $global:Configuration.minecraft.files.properties = "$ServerProperties"
  $global:Configuration.minecraft.files.eula = "$EulaFile"
  $global:Configuration.minecraft.files.ops = "$OpsFile"
  $global:Configuration.minecraft.files.startProperties = "$StartProperties"
  $global:Configuration.minecraft.download.url = "$DownloadUrl"
}

Function Update-ConfigurationForgeInstallation {
  $InstallDir = Join-Path -Path "${PSScriptRoot}" -ChildPath "$($global:Configuration.properties["install.dir"])"
  $MinecraftVersion = "$($global:Configuration.properties["minecraft.version"])"
  $ForgeVersion = "$($global:Configuration.properties["forge.version"])"
  
  Switch($MinecraftVersion) {
    "1.7.10" { $CombinedVersion = "${MinecraftVersion}-${ForgeVersion}-${MinecraftVersion}" }
    "1.8.9" { $CombinedVersion = "${MinecraftVersion}-${ForgeVersion}-${MinecraftVersion}" }
    default { $CombinedVersion = "${MinecraftVersion}-${ForgeVersion}" }
  }

  $InstallerName="forge-${CombinedVersion}-installer.jar"
  $DownloadUrl = "$($global:Configuration.forge.download.baseUrl)/${CombinedVersion}/${InstallerName}"
  $DownloadTarget = Join-Path -Path "${InstallDir}" -ChildPath "${InstallerName}"

  $JarName = "forge-${CombinedVersion}-universal.jar"
  $JarFullPath = Join-Path -Path "${InstallDir}" -ChildPath "${JarName}"

  # Expects that paths are already pre-defined in config.json
  $global:Configuration.forge.install.jar.name = "$InstallerName"
  $global:Configuration.forge.install.jar.dir = "$InstallDir"
  $global:Configuration.forge.install.jar.fullPath = "$DownloadTarget"

  $global:Configuration.forge.exec.jar.name = "$JarName"
  $global:Configuration.forge.exec.jar.dir = "$InstallDir"
  $global:Configuration.forge.exec.jar.fullPath = "$JarFullPath"

  $global:Configuration.forge.download.url = "$DownloadUrl"
}

<#
.SYNOPSIS
Creates the installation directory.

.DESCRIPTION
Creates the installation directory, if it does not exist yet.

.PARAMETER $VersionDescriptor
A String describing the requested minecraft versions. While most versions
will be returned as is, the keywords "latest" and "snapshot" will be resolved
to most recent release or snapshot.

.OUTPUTS
System.String. Resolved version number.

.NOTES
Requires the following configuration setting:

* $global:Configuration.minecraft.versions.json
#>
Function Resolve-MinecraftVersion([String] $VersionDescriptor) {
  $VersionInfo=Download-Json "$($global:Configuration.minecraft.versions.json)"
  $VersionDescriptor = $VersionDescriptor.ToLower()
  Switch($VersionDescriptor) {
    "latest" { $Result = $VersionInfo.latest.release }
    "snapshot" { $Result = $VersionInfo.latest.snapshot }
    default { $Result = $VersionDescriptor }
  }
  "${Result}"
}

Function Resolve-ForgeVersion([String] $VersionDescriptor, [String] $MinecraftVersion) {
  # http://files.minecraftforge.net/maven/net/minecraftforge/forge/promotions_slim.json
  # Download-Url Examples:
  # http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.12-14.21.1.2405/forge-1.12-14.21.1.2405-installer.jar
  # http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.8.9-11.15.1.2318-1.8.9/forge-1.8.9-11.15.1.2318-1.8.9-installer.jar
  # http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.7.10-10.13.4.1540-1.7.10/forge-1.7.10-10.13.4.1540-1.7.10-installer.jar
  $VersionInfo=Download-Json "$($global:Configuration.forge.versions.json)"
  $VersionDescriptor = $VersionDescriptor.ToLower()
  [PSNoteProperty] $RecommendedVersion = $VersionInfo.promos.PSObject.Properties | Where-Object { $_.Name -eq "${MinecraftVersion}-recommended"}
  [PSNoteProperty] $LatestVersion = $VersionInfo.promos.PSObject.Properties | Where-Object { $_.Name -eq "${MinecraftVersion}-latest"}

  Switch($VersionDescriptor) {
    "recommended" { $Result = $RecommendedVersion.Value }
    "latest" { $Result = $LatestVersion.Value }
    default { $Result = $VersionDescriptor }
  }
  "${Result}"
}
