# Define the Win32 API function SendMessage
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Win32 {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
}
"@

# Constants
$WM_SYSCOMMAND = 0x0112
$SC_SCREENSAVE = 0xF140

# HWND_BROADCAST = 0xffff (send to all top-level windows)
$HWND_BROADCAST = [IntPtr]0xffff

# Call the API to start the screensaver
[Win32]::SendMessage($HWND_BROADCAST, $WM_SYSCOMMAND, [IntPtr]$SC_SCREENSAVE, [IntPtr]::Zero)
