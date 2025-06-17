Get-Process | Where-Object {$_.Name -like "*GenshinImpact*"} | Stop-Process
Get-Process | Where-Object {$_.Name -like "*ZFGameBrowser*"} | Stop-Process
Get-Process | Where-Object {$_.Name -like "*VirtualController*"} | Stop-Process
Get-Process | Where-Object {$_.Name -like "*powershell*"} | Stop-Process