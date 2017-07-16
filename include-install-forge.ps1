Function Install-Forge {
  Init-InstallDir

  if (Test-Path "$($global:Configuration.forge.install.jar.fullPath)") {
    Log-Minor "Download skipped. File already exists: $($global:Configuration.forge.install.jar.fullPath)"
  } Else {
    $WebClient = New-Object System.Net.WebClient
    Log-Minor "Downloading $($global:Configuration.forge.download.url)..."
    $WebClient.DownloadFile("$($global:Configuration.forge.download.url)", "$($global:Configuration.forge.install.jar.fullPath)")
    Log-Minor "Download saved to $($global:Configuration.forge.install.jar.fullPath)."
  }
  
  Run-Forge-Installer
  Redirect-Forge-Configuration
}

Function Run-Forge-Installer {
  $WorkingDir = "$($global:Configuration.forge.install.jar.dir)"
  $JavaExec = "$($global:Configuration.properties['java.exec'])"
  $exeLocation = Get-Command "${JavaExec}" | Select -Expand Path
  $InstallerJar = "$($global:Configuration.forge.install.jar.fullPath)"
  $Jar = "$($global:Configuration.forge.exec.jar.fullPath)"
  
  If (Test-Path "${Jar}") {
    Log-Minor "Skipped Forge installation. Forge is already installed and available at '${Jar}'."
  } Else {
    $JavaArguments = @("-jar", "${InstallerJar}", "--installServer")
    $ErrFile = Join-Path -Path "${WorkingDir}" -ChildPath "forge.err.txt"
    $OutFile = Join-Path -Path "${WorkingDir}" -ChildPath "forge.out.txt"
    
    Log-Minor "Installing Forge via '${InstallerJar}'."
    Start-Process -FilePath "${exeLocation}" -WorkingDirectory "${WorkingDir}" -ArgumentList $JavaArguments -NoNewWindow -RedirectStandardError "${ErrFile}" -RedirectStandardOutput "${OutFile}" -Wait
    Log-Minor "Done installing Forge via '${InstallerJar}'."
  }
}

Function Redirect-Forge-Configuration {
  $global:Configuration.minecraft.exec.jar.name = "$($global:Configuration.forge.exec.jar.name)"
  $global:Configuration.minecraft.exec.jar.dir = "$($global:Configuration.forge.exec.jar.dir)"
  $global:Configuration.minecraft.exec.jar.fullPath = "$($global:Configuration.forge.exec.jar.fullPath)"
  Log-Minor "Redirected Minecraft Start settings to Forge."
}
