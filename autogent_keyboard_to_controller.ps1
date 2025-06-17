& "F:\genshin\Genshin Impact\Genshin Impact game\GenshinImpact.exe"

Get-Process | ForEach-Object {
    try {
        # Check if the process name is "GenshinImpact" (case-insensitive)
        if ($_.Name -ieq "GenshinImpact") {
            # Set GenshinImpact process to highest priority (High)
            $_.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::High
            Write-Output "Set process '$($_.Name)' (ID: $($_.Id)) to High priority."
        }
        else {
            # Set all other processes to the lowest priority (Idle)
            $_.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Idle
            Write-Output "Set process '$($_.Name)' (ID: $($_.Id)) to Idle priority."
        }
    }
    catch {
        # Output a warning message if the priority change fails (e.g., due to insufficient permissions)
        Write-Warning "Could not change priority for process '$($_.Name)' (ID: $($_.Id)): $_"
    }
}


# Start the process
cd "C:\Users\Yousif\Downloads\Programs\Virtual Controller"
$proc = Start-Process "VirtualController.exe" -ArgumentList '/vxbox1' -PassThru

# Wait for the process to start
Start-Sleep -Seconds 1

# Load the necessary assembly for sending keys
Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public class Keyboard {
        [DllImport("user32.dll")]
        public static extern bool PostMessage(IntPtr hWnd, UInt32 Msg, int wParam, int lParam);
    }
"@

# Define constants
$WM_KEYDOWN = 0x100
$WM_KEYUP = 0x101
$VK_F5 = 0x74

# Send the F5 key press to the process
[Keyboard]::PostMessage($proc.MainWindowHandle, $WM_KEYDOWN, $VK_F5, 0)
[Keyboard]::PostMessage($proc.MainWindowHandle, $WM_KEYUP, $VK_F5, 0)

# Minimize the window
$WM_SYSCOMMAND = 0x0112
$SC_MINIMIZE = 0xF020
[Keyboard]::PostMessage($proc.MainWindowHandle, $WM_SYSCOMMAND, $SC_MINIMIZE, 0)


Start-Sleep -s 1111
Get-Process | Where-Object {$_.Name -like "*ZFGameBrowser*"} | Stop-Process
Start-Sleep -s 23
Get-Process | Where-Object {$_.Name -like "*powershell*"} | Stop-Process






