# Load necessary assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# Define SendInput and supporting structures
$signature = @'
using System;
using System.Runtime.InteropServices;

namespace Win32Functions {
    public class Win32SendInput {
        [StructLayout(LayoutKind.Sequential)]
        public struct INPUT {
            public int type;
            public MOUSEINPUT mi;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct MOUSEINPUT {
            public int dx;
            public int dy;
            public int mouseData;
            public int dwFlags;
            public int time;
            public IntPtr dwExtraInfo;
        }

        [DllImport("user32.dll", SetLastError=true)]
        public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

        public const int INPUT_MOUSE = 0;
        public const int MOUSEEVENTF_MOVE = 0x0001;
        public const int MOUSEEVENTF_LEFTDOWN = 0x0002;
        public const int MOUSEEVENTF_LEFTUP = 0x0004;
    }
}
'@

Add-Type -TypeDefinition $signature

# Function to send a mouse event
function Send-MouseEvent {
    param (
        [int]$flag
    )
    $input = New-Object Win32Functions.Win32SendInput+INPUT
    $input.type = [Win32Functions.Win32SendInput]::INPUT_MOUSE
    $mi = New-Object Win32Functions.Win32SendInput+MOUSEINPUT
    $mi.dx = 0
    $mi.dy = 0
    $mi.mouseData = 0
    $mi.dwFlags = $flag
    $mi.time = 0
    $mi.dwExtraInfo = [IntPtr]::Zero
    $input.mi = $mi

    $size = [System.Runtime.InteropServices.Marshal]::SizeOf($input)
    [Win32Functions.Win32SendInput]::SendInput(1, @($input), $size) | Out-Null
}

# Function to perform a mouse click at specified coordinates
function Click-AtPosition {
    param (
        [int]$x,
        [int]$y  
    )
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    Start-Sleep -Milliseconds 100

    Send-MouseEvent -flag ([Win32Functions.Win32SendInput]::MOUSEEVENTF_LEFTDOWN)
    Send-MouseEvent -flag ([Win32Functions.Win32SendInput]::MOUSEEVENTF_LEFTUP)
}

# Coordinates for clicks
$x1 = 1015; $y1 = 870
$x2 = 1133; $y2 = 677
$x3 = 1533; $y3 = 240

Write-Output "Starting automated clicks. Manual mouse movement to a coordinate other than the scripted ones will break the loop."
Write-Output "Press Ctrl+C to quit at any time."

while ($true) {
    Click-AtPosition -x $x1 -y $y1
    Start-Sleep -Milliseconds 100
    Click-AtPosition -x $x2 -y $y2
    Start-Sleep -Milliseconds 300
    Click-AtPosition -x $x3 -y $y3
    Start-Sleep -Milliseconds 500

    $currentPos = [System.Windows.Forms.Cursor]::Position
    $expectedPos1 = New-Object System.Drawing.Point($x1, $y1)
    $expectedPos2 = New-Object System.Drawing.Point($x2, $y2)
    $expectedPos3 = New-Object System.Drawing.Point($x3, $y3)

    if ( ($currentPos.Equals($expectedPos1)) -or 
         ($currentPos.Equals($expectedPos2)) -or
         ($currentPos.Equals($expectedPos3)) ) {
         Write-Output "Mouse position is as expected: ($($currentPos.X), $($currentPos.Y)). Continuing loop."
    }
    else {
         Write-Output "Mouse moved to ($($currentPos.X), $($currentPos.Y)) which is not a scripted coordinate. Exiting loop."
         break
    }
}
