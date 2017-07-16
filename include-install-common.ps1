<#
.SYNOPSIS
Creates the installation directory.

.DESCRIPTION
Creates the installation directory, if it does not exist yet.

.NOTES
Requires the following configuration setting:

* $global:Configuration.minecraft.exec.jar.dir
#>
Function Init-InstallDir {
  New-Item -ItemType Directory -Force -Path "$($global:Configuration.minecraft.exec.jar.dir)" | Out-Null
}

Function Write-StartPropertiesJson {
  Init-InstallDir

  $File = "$($global:Configuration.minecraft.files.startProperties)"

  $Jar = "$($global:Configuration.minecraft.exec.jar.fullPath)"
  $JavaExec = "$($global:Configuration.properties['java.exec'])"
  $exeLocation = Get-Command "${JavaExec}" | Select -Expand Path
  $Java = Get-ChildItem "${exeLocation}"
  $JavaMajor = $Java.VersionInfo.ProductMajorPart
  [String[]] $JavaArgs = $global:Configuration.java.options.common + $global:Configuration.java.options.$JavaMajor
  $JavaArgs = $JavaArgs | ForEach { Replace-Tokens $_ }
  $JavaArgs = $JavaArgs + @("-jar", "${Jar}")

  if ("$($global:Configuration.properties['minecraft.gui'])" -ne "true") {
    $JavaArgs = $JavaArgs + @("nogui")
  }
  
  # Remove empty elements
  $JavaArgs = $JavaArgs | ? {$_}
  
  $StartProperties = @{
    "java" = @{
      "exec" = $exeLocation;
      "arguments" = $JavaArgs
    };
    "backup" = @{
      "keep" = [convert]::ToInt32($($global:Configuration.properties['backup.keep.number']), 10);
      "sourceFolder" = "$($global:Configuration.properties['serverProperties.level-name'])";
      "targetFolder" = "$($global:Configuration.properties['backup.folder.name'])";
    };
  }

  $StartProperties | ConvertTo-Json -Depth 10 | Out-File "${File}"

  Log-Minor "Start Properties written to '${File}'."
}

Function Write-StartScript {
  Init-InstallDir

  $SourceFile = Join-Path -Path "${PSScriptRoot}" -ChildPath "start.template.ps1"
  $TargetFile = Join-Path -Path "$($global:Configuration.minecraft.exec.jar.dir)" -ChildPath "Start-Minecraft.ps1"
  
  Copy-Item -Path "${SourceFile}" -Destination "${TargetFile}"
  
  Log-Minor "Start Script written to '${TargetFile}'."
}
