# KeePass Enhanced Security Configuration

**Make your keepass more secure** using the [enforced configuration file](https://keepass.info/help/kb/config_enf.html), an official but often overlooked KeePass feature.

![](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/icon.ico?raw=true)

## TL;DR — Harden KeePass in 30 seconds 🚀

Just copy one file. No configuration required.

1. Download [KeePass.config.enforced.xml](KeePass.config.enforced.xml) from this repository
2. Copy it to your KeePass installation directory (e.g., `C:\Program Files\KeePass Password Safe 2\`)
3. Restart KeePass

That's it. Over 30 security settings are now enforced — attack surface reduced, dangerous features disabled.

---

- [Introduction](#introduction)
- [General Considerations](#general-considerations)
- [Existing Installation](#existing-installation)
- [Automatic Installation](#automatic-installation)
  - [Parameters](#parameters)
  - [Usage](#usage)
- [Configuration File](#configuration-file)
  - [Sample File](#sample-file)
  - [Settings Description](#settings-description)
  - [Screenshots](#screenshots)
  - [Additional Settings](#additional-settings)
- [References](#references)
- [Resources](#resources)
- [FAQ](#faq)
- [TODO](#todo)

## Introduction

[KeePass](https://keepass.info) is a widely used open-source password manager. However, its broad feature set increases the potential attack surface, and [several attack techniques](https://blog.harmj0y.net/redteaming/keethief-a-case-study-in-attacking-keepass-part-2/) targeting KeePass are publicly documented.

The goal of this project is to disable unnecessary features and enable all security mechanisms that are not active by default, using the [enforced configuration file](https://keepass.info/help/kb/config_enf.html).

## General Considerations

- Download KeePass **[from its official website](https://keepass.info)** only, and **[verify the integrity](https://keepass.info/integrity.html)** of the downloaded file.
- If using the portable version, **restrict write access to the KeePass installation directory** to your user account only, to protect the configuration file from tampering.
- **Increase the key derivation iteration count** for your database (default: 60,000). Use the *1 Second Delay* button to set an appropriate value automatically.
- **Lock the database** when not in use.
- **Use a [key file](https://keepass.info/help/base/keys.html#keyfiles)** in addition to the master password. The key file must not be stored in the same location as the database.
- **Consider KeePass 1.x**, which has a smaller feature set and a reduced attack surface. See the [edition comparison](https://keepass.info/compare.html).

> [KeePwn](https://github.com/Orange-Cyberdefense/KeePwn) is a Python tool that automates KeePass discovery and credential extraction — useful for understanding the threat model.

## Environment-Specific Considerations

This project provides a baseline hardening configuration. Some settings may be incompatible with your environment or security policy.

- **Review the configuration file** before deploying it to ensure it does not disable features required in your environment.
- In a corporate environment, **adjust settings to match your security policy**.
- The configuration **disables automatic updates** to protect against supply-chain attacks on the update mechanism. You are responsible for keeping KeePass up to date manually. Automatic updates can be re-enabled by removing the relevant entries from the file.
- Any user with write access to the enforced configuration file can modify or remove it. In a corporate environment, **deploy this file via Group Policy (GPO)**. For personal use, avoid running KeePass under a local administrator account.
- Administrators may **restrict execution of other KeePass-compatible clients** using Application Control, AppLocker, or Software Restriction Policies.

## Existing Installation

Copy [KeePass.config.enforced.xml](KeePass.config.enforced.xml) to the root of the KeePass installation directory. This also works with portable installations.  
**Settings take effect on the next KeePass launch.**

## Automatic Installation

The **KeePass_Secure_Auto_Install.ps1** script fully automates the installation and configuration of KeePass.

The script performs the following steps:
1. **Downloads** the latest KeePass version from the official website
2. **Verifies** file integrity by comparing the SHA-256 hash against the official value
3. **Copies** the enforced configuration file to the installation directory
4. **Restricts** permissions on the KeePass installation folder (optional, see `-EnforceACL`)

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `-ConfigFile` | No | `.\KeePass.config.enforced.xml` | Path to the enforced configuration file |
| `-EnforceACL` | No | `$false` | Restrict the KeePass installation directory to the current user only |

### Usage

```powershell
# Default
.\KeePass_Secure_Auto_Install.ps1

# With a custom configuration file and ACL enforcement
.\KeePass_Secure_Auto_Install.ps1 -ConfigFile "C:\path\to\file.xml" -EnforceACL $true
```

[![](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/auto_install.gif?raw=true)](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/auto_install.png?raw=true)

## Configuration File

From the [official documentation](https://keepass.info/help/kb/config_enf.html#info):

> The format of an enforced configuration file is basically the same as the format of a regular configuration file. An enforced configuration file must be stored in the KeePass application directory (which contains KeePass.exe). Its name depends on the KeePass edition:
> - KeePass 1.x: KeePass.enforced.ini.
> - KeePass 2.x: KeePass.config.enforced.xml.

### Sample File

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
		<!-- 2   = Disable 'Tools' → 'Plugins' menu item       -->
		<!-- 4   = Disable 'Tools' → 'Triggers' menu item      -->
		<!-- 32  = Disable 'Help'  → 'Check for Updates' item  -->
		<!-- 64  = Disable 'Tools' → 'XML Replace' menu item   -->
		<!-- Total : 2 + 4 + 32 + 64 = 102                     -->
		<UIFlags>102</UIFlags>
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
			<AutoTypeWithoutContext>false</AutoTypeWithoutContext>
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

### Settings Description

| XPath | Parameter | Value | Description |
|-------|-----------|-------|-------------|
| `/Configuration/Application/TriggerSystem/Enabled` | TriggerSystem Enabled | `false` | Disables the trigger system entirely. No automated triggers are executed. |
| `/Configuration/Application/TriggerSystem/Triggers` | Triggers (`MergeContentMode="Replace"`) | *(empty)* | Replaces the trigger list with an empty one, removing any pre-existing triggers. |
| `/Configuration/Application/Start/CheckForUpdate` | CheckForUpdate | `false` | Disables automatic update checks. Updates must be performed manually. |
| `/Configuration/Application/Start/CheckForUpdateConfigured` | CheckForUpdateConfigured | `true` | Marks the update check setting as configured, preventing KeePass from prompting the user. |
| `/Configuration/UI/UIFlags` | UIFlags | `102` | Bitmask hiding UI menu items. `2`=Plugins, `4`=Triggers, `32`=Check for Updates, `64`=XML Replace. Total: 2+4+32+64=102. |
| `/Configuration/Security/Policy/ChangeMasterKeyNoKey` | ChangeMasterKeyNoKey | `false` | Prevents changing the master key without first entering the current one. |
| `/Configuration/Security/Policy/PrintNoKey` | PrintNoKey | `false` | Disallows printing when the database is locked. |
| `/Configuration/Security/Policy/EditTriggers` | EditTriggers | `false` | Prevents creating or editing triggers. |
| `/Configuration/Security/Policy/Plugins` | Plugins | `false` | Disables plugin support entirely. |
| `/Configuration/Security/Policy/Export` | Export | `false` | Disables database export. |
| `/Configuration/Security/Policy/ExportNoKey` | ExportNoKey | `false` | Disallows export when the database is locked. |
| `/Configuration/Security/Policy/Import` | Import | `false` | Disables database import. |
| `/Configuration/Security/Policy/Print` | Print | `false` | Disables entry printing. |
| `/Configuration/Security/Policy/CopyWholeEntries` | CopyWholeEntries | `false` | Prevents copying complete entries (username and password combined). |
| `/Configuration/Security/Policy/DragDrop` | DragDrop | `false` | Disables drag-and-drop of entries. |
| `/Configuration/Security/Policy/UnhidePasswords` | UnhidePasswords | `false` | Prevents unmasking of password fields. |
| `/Configuration/Security/Policy/AutoTypeWithoutContext` | AutoTypeWithoutContext | `false` | Disables the global auto-type hotkey when no target window is matched, preventing credential injection into unintended windows. |
| `/Configuration/Security/WorkspaceLocking/LockOnSessionSwitch` | LockOnSessionSwitch | `true` | Locks the workspace when switching user sessions. |
| `/Configuration/Security/WorkspaceLocking/LockOnSuspend` | LockOnSuspend | `true` | Locks KeePass when the system suspends or hibernates. |
| `/Configuration/Security/WorkspaceLocking/LockAfterTime` | LockAfterTime | `3600` | Locks KeePass after 3,600 seconds (1 hour) of KeePass inactivity. |
| `/Configuration/Security/WorkspaceLocking/LockAfterGlobalTime` | LockAfterGlobalTime | `600` | Locks KeePass after 600 seconds (10 minutes) of system-wide inactivity. |
| `/Configuration/Security/WorkspaceLocking/LockOnRemoteControlChange` | LockOnRemoteControlChange | `true` | Locks KeePass when the remote control state changes (e.g., an RDP session connects or disconnects). |
| `/Configuration/Security/MasterPassword/MinimumLength` | MinimumLength | `16` | Requires the master password to be at least 16 characters long. |
| `/Configuration/Security/MasterPassword/MinimumQuality` | MinimumQuality | `80` | Enforces a minimum password quality score of 80. |
| `/Configuration/Security/MasterPassword/RememberWhileOpen` | RememberWhileOpen | `false` | Prevents KeePass from caching the master key in memory while the database is open. |
| `/Configuration/Security/MasterKeyOnSecureDesktop` | MasterKeyOnSecureDesktop | `true` | Displays the master key prompt on the Windows secure desktop, protecting entry against most keyloggers. |
| `/Configuration/Security/ClipboardClearAfterSeconds` | ClipboardClearAfterSeconds | `10` | Clears clipboard contents 10 seconds after a field is copied. |
| `/Configuration/Security/ProtectProcessWithDacl` | ProtectProcessWithDacl | `true` | Applies a restrictive DACL to the KeePass process, blocking other processes from reading its memory. |
| `/Configuration/Security/PreventScreenCapture` | PreventScreenCapture | `true` | Prevents screen capture of KeePass windows. |
| `/Configuration/PasswordGenerator/AutoGeneratedPasswordsProfile/GeneratorType` | GeneratorType | `CharSet` | Uses character set-based password generation. |
| `/Configuration/PasswordGenerator/AutoGeneratedPasswordsProfile/Length` | Length | `12` | Default length for auto-generated passwords. |
| `/Configuration/PasswordGenerator/AutoGeneratedPasswordsProfile/CharSetRanges` | CharSetRanges | `ULDS______` | Character sets used: U=uppercase, L=lowercase, D=digits, S=special characters. |
| `/Configuration/PasswordGenerator/AutoGeneratedPasswordsProfile/ExcludeLookAlike` | ExcludeLookAlike | `true` | Excludes visually similar characters (e.g., `O`/`0`, `l`/`1`). |
| `/Configuration/PasswordGenerator/AutoGeneratedPasswordsProfile/NoRepeatingCharacters` | NoRepeatingCharacters | `true` | Ensures no character appears more than once in a generated password. |
| `/Configuration/Integration/ProxyType` | ProxyType | `System` | Uses the system proxy configuration. |
| `/Configuration/Integration/ProxyAuthType` | ProxyAuthType | `Auto` | Uses automatic proxy authentication. |

### Screenshots

Enforced settings in the KeePass options dialog:

[![](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/enforced_settings.png?raw=true)](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/enforced_settings.png?raw=true)

KeePass process protected against memory dumping and alteration:

[![](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/after_dacl_protect.png?raw=true)](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/after_dacl_protect.png?raw=true)

Restricted operations (plugins, export, and other disabled features):

[![](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/disallowed.png?raw=true)](https://github.com/onSec-fr/Keepass-Enhanced-Security-Configuration/blob/main/res/disallowed.png?raw=true)

### Additional Settings

Not all KeePass settings are exposed in the UI or formally documented. To discover additional enforceable options, follow the procedure recommended in the official documentation:

> 1. Download the portable ZIP package of KeePass and unpack it. Run KeePass, configure everything as desired, and exit.
> 2. Rename the resulting configuration file to the enforced configuration file name.
> 3. Open the file in a text editor and remove any settings you do not wish to enforce.
>
> **Note:** not all settings are configurable through the UI.

## References

- [KeePass official website](https://keepass.info)
- [Enforced configuration documentation](https://keepass.info/help/kb/config_enf.html)
- [Customization documentation](https://keepass.info/help/v2_dev/customize.html)

## Resources

- [A Case Study in Attacking KeePass – Part 2](https://blog.harmj0y.net/redteaming/keethief-a-case-study-in-attacking-keepass-part-2/) (@HarmJ0y)
- [A Case Study in Attacking KeePass – Slides](https://www.slideshare.net/harmj0y/a-case-study-in-attacking-keepass) (@HarmJ0y)
- [KeePwn](https://github.com/Orange-Cyberdefense/KeePwn) – automated KeePass discovery and credential extraction
- [Hardening KeePass configuration (IT-Connect, FR)](https://www.it-connect.fr/comment-durcir-la-configuration-de-keepass/)
- [Webinar: Attaquer et durcir KeePass](https://www.linkedin.com/events/7098643529362468864) (Hamza Kondah)

## FAQ

**Am I protected against keyloggers with this configuration?**

Partially. Most keyloggers operate on the standard desktop and cannot capture keystrokes entered on the Windows secure desktop. Enabling `MasterKeyOnSecureDesktop` therefore protects master key entry against the majority of keyloggers.

**Is my KeePass database protected if an attacker has access to my machine?**

No. A local attacker has multiple avenues to recover credentials, including memory analysis and feature abuse. If the attacker has write access to the configuration file, they can simply modify or delete it.

**Is there a better password manager for personal use?**

KeePass is a solid, free, and open-source password manager with [very few CVEs](https://www.cvedetails.com/vulnerability-list/vendor_id-12214/Keepass.html) over its history, none of them critical. The appropriate choice depends on individual requirements and threat model.

## TODO

- Add mapping between known attacks and associated mitigations.

[@onSec-fr](https://github.com/onSec-fr)
