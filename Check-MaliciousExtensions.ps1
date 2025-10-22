# PowerShell script to check for potentially malicious VS Code/Cursor extensions
# This script checks for known compromised extensions and their versions

param(
    [switch]$Detailed,
    [switch]$Quiet,
    [switch]$ListAll,
    [switch]$Alphabetical
)

# List of compromised extensions with their malicious versions
$MaliciousExtensions = @(
    @{Name="codejoy.codejoy-vscode-extension"; Versions=@("1.8.3", "1.8.4")},
    @{Name="l-igh-t.vscode-theme-seti-folder"; Versions=@("1.2.3")},
    @{Name="kleinesfilmroellchen.serenity-dsl-syntaxhighlight"; Versions=@("0.3.2")},
    @{Name="JScearcy.rust-doc-viewer"; Versions=@("4.2.1")},
    @{Name="SIRILMP.dark-theme-sm"; Versions=@("3.11.4")},
    @{Name="CodeInKlingon.git-worktree-menu"; Versions=@("1.0.9", "1.0.91")},
    @{Name="ginfuru.better-nunjucks"; Versions=@("0.3.2")},
    @{Name="ellacrity.recoil"; Versions=@("0.7.4")},
    @{Name="grrrck.positron-plus-1-e"; Versions=@("0.0.71")},
    @{Name="jeronimoekerdt.color-picker-universal"; Versions=@("2.8.91")},
    @{Name="srcery-colors.srcery-colors"; Versions=@("0.3.9")},
    @{Name="sissel.shopify-liquid"; Versions=@("4.0.1")},
    @{Name="TretinV3.forts-api-extention"; Versions=@("0.3.1")},
    @{Name="cline-ai-main.cline-ai-agent"; Versions=@("3.1.3")}
)

# Function to clean JSON content by removing deprecated envfile key
function Remove-DeprecatedEnvfile {
    param([string]$jsonContent)
    
    # Find the start of the envfile key
    $envfileStart = $jsonContent.IndexOf('"envfile":')
    if ($envfileStart -eq -1) {
        return $jsonContent
    }
    
    # Find the matching closing brace by counting braces
    $braceCount = 0
    $startBrace = $jsonContent.IndexOf('{', $envfileStart)
    $pos = $startBrace
    
    while ($pos -lt $jsonContent.Length) {
        $char = $jsonContent[$pos]
        if ($char -eq '{') {
            $braceCount++
        } elseif ($char -eq '}') {
            $braceCount--
            if ($braceCount -eq 0) {
                # Found the matching closing brace
                $endPos = $pos + 1
                # Remove the entire envfile block
                $before = $jsonContent.Substring(0, $envfileStart)
                $after = $jsonContent.Substring($endPos)
                # Clean up any trailing comma
                $after = $after -replace '^\s*,', ''
                return $before + $after
            }
        }
        $pos++
    }
    
    return $jsonContent
}

# Function to get VS Code extensions
function Get-VSCodeExtensions {
    $extensions = @()
    
    # Check VS Code extensions
    $vscodePaths = @(
        "$env:USERPROFILE\.vscode\extensions",
        "$env:APPDATA\Code\User\extensions"
    )
    
    foreach ($path in $vscodePaths) {
        if (Test-Path $path) {
            $extensionDirs = Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue
            foreach ($dir in $extensionDirs) {
                $packageJson = Join-Path $dir.FullName "package.json"
                if (Test-Path $packageJson) {
                    try {
                        $jsonContent = Get-Content $packageJson -Raw
                        # Remove deprecated lowercase "envfile" key to fix parsing issues
                        $jsonContent = Remove-DeprecatedEnvfile -jsonContent $jsonContent
                        $package = $jsonContent | ConvertFrom-Json
                        $extensions += [PSCustomObject]@{
                            Name = $package.name
                            Version = $package.version
                            Publisher = $package.publisher
                            Path = $dir.FullName
                            Editor = "VS Code"
                            InstallTime = $dir.CreationTime
                        }
                    }
                    catch {
                        if (-not $Quiet) {
                            Write-Warning "Failed to parse package.json in $($dir.FullName)"
                        }
                    }
                }
            }
        }
    }
    
    return $extensions
}

# Function to get Cursor extensions
function Get-CursorExtensions {
    $extensions = @()
    
    # Check Cursor extensions
    $cursorPaths = @(
        "$env:USERPROFILE\.cursor\extensions",
        "$env:APPDATA\Cursor\User\extensions"
    )
    
    foreach ($path in $cursorPaths) {
        if (Test-Path $path) {
            $extensionDirs = Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue
            foreach ($dir in $extensionDirs) {
                $packageJson = Join-Path $dir.FullName "package.json"
                if (Test-Path $packageJson) {
                    try {
                        $jsonContent = Get-Content $packageJson -Raw
                        # Remove deprecated lowercase "envfile" key to fix parsing issues
                        $jsonContent = Remove-DeprecatedEnvfile -jsonContent $jsonContent
                        $package = $jsonContent | ConvertFrom-Json
                        $extensions += [PSCustomObject]@{
                            Name = $package.name
                            Version = $package.version
                            Publisher = $package.publisher
                            Path = $dir.FullName
                            Editor = "Cursor"
                            InstallTime = $dir.CreationTime
                        }
                    }
                    catch {
                        if (-not $Quiet) {
                            Write-Warning "Failed to parse package.json in $($dir.FullName)"
                        }
                    }
                }
            }
        }
    }
    
    return $extensions
}

# Function to check for malicious extensions
function Test-MaliciousExtensions {
    param($Extensions)
    
    $foundMalicious = @()
    
    foreach ($extension in $Extensions) {
        foreach ($malicious in $MaliciousExtensions) {
            if ($extension.Name -eq $malicious.Name) {
                foreach ($maliciousVersion in $malicious.Versions) {
                    if ($extension.Version -eq $maliciousVersion) {
                        $foundMalicious += [PSCustomObject]@{
                            Name = $extension.Name
                            Version = $extension.Version
                            Publisher = $extension.Publisher
                            Path = $extension.Path
                            Editor = $extension.Editor
                            MaliciousVersion = $maliciousVersion
                        }
                    }
                }
            }
        }
    }
    
    return $foundMalicious
}

# Main execution
try {
    if (-not $Quiet) {
        Write-Host "Checking for potentially malicious VS Code/Cursor extensions..." -ForegroundColor Yellow
        Write-Host ""
    }
    
    # Get all extensions
    $allExtensions = @()
    $allExtensions += Get-VSCodeExtensions
    $allExtensions += Get-CursorExtensions
    
    if ($allExtensions.Count -eq 0) {
        if (-not $Quiet) {
            Write-Host "No extensions found in standard locations." -ForegroundColor Yellow
        }
        exit 0
    }
    
    # Handle ListAll switch
    if ($ListAll) {
        if (-not $Quiet) {
            if ($Alphabetical) {
                Write-Host "All extensions sorted alphabetically:" -ForegroundColor Cyan
            } else {
                Write-Host "All extensions sorted by installation time (ascending):" -ForegroundColor Cyan
            }
            Write-Host ""
        }
        
        if ($Alphabetical) {
            $sortedExtensions = $allExtensions | Sort-Object Name
            foreach ($extension in $sortedExtensions) {
                Write-Host "$($extension.Name) v$($extension.Version) ($($extension.Editor))" -ForegroundColor White
                if ($Detailed) {
                    $installTimeStr = $extension.InstallTime.ToString("yyyy-MM-dd HH:mm:ss")
                    Write-Host "    Publisher: $($extension.Publisher)" -ForegroundColor Gray
                    Write-Host "    Installed: $installTimeStr" -ForegroundColor Gray
                    Write-Host "    Path: $($extension.Path)" -ForegroundColor Gray
                }
            }
        } else {
            $sortedExtensions = $allExtensions | Sort-Object InstallTime
            foreach ($extension in $sortedExtensions) {
                $installTimeStr = $extension.InstallTime.ToString("yyyy-MM-dd HH:mm:ss")
                Write-Host "$installTimeStr - $($extension.Name) v$($extension.Version) ($($extension.Editor))" -ForegroundColor White
                if ($Detailed) {
                    Write-Host "    Publisher: $($extension.Publisher)" -ForegroundColor Gray
                    Write-Host "    Path: $($extension.Path)" -ForegroundColor Gray
                }
            }
        }
        
        if (-not $Quiet) {
            Write-Host ""
            Write-Host "Total extensions found: $($allExtensions.Count)" -ForegroundColor Cyan
        }
        exit 0
    }
    
    # Check for malicious extensions
    $maliciousFound = Test-MaliciousExtensions -Extensions $allExtensions
    
    if ($maliciousFound.Count -gt 0) {
        Write-Host "WARNING: Found potentially malicious extensions!" -ForegroundColor Red
        Write-Host ""
        
        foreach ($malicious in $maliciousFound) {
            Write-Host "MALICIOUS EXTENSION DETECTED:" -ForegroundColor Red
            Write-Host "   Name: $($malicious.Name)" -ForegroundColor Red
            Write-Host "   Version: $($malicious.Version)" -ForegroundColor Red
            Write-Host "   Publisher: $($malicious.Publisher)" -ForegroundColor Red
            Write-Host "   Editor: $($malicious.Editor)" -ForegroundColor Red
            if ($Detailed) {
                Write-Host "   Path: $($malicious.Path)" -ForegroundColor Red
            }
            Write-Host ""
        }
        
        Write-Host "RECOMMENDED ACTIONS:" -ForegroundColor Yellow
        Write-Host "1. Immediately uninstall these extensions" -ForegroundColor Yellow
        Write-Host "2. Scan your system for malware" -ForegroundColor Yellow
        Write-Host "3. Change any passwords that may have been compromised" -ForegroundColor Yellow
        Write-Host "4. Review your system for any unauthorized access" -ForegroundColor Yellow
        
        exit 1
    }
    else {
        if (-not $Quiet) {
            Write-Host "No malicious extensions detected." -ForegroundColor Green
            Write-Host "Checked $($allExtensions.Count) extensions across VS Code and Cursor." -ForegroundColor Green
        }
        exit 0
    }
}
catch {
    Write-Error "An error occurred while checking extensions: $($_.Exception.Message)"
    exit 1
}
