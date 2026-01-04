#!/usr/bin/swift


// Documentation:
// resize all windows based on display resolution
// author TLX

import Cocoa
import ApplicationServices

let margin: CGFloat = 16

guard let screen = NSScreen.main else {
    print("No screen available.")
    exit(1)
}

// Convert Cocoa (bottom-left) to AX (top-left) coordinates
func cocoaToAX(_ rect: CGRect, on screen: NSScreen) -> CGRect {
    let screenH = screen.frame.height
    let axY = screenH - rect.origin.y - rect.size.height
    return CGRect(x: rect.origin.x, y: axY, width: rect.size.width, height: rect.size.height)
}

let v = screen.visibleFrame

// Calculate Max Rect (Cocoa coordinates)
// Apply margins within the visible frame
let x = v.origin.x + margin
let y = v.origin.y + margin
let width = v.width - 2 * margin
let height = v.height - 2 * margin

let cocoaRect = CGRect(x: x, y: y, width: width, height: height)
let axRect = cocoaToAX(cocoaRect, on: screen)

let newPosition = axRect.origin
let newSize = axRect.size

let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
guard AXIsProcessTrustedWithOptions(options) else {
    print("Grant Accessibility permissions in System Settings → Privacy & Security → Accessibility.")
    exit(1)
}

let workspace = NSWorkspace.shared

for app in workspace.runningApplications {
    guard !app.isHidden, app.activationPolicy == .regular else { continue }

    // Skip windows
    let skipBundleIdentifier: Set<String> = [
        "com.apple.finder",
        "com.apple.systempreferences",
        "com.cisco.secureclient.gui",
        "com.microsoft.teams2",
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
