# GlassWorm Detector

This repository contains PowerShell scripts to detect and protect against the GlassWorm malware campaign that targets VS Code and Cursor extensions.

NO WARRANTIES, [MIT License](LICENSE)

> **⚠️ WARNING:**  
> This list reflects the *current* state of known compromised VS Code and Cursor extensions and IP addresses as of **OCT-22-2025, 11:38:00 EST**.  
> New malicious extensions may be discovered at any time. 

## Background

**GlassWorm** is a sophisticated supply chain attack discovered in October 2025 that uses invisible Unicode characters to hide malicious code in VS Code extensions. The malware spreads through compromised extensions on the OpenVSX and VSCode marketplaces, affecting over 35,800 installations.

### Key Features of GlassWorm:
- **Invisible Code**: Uses Unicode variation selectors to hide malicious code from code editors
- **Blockchain C2**: Uses Solana blockchain for command and control infrastructure
- **Credential Harvesting**: Steals NPM, GitHub, and Git credentials
- **Crypto Wallet Targeting**: Targets 49 different cryptocurrency wallet extensions
- **SOCKS Proxy Deployment**: Turns infected machines into criminal infrastructure
- **Self-Propagating**: Automatically spreads through stolen credentials

For detailed information about the attack, see: [GlassWorm: First Self-Propagating Worm Using Invisible Code Hits OpenVSX Marketplace](https://www.koi.ai/blog/glassworm-first-self-propagating-worm-using-invisible-code-hits-openvsx-marketplace)

## Scripts Overview

### 1. Check-MaliciousExtensions.ps1
**Purpose**: Scans your system for known compromised extensions and their malicious versions.

**Features**:
- Checks both VS Code and Cursor extensions
- Identifies 14 known malicious extensions with specific version numbers
- Provides detailed reporting with installation paths and timestamps
- Supports multiple output formats (detailed, quiet, list all)
- Handles JSON parsing issues in extension manifests

**Usage**:
```powershell
# Basic scan
.\Check-MaliciousExtensions.ps1

# Detailed output with full paths
.\Check-MaliciousExtensions.ps1 -Detailed

# List all extensions (not just malicious ones)
.\Check-MaliciousExtensions.ps1 -ListAll

# List all extensions alphabetically
.\Check-MaliciousExtensions.ps1 -ListAll -Alphabetical

# Quiet mode (minimal output)
.\Check-MaliciousExtensions.ps1 -Quiet
```

### 2. Set-Firewall-Rules.ps1
**Purpose**: Creates Windows Firewall rules to block communication with known GlassWorm command and control servers.

**Features**:
- Blocks inbound and outbound traffic to GlassWorm C2 servers
- Targets specific IP addresses used by the malware
- Provides immediate protection against active infections

**Usage**:
```powershell
# Run as Administrator
.\Set-Firewall-Rules.ps1
```

## Compromised Extensions

The following extensions have been identified as compromised with specific malicious versions:

- `codejoy.codejoy-vscode-extension` (versions 1.8.3, 1.8.4)
- `l-igh-t.vscode-theme-seti-folder` (version 1.2.3)
- `kleinesfilmroellchen.serenity-dsl-syntaxhighlight` (version 0.3.2)
- `JScearcy.rust-doc-viewer` (version 4.2.1)
- `SIRILMP.dark-theme-sm` (version 3.11.4)
- `CodeInKlingon.git-worktree-menu` (versions 1.0.9, 1.0.91)
- `ginfuru.better-nunjucks` (version 0.3.2)
- `ellacrity.recoil` (version 0.7.4)
- `grrrck.positron-plus-1-e` (version 0.0.71)
- `jeronimoekerdt.color-picker-universal` (version 2.8.91)
- `srcery-colors.srcery-colors` (version 0.3.9)
- `sissel.shopify-liquid` (version 4.0.1)
- `TretinV3.forts-api-extention` (version 0.3.1)
- `cline-ai-main.cline-ai-agent` (version 3.1.3)

## Recommended Actions

If malicious extensions are detected:

1. **Immediately uninstall** the compromised extensions
2. **Run a full malware scan** on your system
3. **Change passwords** for any accounts that may have been compromised
4. **Review system logs** for unauthorized access
5. **Apply firewall rules** to block C2 communication
6. **Monitor network traffic** for suspicious activity

## Requirements

- Windows PowerShell 5.1 or PowerShell 7+
- Administrator privileges (for firewall rules)
- VS Code or Cursor installed

## Security Note

This malware campaign is **actively ongoing** as of October 2025. The C2 infrastructure remains operational, and the worm continues to spread through compromised credentials. Regular scanning and monitoring are recommended.

## References

- [Koi Security Research: GlassWorm Analysis](https://www.koi.ai/blog/glassworm-first-self-propagating-worm-using-invisible-code-hits-openvsx-marketplace)
- [OpenVSX Marketplace](https://open-vsx.org/)
- [Microsoft VSCode Marketplace](https://marketplace.visualstudio.com/)
