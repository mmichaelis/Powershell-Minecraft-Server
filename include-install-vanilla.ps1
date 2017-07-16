<#
.SYNOPSIS
Installs plain Vanilla Minecraft Jar.

.DESCRIPTION
Downloads the Minecraft Jar to the configured location. If the Minecraft Jar
already exists, an additional download is skipped.

.NOTES
Requires the following configuration settings:

* $global:Configuration.minecraft.exec.jar.fullPath
* $global:Configuration.minecraft.download.url
#>
Function Install-Vanilla {
  Init-InstallDir

  if (Test-Path "$($global:Configuration.minecraft.exec.jar.fullPath)") {
    Log-Minor "Download skipped. File already exists: $($global:Configuration.minecraft.exec.jar.fullPath)"
  } Else {
    $WebClient = New-Object System.Net.WebClient
    Log-Minor "Downloading $($global:Configuration.minecraft.download.url)..."
    $WebClient.DownloadFile("$($global:Configuration.minecraft.download.url)", "$($global:Configuration.minecraft.exec.jar.fullPath)")
    Log-Minor "Download saved to $($global:Configuration.minecraft.exec.jar.fullPath)."
  }
}

Function Write-ServerProperties {
  Init-InstallDir
  
  $FilteredConfiguration = $global:Configuration.properties.GetEnumerator() | Where-Object { $_.Key.StartsWith("serverProperties") }
  [Hashtable] $ServerProperties = @{}
  $FilteredConfiguration | ForEach-Object { $ServerProperties.Add($_.Key.Replace('serverProperties.',''), $_.Value) }
  $File = "$($global:Configuration.minecraft.files.properties)"

  Clear-Content -Force "${File}" -ErrorAction SilentlyContinue
  $ServerProperties.GetEnumerator() | %{ Add-Content -Encoding ASCII "${File}" "$($_.Key)=$($_.Value)" }
  Log-Minor "Server Properties written to '${File}'."
}

Function Write-Ops {
  Init-InstallDir

  $opsString = "$($global:Configuration.properties['minecraft.ops'])"
  if (-not [string]::IsNullOrEmpty($opsString)) {
    $File = "$($global:Configuration.minecraft.files.ops)"
    if (Test-Path "${File}.converted") {
      Log-Minor "Skipped updating operators. Use /op command instead."
    } Else {
      $ops = [regex]::split("${opsString}", '\s*[\t:,;]\s*')
      $ops | Out-File -Encoding ASCII "${File}"
      Log-Minor "Operators written to '${File}'."
    }
  }
}

Function Write-Eula {
  Init-InstallDir

  $eula = "$($global:Configuration.properties['minecraft.eula'])"
  $File = "$($global:Configuration.minecraft.files.eula)"

  if (-not (Test-Path "${File}")) {
    if ($eula -eq "true") {
      $Content = @(
        "#EULA (https://account.mojang.com/documents/minecraft_eula) accepted via properties.",
        "#Generated by '$($MyInvocation.ScriptName)'.",
        "#$(Get-Date -UFormat %c)",
        "eula=true"
      )
    
      $Content | Out-File -Encoding ASCII "${File}"
      Log-Minor "EULA accepted in '${File}'."
    } else {
      Log-Warn "EULA (https://account.mojang.com/documents/minecraft_eula) not accepted."
      Log-Warn "You will have to do that later on by editing '${File}'."
      Log-Warn "Instead you might set 'minecraft.eula=true' in your properties."
    }
  } Else {
    Log-Minor "Skipped updating existing eula.txt."
  }
}
