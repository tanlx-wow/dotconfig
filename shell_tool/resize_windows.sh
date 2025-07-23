
#!/bin/bash

menu_bar_height=$(swift -e 'import Cocoa; if let s = NSScreen.main { print(Int(s.frame.height - s.visibleFrame.height)) }')
osascript <<EOF
-- Raycast-style Almost Maximize with 32px margin, including under menu bar

set margin to 32

set menuBarHeight to $menu_bar_height -- typical macOS menu bar height

-- Get screen size including menu bar
tell application "Finder"
    set screenBounds to bounds of window of desktop
    set screenWidth to item 3 of screenBounds
    set screenHeight to item 4 of screenBounds
end tell

-- Adjust for margins and menu bar
set newX to margin
set newY to margin + menuBarHeight
set newWidth to screenWidth - 2 * margin
set newHeight to screenHeight - newY - margin

-- Resize all visible windows of all apps
tell application "System Events"
    set appList to name of every process whose visible is true and background only is false
    repeat with appName in appList
        try
            tell process appName
                repeat with w in windows
                    set position of w to {newX, newY}
                    set size of w to {newWidth, newHeight}
                end repeat
            end tell
        end try
    end repeat
end tell
EOF

