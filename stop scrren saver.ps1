# Define the SetThreadExecutionState function from kernel32.dll
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class PowerHelper {
    [Flags]
    public enum EXECUTION_STATE : uint {
        ES_AWAYMODE_REQUIRED = 0x00000040,
        ES_CONTINUOUS        = 0x80000000,
        ES_DISPLAY_REQUIRED  = 0x00000002,
        ES_SYSTEM_REQUIRED   = 0x00000001
    }

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern EXECUTION_STATE SetThreadExecutionState(EXECUTION_STATE esFlags);
}
"@

try {
    Write-Host "Preventing system sleep..."
    # Apply ES_CONTINUOUS (keeps system awake until cleared)
    [PowerHelper]::SetThreadExecutionState(
    [PowerHelper+EXECUTION_STATE]::ES_CONTINUOUS -bor 
    [PowerHelper+EXECUTION_STATE]::ES_SYSTEM_REQUIRED -bor 
    [PowerHelper+EXECUTION_STATE]::ES_DISPLAY_REQUIRED
)


    # Keep script running until user stops it (Ctrl+C or close)
    while ($true) {
        Start-Sleep -Seconds 5
    }
}
finally {
    Write-Host "Restoring normal sleep behavior..."
    # Clear the flag by calling with ES_CONTINUOUS only (no SYSTEM_REQUIRED/DISPLAY_REQUIRED)
    [PowerHelper]::SetThreadExecutionState([PowerHelper+EXECUTION_STATE]::ES_CONTINUOUS)
}
