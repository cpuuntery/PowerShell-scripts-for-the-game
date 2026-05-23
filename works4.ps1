# Load necessary assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# Define SendInput, INPUT and MOUSEINPUT via Add-Type
$cs = @'
using System;
using System.Runtime.InteropServices;

namespace Win32 {
    [StructLayout(LayoutKind.Sequential)]
    public struct MOUSEINPUT {
        public int dx;
        public int dy;
        public uint mouseData;
        public uint dwFlags;
        public uint time;
        public IntPtr dwExtraInfo;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct INPUT {
        public uint type; // 0 = INPUT_MOUSE
        public MOUSEINPUT mi;
    }

    public class SendInputWrapper {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern uint SendInput(uint nInputs, [In] INPUT[] pInputs, int cbSize);
    }
}
'@

Add-Type -TypeDefinition $cs -PassThru | Out-Null

# Constants for mouse flags
$MOUSEEVENTF_LEFTDOWN = 0x0002
$MOUSEEVENTF_LEFTUP   = 0x0004

# Function to perform a mouse click at specified coordinates using SendInput
function Click-AtPosition {
    param (
        [int]$x,
        [int]$y  
    )

    # Move the cursor to specified coordinates (kept as original)
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)

    # Wait a bit to allow the cursor movement (adjust if necessary)
    Start-Sleep -Milliseconds 100

    # Build INPUT for left button down
    $inputDown = New-Object Win32.INPUT
    $miDown = New-Object Win32.MOUSEINPUT
    $miDown.dx = 0
    $miDown.dy = 0
    $miDown.mouseData = 0
    $miDown.dwFlags = [uint32]$MOUSEEVENTF_LEFTDOWN
    $miDown.time = 0
    $miDown.dwExtraInfo = [IntPtr]::Zero
    $inputDown.type = 0
    $inputDown.mi = $miDown

    # Build INPUT for left button up
    $inputUp = New-Object Win32.INPUT
    $miUp = New-Object Win32.MOUSEINPUT
    $miUp.dx = 0
    $miUp.dy = 0
    $miUp.mouseData = 0
    $miUp.dwFlags = [uint32]$MOUSEEVENTF_LEFTUP
    $miUp.time = 0
    $miUp.dwExtraInfo = [IntPtr]::Zero
    $inputUp.type = 0
    $inputUp.mi = $miUp

    # Send inputs individually (more robust). Use Marshal.SizeOf on the actual instance.
    $cbSizeDown = [System.Runtime.InteropServices.Marshal]::SizeOf($inputDown)
    $sentDown = [Win32.SendInputWrapper]::SendInput(1, [Win32.INPUT[]]($inputDown), $cbSizeDown)

    # Small pause between down and up can help reliability
    Start-Sleep -Milliseconds 10

    $cbSizeUp = [System.Runtime.InteropServices.Marshal]::SizeOf($inputUp)
    $sentUp = [Win32.SendInputWrapper]::SendInput(1, [Win32.INPUT[]]($inputUp), $cbSizeUp)
}

# Coordinates for clicks
$x1 = 1015
$y1 = 870
$x2 = 1133
$y2 = 677
$x3 = 1533
$y3 = 240

Write-Output "Starting automated clicks. Manual mouse movement to a coordinate other than the scripted ones will break the loop."
Write-Output "Press Ctrl+C to quit at any time."

while ($true) {
    # Perform the scripted clicks
    Click-AtPosition -x $x1 -y $y1
    Start-Sleep -Milliseconds 100
    Click-AtPosition -x $x2 -y $y2
    Start-Sleep -Milliseconds 300
    Click-AtPosition -x $x3 -y $y3
    Start-Sleep -Milliseconds 500
   

    # After the iteration, check current mouse position
    $currentPos = [System.Windows.Forms.Cursor]::Position
    $expectedPos1 = New-Object System.Drawing.Point($x1, $y1)
    $expectedPos2 = New-Object System.Drawing.Point($x2, $y2)
    $expectedPos3 = New-Object System.Drawing.Point($x3, $y3)

    # Acceptable conditions: position equals either of the two scripted coordinates.
    if ( ($currentPos.X -eq $expectedPos1.X -and $currentPos.Y -eq $expectedPos1.Y) -or 
         ($currentPos.X -eq $expectedPos2.X -and $currentPos.Y -eq $expectedPos2.Y) -or
         ($currentPos.X -eq $expectedPos3.X -and $currentPos.Y -eq $expectedPos3.Y)      ) {
         Write-Output "Mouse position is as expected: ($($currentPos.X), $($currentPos.Y)). Continuing loop."
    }
    else {
         Write-Output "Mouse moved to ($($currentPos.X), $($currentPos.Y)) which is not a scripted coordinate. Exiting loop."
         break
    }
}
