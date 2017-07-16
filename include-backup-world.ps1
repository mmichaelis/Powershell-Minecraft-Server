Function Backup-World([String] $WorldFolder, [String] $BackupRootFolder, [Int] $KeepBackups = 5) {
  [String] $BackupTimestamp = "$(Get-Date -f yyyy-MM-ddTHH-mm-ss)"
  [String] $WorldFolderName = Split-Path "${WorldFolder}" -leaf
  [String] $BackupTargetPath = Join-Path -Path "${BackupRootFolder}" -ChildPath "${WorldFolderName}.${BackupTimestamp}.zip"

  New-Item -ItemType Directory -Force -Path "${BackupRootFolder}" | Out-Null

  Compress-Archive -Path "${WorldFolder}" -DestinationPath "${BackupTargetPath}" -CompressionLevel Optimal
  
  Write-Host "Created backup: ${BackupTargetPath}"

  Get-ChildItem -Path "${BackupRootFolder}" -Filter "${WorldFolderName}*.zip" | Sort CreationTime | Select -SkipLast $KeepBackups | Remove-Item
}
