### KeePass_Secure_Auto_Install ###
### Author : onSec-fr
### Source : https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration
### Version : 1.1 (25/08/2023)

param(
     [Parameter()]
     [string]$ConfigFile = $null, # Optional - path to the KeePass.config.enforced.xml (Default : .\KeePass.config.enforced.xml)
     [Parameter()]
     [bool]$EnforceACL = $false # Optional - secure KeePass installation directory using ACLs (Default : False)
 )

# Check last version available on keepass.info
$DownloadSource = "https://keepass.info/download.html"
Write-Host "Checking last version..." -ForegroundColor white
$WebResponseObj = Invoke-WebRequest -Uri $DownloadSource
$link = $WebResponseObj.Links | Where-Object href -like '*KeePass-2*exe*'
$lastVersion = $link.outerText.Split(" ")[2].Split("-")[1]
Write-Host "Last version found: $lastVersion" -ForegroundColor green

# Download package from sourceforge. File integrity will be checked later.
$downloadlink = $link.href
Write-Host "Downloading package from $downloadlink ..." -ForegroundColor white
Invoke-WebRequest -Uri $downloadlink -OutFile "keepass-$lastVersion.exe" -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox
Write-Host "Saved to: keepass-$lastVersion.exe" -ForegroundColor green

#Check file integrity
$IntegritySource = "https://keepass.info/integrity.html"
$filehash = Get-FileHash("keepass-$lastVersion.exe")
$filehash = $filehash.Hash
$filehash = $filehash.Substring(0,8) + " " + $filehash.Substring(8,8) + " " + $filehash.Substring(16,8) + " " + $filehash.Substring(24,8) + " " + $filehash.Substring(32,8) + " " + $filehash.Substring(40,8) + " " + $filehash.Substring(48,8) + " " + $filehash.Substring(56,8)
Write-Host "File hash is: $filehash" -ForegroundColor white
$WebResponseObj = Invoke-WebRequest -Uri $IntegritySource
$WebResponseObj = $WebResponseObj.RawContent
if ($WebResponseObj -match '<td>SHA-256:</td><td><code>' + $filehash + '</code></td>')
{
    Write-Host "Integrity check passed. Success." -ForegroundColor green
} 
else 
{
    Write-Host "Failed to verify file integrity. Aborting..." -ForegroundColor red
    exit
}

#Installation
Write-Host "Installing KeePass..." -ForegroundColor white
Start-Process -Wait -FilePath "keepass-$lastVersion.exe" -ArgumentList "/VERYSILENT" -PassThru
$KeepassInstallationLocation = Get-ChildItem HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | % { Get-ItemProperty $_.PsPath } | Select InstallLocation | Sort-Object Displayname -Descending | findstr "KeePass"
$KeepassInstallationLocation = $KeepassInstallationLocation.TrimEnd([char]0x20)
Write-Host "Installation done." -ForegroundColor green
if ($KeepassInstallationLocation -eq $null)
{
    Write-Host "KeePass installation location not found." -ForegroundColor red
    exit
}
else
{
    Write-Host "KeePass installation location found at $KeepassInstallationLocation." -ForegroundColor white
}

#Copy enforced configuration
if ($ConfigFile -eq '')
{
    Write-Host "No Config File specified. Default file will be used." -ForegroundColor white
    $ConfigFile = "KeePass.config.enforced.xml"
}
else
{
    Write-Host "ConfigFile is set to use $ConfigFile" -ForegroundColor white
}
Copy-Item $ConfigFile -Destination $KeepassInstallationLocation"KeePass.config.enforced.xml" -Verbose
if (Test-Path -Path $KeepassInstallationLocation"KeePass.config.enforced.xml" -PathType Leaf)
{
    Write-Host "Enforced configuration file successfully copied." -ForegroundColor green
}
else
{
    Write-Host "Failed to copy enforced configuration file. Try to copy it manually. Skipped." -ForegroundColor red
}

if ($EnforceACL)
{
    Write-Host "EnforceACL not specified. Default : Protecting KeePass installation Folder with ACLs..." -ForegroundColor white
    #Set ACLs to protect keepass installation folder. Remove all rights and give full control to current user.
    $FolderPath = $KeepassInstallationLocation
    $acl = Get-Acl -Path $FolderPath
    $acl.SetAccessRuleProtection($true,$false) # disable inheritance
    $acl.SetOwner([System.Security.Principal.NTAccount] $env:USERNAME) # set current user owner
    $permissions = $env:username, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow' #give full control to current user
    $rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $permissions
    $acl.SetAccessRule($rule) 
    $acl | Set-Acl -Path $FolderPath -Verbose #apply acl
    $subFolders = Get-ChildItem $FolderPath -Directory -Recurse
    Foreach ($subFolder in $subFolders) # set current user owner for subfolders
    {
        $acl = Get-Acl $subFolder.FullName
        $acl.SetOwner([System.Security.Principal.NTAccount]"$env:USERNAME")
        set-acl $subFolder.FullName $acl
    }
    $subFiles = Get-ChildItem $FolderPath -File -Recurse
    Foreach ($subFile in $subFiles)  # set current user owner for subfiles
    {
        $acl = Get-Acl $subFile.FullName
        $acl.SetOwner([System.Security.Principal.NTAccount]"$env:USERNAME")
        set-acl $subFile.FullName $acl
    }
}
else
{
    Write-Host "EnforceACL is set to False. Skipped." -ForegroundColor yellow
}

#END
del "keepass-$lastVersion.exe" -Verbose
Write-Host "Installation competed. Be safe !" -ForegroundColor green