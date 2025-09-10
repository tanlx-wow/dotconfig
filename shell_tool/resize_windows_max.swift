#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title maximize all windows
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 🤖

// Documentation:
// @raycast.description resize all windows based on display resolution
// @raycast.author TLX

import Cocoa
import ApplicationServices

let margin: CGFloat = 16

guard let screen = NSScreen.main else {
    print("No screen available.")
    exit(1)
}
let fullFrame = screen.frame
let visible = screen.visibleFrame
let menuBarHeight = fullFrame.height - visible.height

let newX = visible.origin.x + margin
let newY = margin +  menuBarHeight
let newWidth = visible.width - 2 * margin
let newHeight = fullFrame.height - newY - margin

let newPosition = CGPoint(x: newX, y: newY)
let newSize = CGSize(width: newWidth, height: newHeight)

let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
guard AXIsProcessTrustedWithOptions(options) else {
    print("Grant Accessibility permissions in System Settings → Privacy & Security → Accessibility.")
    exit(1)
}

let workspace = NSWorkspace.shared

for app in workspace.runningApplications {
    guard !app.isHidden, app.activationPolicy == .regular else { continue }

    // Skip  windows
    let skipBundleIdentifier: Set<String> = [
        "com.apple.finder",
        "com.apple.systempreferences",
        "com.cisco.secureclient.gui"
    ]
    guard let bundleID = app.bundleIdentifier, !skipBundleIdentifier.contains(bundleID) else { continue }

    let appElement = AXUIElementCreateApplication(app.processIdentifier)
    var value: AnyObject?

    let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &value)
    guard result == .success, let windows = value as? [AXUIElement] else { continue }

    for window in windows {
        var pos = newPosition
        var size = newSize

        if let posValue = AXValueCreate(.cgPoint, &pos),
           let sizeValue = AXValueCreate(.cgSize, &size) {
            AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, posValue)
            AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
        }
    }
}

