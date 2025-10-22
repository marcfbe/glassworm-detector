New-NetFirewallRule -DisplayName "Block Glassworm In" -Direction Inbound -RemoteAddress 217.69.3.218 -Action Block
New-NetFirewallRule -DisplayName "Block Glassworm Out" -Direction Outbound -RemoteAddress 217.69.3.218 -Action Block
New-NetFirewallRule -DisplayName "Block Glassworm In" -Direction Inbound -RemoteAddress 140.82.52.31 -Action Block
New-NetFirewallRule -DisplayName "Block Glassworm Out" -Direction Outbound -RemoteAddress 140.82.52.31 -Action Block
