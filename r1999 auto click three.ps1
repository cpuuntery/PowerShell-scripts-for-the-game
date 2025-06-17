# Load necessary assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# Define mouse_event function from user32.dll
$signature = @'
[DllImport("user32.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@
$SendMouseClick = Add-Type -MemberDefinition $signature -Name "Win32MouseEventNew" -Namespace Win32Functions -PassThru

# Function to perform a mouse click at specified coordinates
function Click-AtPosition {
    param (
        [int]$x,
        [int]$y  
    )
    # Move the cursor to specified coordinates
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    # Wait a bit to allow the cursor movement (adjust if necessary)
    Start-Sleep -Milliseconds 100
    # Perform a left-click (down then up)
    $SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0) # Left button down
    $SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0) # Left button up
}

# Coordinates for clicks
$x1 = 1015
$y1 = 870
$x2 = 
$y2 = 
$x3 = 1533
$y3 = 239

Write-Output "Starting automated clicks. Manual mouse movement to a coordinate other than the scripted ones will break the loop."
Write-Output "Press Ctrl+C to quit at any time."

while ($true) {
    # Perform the two scripted clicks
    Click-AtPosition -x $x1 -y $y1
    Click-AtPosition -x $x2 -y $y2
    Click-AtPosition -x $x3 -y $y3

    # After the iteration, check current mouse position
    $currentPos = [System.Windows.Forms.Cursor]::Position
    $expectedPos1 = New-Object System.Drawing.Point($x1, $y1)
    $expectedPos2 = New-Object System.Drawing.Point($x2, $y2)
    $expectedPos3 = New-Object System.Drawing.Point($x3, $y3)

    # Acceptable conditions: position equals either of the two scripted coordinates.
    if ( ($currentPos.X -eq $expectedPos1.X -and $currentPos.Y -eq $expectedPos1.Y) -or 
         ($currentPos.X -eq $expectedPos2.X -and $currentPos.Y -eq $expectedPos2.Y) -or
		 ($currentPos.X -eq $expectedPos3.X -and $currentPos.Y -eq $expectedPos3.Y)		 ) {
         Write-Output "Mouse position is as expected: ($($currentPos.X), $($currentPos.Y)). Continuing loop."
    }
    else {
         Write-Output "Mouse moved to ($($currentPos.X), $($currentPos.Y)) which is not a scripted coordinate. Exiting loop."
         break
    }
}
