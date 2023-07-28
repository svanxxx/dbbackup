# Set variables
$ServerInstance = "localhost"
$MaxBak = 2
$Timestamp = Get-Date -Format "yyyy.MM.dd"
$zip = $PSScriptRoot + "\7z.exe" 
$rclone = $PSScriptRoot + "\rclone.exe" 
$ConfigFile = $PSScriptRoot + "\rclone.conf"

$databases =
@(
    [pscustomobject]@{name="FIELDPRO_DEMO_SQL_V8";folder="FIELDPRO_DEMO_SQL_V8"},
    [pscustomobject]@{name="ALFA";folder="ALPHA"},
    [pscustomobject]@{name="FIELDPRO_EARTHSTONE";folder="EARTHSTONE"},
    [pscustomobject]@{name="FIELDPRO_MOONTOWER";folder="FIELDPRO_MOONTOWER"},
    [pscustomobject]@{name="RIVERBEND";folder="FIELDPRO_RIVERBEND"},
    [pscustomobject]@{name="UPDATES";folder="UPDATES"}
)

Foreach ($database in $databases)
{   
    $DatabaseName = $database.name
    $RemoteFolder = $database.folder
    $BackupDir = "c:\ProgramData\Fieldpro\DBBackups\$($DatabaseName)"
    $ArchiveDir = "c:\ProgramData\Fieldpro\DBBackups\$($DatabaseName)"
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
    & $zip a -t7z -mx=1 $ArchiveFile $BackupFile
    Write-Host "Backup archived successfully."
    
    # Remove the original backup file
    Remove-Item $BackupFile
    Write-Host "Original backup file removed."
    
    & $rclone copy "$($ArchiveFile)" client:$RemoteFolder/Database --config "$($ConfigFile)"
    
    Get-ChildItem $ArchiveDir | Sort-Object Name -desc | Select-Object -Skip $MaxBak | Remove-Item -Force
}