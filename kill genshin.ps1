Get-Process | Where-Object {$_.Name -like "*GenshinImpact*"} | Stop-Process
Get-Process | Where-Object {$_.Name -like "*ZFGameBrowser*"} | Stop-Process
Get-Process | Where-Object {$_.Name -like "*VirtualController*"} | Stop-Process

Get-Process | ForEach-Object {
    try {
            # Set all other processes to the Normal priority (Normal)
            $_.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Normal
            Write-Output "Set process '$($_.Name)' (ID: $($_.Id)) to Normal priority."
        
    }
    catch {
        # Output a warning message if the priority change fails (e.g., due to insufficient permissions)
        Write-Warning "Could not change priority for process '$($_.Name)' (ID: $($_.Id)): $_"
    }
}

Start-Sleep -Seconds 1

Get-Process | Where-Object {$_.Name -like "*powershell*"} | Stop-Process