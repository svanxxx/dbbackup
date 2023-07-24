# Set variables
$ServerInstance = "localhost"
$DatabaseName = "FIELDPRO_DEMO_SQL_V8"
$BackupDir = "c:\ProgramData\Fieldpro\DBBackups"
$ArchiveDir = "c:\ProgramData\Fieldpro\DBBackups"
$Timestamp = Get-Date -Format "yyyy.MM.dd"
$zip = $PSScriptRoot + "\7z.exe" 
$rclone = $PSScriptRoot + "\rclone.exe" 
$BackupFile = "${BackupDir}\${DatabaseName}_${Timestamp}.bak"
$ArchiveFile = "${ArchiveDir}\${DatabaseName}_${Timestamp}.7z"

# Create backup and archive directories if they don't exist
if (!(Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir
}
if (!(Test-Path $ArchiveDir)) {
    New-Item -ItemType Directory -Path $ArchiveDir
}

if (Test-Path $BackupFile) {
    Remove-Item $BackupFile
}

if (Test-Path $ArchiveFile) {
    Remove-Item $ArchiveFile
}

# Backup the SQL Server database
Backup-SqlDatabase -ServerInstance $ServerInstance -Database $DatabaseName -BackupFile $BackupFile
Write-Host "Database backup completed successfully."
 
# Archive the backup using 7-Zip
& $zip a -t7z $ArchiveFile $BackupFile
Write-Host "Backup archived successfully."

# Remove the original backup file
Remove-Item $BackupFile
Write-Host "Original backup file removed."

& $rclone copy "$($ArchiveFile)" client: --config rclone.conf

Get-ChildItem $ArchiveDir | Sort-Object Name -desc | Select-Object -Skip 7 | Remove-Item -Force
