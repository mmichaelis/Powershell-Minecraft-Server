<#
.SYNOPSIS
Utilities for Minecraft-Installation.

.DESCRIPTION
This script only contains functions to be used via Include in Minecraft-
Installation Scripts.

.NOTES
Include for example via:

    . (Join-Path $PSScriptRoot "include-utilities.ps1")

#>

### ---------------------------------------------------------------------------
###   Logging
### ---------------------------------------------------------------------------

Function Log-Minor([String] $Message) {
  Write-Host "${Message}" -foregroundcolor "Gray"
}

Function Log-Normal([String] $Message) {
  Write-Host "${Message}" -foregroundcolor "White"
}

Function Log-Warn([String] $Message) {
  Write-Host "${Message}" -foregroundcolor "Yellow"
}

Function Log-Error([String] $Message) {
  Write-Host "${Message}" -foregroundcolor "Red"
}

### ---------------------------------------------------------------------------
###   File-Handling
### ---------------------------------------------------------------------------

Function Get-ConfigFile([String] $FileName) {
  $Path = Join-Path -Path "${PSScriptRoot}" -ChildPath "${FileName}"
  "${Path}"
}

# https://stackoverflow.com/questions/495618/how-to-normalize-a-path-in-powershell
Function Get-AbsolutePath([String] $Path) {
  $Path = [System.IO.Path]::Combine( ((pwd).Path), ($Path) )
  $Path = [System.IO.Path]::GetFullPath($Path)

  "$Path"
}

Function Read-Properties([String] $Path) {
  Get-Content "$Path" -Raw | ConvertFrom-StringData
}

Function Read-Json([String] $Path) {
  Get-Content "$Path" | ConvertFrom-Json
}

### ---------------------------------------------------------------------------
###   String-Handling
### ---------------------------------------------------------------------------

# https://stackoverflow.com/questions/40426448/how-can-i-use-powershell-to-expand-placeholders-in-a-template-string-using-value
Function Replace-Tokens([String] $Original) {
  [Regex]::Replace($Original, '%([\p{L}._]+)%', {
    Param($Match)
    $global:Configuration.properties[$Match.Groups[1].Value]
  })
}

### ---------------------------------------------------------------------------
###   Web
### ---------------------------------------------------------------------------

Function Download-Json([String] $JsonUrl) {
  $WebClient = New-Object System.Net.WebClient
  $WebClient.DownloadString("${JsonUrl}") | ConvertFrom-Json
}

### ---------------------------------------------------------------------------
###   Utilities
### ---------------------------------------------------------------------------

Function Merge-Hashtables([Hashtable] $Base, [Hashtable] $Override) {
  [Hashtable] $Result = $Base.Clone()
  $Override.GetEnumerator() | ForEach-Object {
    $Result[$_.key] = $_.value
  }
  $Result
}

# https://stackoverflow.com/questions/3740128/pscustomobject-to-hashtable
Function Convert-PSObjectToHashtable([Parameter(ValueFromPipeline)] $InputObject) {
  Process {
    If ($null -eq $InputObject) {
      return $null
    }

    If ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
      $collection = @(
        ForEach ($object in $InputObject) {
          Convert-PSObjectToHashtable $object
        }
      )

      Write-Output -NoEnumerate $collection
    } ElseIf ($InputObject -is [psobject]) {
      $hash = @{}

      ForEach ($property in $InputObject.PSObject.Properties) {
        $hash[$property.Name] = Convert-PSObjectToHashtable $property.Value
      }

      $hash
    } Else {
      $InputObject
    }
  }
}
