# KeePass Enhanced Security Configuration 

**Make your keepass more secure** using the not very-well known KeePass enforced configuration file. 

![](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/icon.ico?raw=true)

- [KeePass Enhanced Security Configuration](#keepass-enhanced-security-configuration)
    + [Introduction](#introduction)
    + [General considerations](#general-considerations)
    + [Existing installation](#existing-installation)
	+ [Automatic installation](#automatic-installation)
      - [Parameters](#parameters)
      - [Run](#run)
    + [Configuration file](#configuration-file)
      - [Sample file](#sample-file)
      - [Settings description](#settings-description)
      - [Screenshots](#screenshots)
      - [More settings](#more-settings)
    + [References](#references)
    + [Resources](#resources)
    + [FAQ](#faq)
    + [TODO](#todo)

### Introduction
[KeePass](https://keepass.info "KeePass") is a great tool to store your passwords securely for personnal use.

On the other hand its popularity leads to a risk since there are [many ways to attack Keepass](https://blog.harmj0y.net/redteaming/keethief-a-case-study-in-attacking-keepass-part-2/ "many ways to attack Keepass").
Furthermore the large number of features increases the potential attack surface. 

**So the goal is to limit some features you don't need and to activate all security mechanisms that are not activated by default.**

To do this we will use the [enforced configuration file](https://keepass.info/help/kb/config_enf.html "enforced configuration file"), which is an official KeePass feature.

### General considerations
In order to further secure your installation, please remember to apply the following recommendations: 

- Download KeePass **[from its official website](https://keepass.info "from its official website")** only and **[check the integrity of the downloaded file](https://keepass.info/integrity.html "check the integrity of the downloaded file")**.
- If you are using the portable version, **secure your KeePass installation directory** so that only your user account can write to it (to protect the integrity of your configuration file).
- **Increase the number of iterations of the derivation key** used to encrypt your database (default is 60000). *You can use the "1 Second Delay" button to set a value automatically.*
- **Lock your database** when not in use.
- **Secure your database [with a key file](https://keepass.info/help/base/keys.html#keyfiles "with a key file")** in addition to the master password. Note that the key file should not be stored in the same location as your database.
- **Consider using version 1.x**, which has fewer features but is also more secure by design. See **[edition comparison](https://keepass.info/compare.html "edition comparison")**.

> Check out KeePwn, a python tool to automate KeePass discovery and secret extraction : https://github.com/Orange-Cyberdefense/KeePwn.

### Environment-specific considerations
The purpose of this repo is to provide an example of best practices that can be implemented. Some settings may be incompatible or unnecessary in your environment.
- **Review the supplied configuration file** and check that it does not disable any of the features you use. 
- In a corporate environment, **adjust the settings according to your security policy.**
- Please note that **the provided file disables automatic updates** in order to protect against a compromised version. This means **you'll be responsible for updating your package** on a regular basis. If you prefer, automatic updates can be re-enabled by modifying the configuration file.
- Note that if the user or attacker has write access to the enforced configuration file, they will be able to alter the settings. This is why, in an corporate environment, **I recommend deploying this file via GPO**. For personal use, you should not use keepass with a local administrator account.
- Administrators can **disallow running other copies of KeePass** and other applications (that support the KeePass database file format), if desired, e.g. using Application Control, AppLocker or Software Restriction Policies.

### Existing installation
You can just copy the *KeePass.config.enforced.xml* file to the root of the KeePass installation directory (this also works with portable versions).  
**Settings will be applied at the next Keepass launch.**

### Automatic installation
You can use the **KeePass_Secure_Auto_Install.ps1** file to fully install and configure KeePass automatically !
> If you don't want to, just copy the *KeePass.config.enforced.xml* file to the root of the KeePass installation directory.

What the script does:
1. **Download the latest version** of KeePass from its official website
2. **Checks the integrity** of the file by comparing its hash
3. **Copy the enforced configuration file**
4. **Alter permissions** on the KeePass installation folder (remove all ACLs except the current user)

#### Parameters
- **ConfigFile** : Optional - path to the KeePass.config.enforced.xml *(Default : .\KeePass.config.enforced.xml)*
- **EnforceACL** : Optional - secure KeePass installation directory using ACLs *(Default : False)*

#### Run
**Default** : `.\KeePass_Secure_Auto_Install.ps1`  
**Custom** : `.\KeePass_Secure_Auto_Install.ps1 -ConfigFile "C:\path\to\file.xml" -EnforceACL $True`

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
			<LockAfterTime>3600</LockAfterTime>
			<LockAfterGlobalTime>600</LockAfterGlobalTime>
			<LockOnRemoteControlChange>true</LockOnRemoteControlChange>
		</WorkspaceLocking>
		<!-- Master password requirements -->
		<MasterPassword>
			<MinimumLength>16</MinimumLength>
			<MinimumQuality>80</MinimumQuality>
			<RememberWhileOpen>false</RememberWhileOpen>
		</MasterPassword>
		<!-- Enable Secure Desktop (ref https://keepass.info/help/kb/sec_desk.html)  -->
		<MasterKeyOnSecureDesktop>true</MasterKeyOnSecureDesktop>
		<!-- Clear clipboard after x sec -->
		<ClipboardClearAfterSeconds>10</ClipboardClearAfterSeconds>
		<!-- Protect Keepass process with DACL - Use with caution - -->
		<ProtectProcessWithDacl>true</ProtectProcessWithDacl>
		<!-- Prevent Screen Capture - Use with caution - -->
		<PreventScreenCapture>true</PreventScreenCapture>
	</Security>
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

#### Settings description 
This table lists all parameters used in the sample :
| XPath | Parameter | Example Value | Description |
|-------|-----------|---------------|---------------------|
| `/Configuration/Application/TriggerSystem/Enabled` | TriggerSystem Enabled | `false` | Disables or enables the trigger system. If `false`, no automated triggers are executed. |
| `/Configuration/Application/TriggerSystem/Triggers` | Triggers (with `MergeContentMode="Replace"`) | *(empty list)* | Replaces all triggers with an empty list, effectively removing any existing triggers. |
| `/Configuration/Application/Start/CheckForUpdate` | CheckForUpdate | `false` | Disables automatic update checks. Updates must be performed manually. |
| `/Configuration/Application/Start/CheckForUpdateConfigured` | CheckForUpdateConfigured | `true` | Marks the update check setting as configured and enforces its value. |
| `/Configuration/UI/UIFlags` | UIFlags | `32` | Bitmask controlling UI elements (hiding “Check for Updates” menu entry). |
| `/Configuration/Security/Policy/ChangeMasterKeyNoKey` | ChangeMasterKeyNoKey | `false` | Prevents changing the master key without entering the current key. |
| `/Configuration/Security/Policy/PrintNoKey` | PrintNoKey | `false` | Disallows printing when the database is not unlocked. |
| `/Configuration/Security/Policy/EditTriggers` | EditTriggers | `false` | Prevents editing or creating triggers. |
| `/Configuration/Security/Policy/Plugins` | Plugins | `false` | Disables the use of plugins. |
| `/Configuration/Security/Policy/Export` | Export | `false` | Disables exporting entries. |
| `/Configuration/Security/Policy/ExportNoKey` | ExportNoKey | `false` | Disallows export operations when the database is not unlocked. |
| `/Configuration/Security/Policy/Import` | Import | `false` | Disables importing of entries. |
| `/Configuration/Security/Policy/Print` | Print | `false` | Disables printing of entries. |
| `/Configuration/Security/Policy/CopyWholeEntries` | CopyWholeEntries | `false` | Prevents copying complete entries (username+password). |
| `/Configuration/Security/Policy/DragDrop` | DragDrop | `false` | Disables drag-and-drop of entries. |
| `/Configuration/Security/Policy/UnhidePasswords` | UnhidePasswords | `false` | Disallows unmasking of password fields. |
| `/Configuration/Security/WorkspaceLocking/LockOnSessionSwitch` | LockOnSessionSwitch | `true` | Locks the workspace when switching user sessions. |
| `/Configuration/Security/WorkspaceLocking/LockOnSuspend` | LockOnSuspend | `true` | Locks KeePass when the system goes into suspend/sleep mode. |
| `/Configuration/Security/WorkspaceLocking/LockAfterTime` | LockAfterTime | `600` | Locks KeePass after 600 seconds (10 min) of KeePass inactivity. |
| `/Configuration/Security/WorkspaceLocking/LockAfterGlobalTime` | LockAfterGlobalTime | `3600` | Locks KeePass after 3600 seconds (1 hour) of global user inactivity. |
| `/Configuration/Security/WorkspaceLocking/LockOnRemoteControlChange` | LockOnRemoteControlChange | `true` | Locks KeePass when remote control status changes (e.g., Remote Desktop). |
| `/Configuration/Security/MasterPassword/MinimumLength` | MinimumLength | `16` | Requires master password to be at least 16 characters long. |
| `/Configuration/Security/MasterPassword/MinimumQuality` | MinimumQuality | `80` | Enforces minimum quality/entropy for the master password. |
| `/Configuration/Security/MasterPassword/RememberWhileOpen` | RememberWhileOpen | `false` | Prevents KeePass from storing the master password in memory while database is open. |
| `/Configuration/Security/MasterKeyOnSecureDesktop` | MasterKeyOnSecureDesktop | `true` | Enables secure desktop for master key entry to protect against keyloggers. |
| `/Configuration/Security/ClipboardClearAfterSeconds` | ClipboardClearAfterSeconds | `10` | Clears clipboard contents after 10 seconds. |
| `/Configuration/Security/ProtectProcessWithDacl` | ProtectProcessWithDacl | `true` | Restricts other processes from accessing KeePass memory via DACL protection. |
| `/Configuration/Security/PreventScreenCapture` | PreventScreenCapture | `true` | Prevents screen capturing of KeePass windows. |
| `/Configuration/PasswordGenerator/AutoGeneratedPasswordsProfile/GeneratorType` | GeneratorType | `CharSet` | Uses character set–based password generation. |
| `/Configuration/PasswordGenerator/AutoGeneratedPasswordsProfile/Length` | Length | `12` | Default length for generated passwords. |
| `/Configuration/PasswordGenerator/AutoGeneratedPasswordsProfile/CharSetRanges` | CharSetRanges | `ULDS______` | Character sets used: U=uppercase, L=lowercase, D=digits, S=specials. |
| `/Configuration/PasswordGenerator/AutoGeneratedPasswordsProfile/ExcludeLookAlike` | ExcludeLookAlike | `true` | Excludes look-alike characters (`O/0`, `l/1`) from generated passwords. |
| `/Configuration/PasswordGenerator/AutoGeneratedPasswordsProfile/NoRepeatingCharacters` | NoRepeatingCharacters | `true` | Ensures no repeating characters in generated passwords. |
| `/Configuration/Integration/ProxyType` | ProxyType | `System` | Uses system proxy configuration for connections. |
| `/Configuration/Integration/ProxyAuthType` | ProxyAuthType | `Auto` | Uses automatic proxy authentication method. |


#### Screenshots
- As you can see the settings are now enforced :

[![](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/enforced_settings.png?raw=true)](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/enforced_settings.png?raw=true)

- KeePass process is now protected from dumping and alteration :

[![](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/after_dacl_protect.png?raw=true)](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/after_dacl_protect.png?raw=true)

- Plugins and others specified settings are now disallowed :

[![](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/disallowed.png?raw=true)](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/disallowed.png?raw=true)

#### More settings
Some settings are poorly documented, but if you want to play around, there is a way :
> In order to create an enforced configuration file, we recommend the following procedure:
> 1. Download the portable ZIP package of KeePass and unpack it. Run KeePass, configure everything as you wish, and exit it.
> 2. Rename the configuration file to the enforced configuration file name.
> 3. Open the enforced configuration file with a text editor and delete all settings that you do not want to enforce.
>
> **Note that not all parameters are accessible from the UI**

### References
- Official KeePass Website : https://keepass.info
- Enforced configuration official documentation : https://keepass.info/help/kb/config_enf.html
- Customization official documentation : https://keepass.info/help/v2_dev/customize.html

### Resources
- A case study in Attacking KeePass (@HarmJ0y) : https://blog.harmj0y.net/redteaming/keethief-a-case-study-in-attacking-keepass-part-2/
- Another case study in Attacking Keepass (@HarmJ0y) : https://www.slideshare.net/harmj0y/a-case-study-in-attacking-keepass
- KeePwn : https://github.com/Orange-Cyberdefense/KeePwn
- Webinar "Attaquer et durcir KeePass" (Hamza Kondah) : https://www.linkedin.com/events/7098643529362468864

### FAQ
> Am I protected from keyloggers using this configuration ?
- **Yes and no**. Most currently available keyloggers work only on normal desktops; they do not capture keypresses on secure desktops. So, if you enable the MasterKeyOnSecureDesktop setting, the master key is protected against most keyloggers.

> Is my keepass database protected from an attacker who has access to my machine?
- **Definitely not**. There are multiple ways to recover passwords in memory, or by abusing certain features. Note that if the attacker has write access to your configuration file, he can simply modify or delete it. 

> Is there a better password manager for personal use ?
- Everyone will have their own opinion on this. What I can say is that Keepass is a very good free and open source password manager. The product has been affected by [very few CVEs](https://www.cvedetails.com/vulnerability-list/vendor_id-12214/Keepass.html "[very few CVEs") over the past ten years. None of them were critical.

### TODO
- Add mapping between known attacks and associated mitigations.

[@onSec-fr](https://github.com/onSec-fr "@onSec-fr")
