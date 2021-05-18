# KeePass Enhanced Security Configuration 

**Make your keepass more secure** using the not very-well known KeePass enforced configuration file and some tweaking.

![](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/icon.ico?raw=true)

- [KeePass Enhanced Security Configuration](#keepass-enhanced-security-configuration)
    + [Introduction](#introduction)
    + [General considerations](#general-considerations)
	+ [Automatic installation](#automatic-installation)
      - [Parameters](#parameters)
      - [Run](#run)
    + [Configuration file](#configuration-file)
      - [Sample file](#sample-file)
      - [Screenshots](#screenshots)
      - [More settings](#more-settings)
    + [References](#references)

### Introduction
[KeePass](https://keepass.info "KeePass") is a great tool to store your passwords securely (the best in my opinion).

On the other hand its popularity leads to a risk since there are [many ways to attack Keepass](https://www.harmj0y.net/blog/redteaming/keethief-a-case-study-in-attacking-keepass-part-2/ "many ways to attack Keepass") nowadays.
Furthermore the large number of features increases the potential attack surface.

So the goal is to limit some features you don't need and to activate all security mechanisms that are not activated by default.

To do this we will use the [enforced configuration file](https://keepass.info/help/kb/config_enf.html "enforced configuration file"), which is an official KeePass feature.

### General considerations
In order to further secure your installation, please remember to apply the following recommendations: 

- Download KeePass **[from its official website](https://keepass.info "from its official website")** only and **[check the integrity of the downloaded file](https://keepass.info/integrity.html "check the integrity of the downloaded file")**.
- **Secure your KeePass installation directory** so that only your user account can write to it (to protect the integrity of your configuration file).
- **Increase the number of iterations of the derivation key** used to encrypt your database (default is 60000).
- **Secure your database [with a key file](https://keepass.info/help/base/keys.html#keyfiles "with a key file")** in addition to the master password. Note that the key file should not be stored in the same location as your database.

### Automatic installation
You can use the **KeePass_Secure_Auto_Install.ps1** file to install and configure KeePass automatically !

What the script does:
1. **Download the latest version** of KeePass from its official website
2. **Checks the integrity** of the file by comparing its hash
3. **Copy the enforced configuration file**
4. **Alter permissions** on the KeePass installation folder

#### Parameters
- **ConfigFile** : Optional - path to the KeePass.config.enforced.xml (Default : .\KeePass.config.enforced.xml).
- **EnforceACL** Optional - secure KeePass installation directory using ACLs (Default : True).

#### Run
**Default** : `.\KeePass_Secure_Auto_Install.ps1`  
**Custom** : `.\KeePass_Secure_Auto_Install.ps1 -ConfigFile "C:\path\to\file.xml" -EnforceACL $False`

[![](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/auto_install.gif?raw=true)](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/auto_install.png?raw=true)

### Configuration file
From [official documentation ](https://keepass.info/help/kb/config_enf.html#info "official documentation "): 
> The format of an enforced configuration file is basically the same as the format of a regular configuration file. An enforced configuration file must be stored in the KeePass application directory (which contains KeePass.exe). Its name depends on the KeePass edition:
> - KeePass 1.x: KeePass.enforced.ini.
> - KeePass 2.x: KeePass.config.enforced.xml.

#### Sample file
Here is an example file, which embeds most of the important security mechanisms, and disables dangerous features :
```xml
<?xml version="1.0" encoding="utf-8"?>
<Configuration xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<!-- Ref https://keepass.info/help/kb/config_enf.html -->
	<Application>
		<!-- Disable triggers -->
		<TriggerSystem>
			<Enabled>false</Enabled>
			<Triggers MergeContentMode="Replace" />
		</TriggerSystem>
		<!-- Disable automatic update -->
		<Start>
			<CheckForUpdate>false</CheckForUpdate>
			<CheckForUpdateConfigured>true</CheckForUpdateConfigured>
		</Start>
	</Application>
	<!-- Specifying UI Element States : https://keepass.info/help/v2_dev/customize.html#uiflags -->
	<UI>
		<!-- Disable 'Help' → 'Check for Updates' menu item. -->
		<UIFlags>32</UIFlags>
	</UI>
	<Security>
		<!-- Edit Policy -->
		<Policy>
			<ChangeMasterKeyNoKey>false</ChangeMasterKeyNoKey>
			<PrintNoKey>false</PrintNoKey>
			<EditTriggers>false</EditTriggers>
			<Plugins>false</Plugins>
			<Export>false</Export>
			<ExportNoKey>false</ExportNoKey>
			<Import>false</Import>
			<Print>false</Print>
			<CopyWholeEntries>false</CopyWholeEntries>
			<DragDrop>false</DragDrop>
			<UnhidePasswords>false</UnhidePasswords>
		</Policy>
		<!-- Enforce automatic locking -->
		<WorkspaceLocking>
			<LockOnSessionSwitch>true</LockOnSessionSwitch>
			<LockOnSuspend>true</LockOnSuspend>
			<LockAfterTime>600</LockAfterTime>
			<LockAfterGlobalTime>3600</LockAfterGlobalTime>
			<LockOnRemoteControlChange>true</LockOnRemoteControlChange>
		</WorkspaceLocking>
		<!-- Master password requirements -->
		<MasterPassword>
			<MinimumLength>16</MinimumLength>
			<MinimumQuality>80</MinimumQuality>
		</MasterPassword>
		<!-- Enable Secure Desktop (ref https://keepass.info/help/kb/sec_desk.html)  -->
		<MasterKeyOnSecureDesktop>true</MasterKeyOnSecureDesktop>
		<!-- Clear clipboard after x sec -->
		<ClipboardClearAfterSeconds>10</ClipboardClearAfterSeconds>
		<!-- Protect Keepass process with DACL - Use with caution - -->
		<ProtectProcessWithDacl>true</ProtectProcessWithDacl>
		<!-- Prevent Screen Capture - Use with caution - -->
		<PreventScreenCapture>true</PreventScreenCapture>
	</Security>P
	<!-- Replace default password generator -->
	<PasswordGenerator>
		<AutoGeneratedPasswordsProfile>
			<GeneratorType>CharSet</GeneratorType>
			<Length>12</Length>
			<CharSetRanges>ULDS______</CharSetRanges>
			<ExcludeLookAlike>true</ExcludeLookAlike>
			<NoRepeatingCharacters>true</NoRepeatingCharacters>
		</AutoGeneratedPasswordsProfile>
	</PasswordGenerator>
	<!-- Enforce Proxy configuration -->
	<Integration>
		<ProxyType>System</ProxyType>
		<ProxyAuthType>Auto</ProxyAuthType>
	</Integration>
</Configuration>
```
#### Screenshots
- As you can see the settings are now enforced :

[![](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/enforced_settings.png?raw=true)](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/enforced_settings.png?raw=true)

- KeePass process is now protected from dumping and alteration :

[![](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/after_dacl_protect.png?raw=true)](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/after_dacl_protect.png?raw=true)

- Plugins and others specified settings are now disallowed :

[![](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/disallowed.png?raw=true)](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/disallowed.png?raw=true)

#### More settings
The settings are poorly documented, but if you want to play around, there is a way :
> In order to create an enforced configuration file, we recommend the following procedure:
> 1. Download the portable ZIP package of KeePass and unpack it. Run KeePass, configure everything as you wish, and exit it.
> 2. Rename the configuration file to the enforced configuration file name.
> 3. Open the enforced configuration file with a text editor and delete all settings that you do not want to enforce.

### References
- Official KeePass Website : https://keepass.info
- Enforced configuration official documentation : https://keepass.info/help/kb/config_enf.html
- Customization official documentation : https://keepass.info/help/v2_dev/customize.html
- A case study in Attacking KeePass (by @HarmJ0y) : https://www.harmj0y.net/blog/redteaming/keethief-a-case-study-in-attacking-keepass-part-2/
- Another case study in Attacking Keepass (by @HarmJ0y) : https://www.slideshare.net/harmj0y/a-case-study-in-attacking-keepass


[@onSec-fr](https://github.com/onSec-fr "@onSec-fr")
