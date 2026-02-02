#!/usr/bin/swift


// Documentation:
// resize all windows based on display resolution (per screen)
// author TLX & Opencode

import Cocoa
import ApplicationServices

let margin: CGFloat = 16

guard let primaryScreen = NSScreen.screens.first else {
    print("No screens available")
    exit(1)
}
let primaryHeight = primaryScreen.frame.height

// Convert AX (top-left) to Cocoa (bottom-left) coordinates
func axToCocoa(_ axFrame: CGRect) -> CGRect {
    let y = primaryHeight - axFrame.origin.y - axFrame.size.height
    return CGRect(x: axFrame.origin.x, y: y, width: axFrame.size.width, height: axFrame.size.height)
}

// Convert Cocoa (bottom-left) to AX (top-left) coordinates
func cocoaToAX(_ cocoaFrame: CGRect) -> CGRect {
    let y = primaryHeight - cocoaFrame.origin.y - cocoaFrame.size.height
    return CGRect(x: cocoaFrame.origin.x, y: y, width: cocoaFrame.size.width, height: cocoaFrame.size.height)
}

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
        "com.teamviewer.TeamViewer",
    ]
    guard let bundleID = app.bundleIdentifier, !skipBundleIdentifier.contains(bundleID) else { continue }

    let appElement = AXUIElementCreateApplication(app.processIdentifier)
    var value: AnyObject?

    let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &value)
    guard result == .success, let windows = value as? [AXUIElement] else { continue }

    for window in windows {
        // Get current frame
        var pos = CGPoint.zero
        var size = CGSize.zero
        var posValue: AnyObject?
        var sizeValue: AnyObject?

        AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &posValue)
        AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeValue)

        if let p = posValue, AXValueGetType(p as! AXValue) == .cgPoint {
            AXValueGetValue(p as! AXValue, .cgPoint, &pos)
        }
        if let s = sizeValue, AXValueGetType(s as! AXValue) == .cgSize {
            AXValueGetValue(s as! AXValue, .cgSize, &size)
        }

        let currentCocoaFrame = axToCocoa(CGRect(origin: pos, size: size))

        // Find which screen the window is mostly on
        var targetScreen: NSScreen?
        var maxIntersectionArea: CGFloat = 0
        for screen in NSScreen.screens {
            let intersection = currentCocoaFrame.intersection(screen.frame)
            let area = intersection.width * intersection.height
            if area > maxIntersectionArea {
                maxIntersectionArea = area
                targetScreen = screen
            }
        }
        // Fallback to main if completely off-screen
        let screen = targetScreen ?? NSScreen.main!

        var v = screen.visibleFrame

        if let primary = NSScreen.screens.first {
            let primaryTopInset = primary.frame.maxY - primary.visibleFrame.maxY
            let currentTopInset = screen.frame.maxY - v.maxY
            if currentTopInset < (primaryTopInset - 5) {
                let missingHeight = primaryTopInset - currentTopInset
                v.size.height -= missingHeight
            }
        }

        // Calculate Max Rect (Cocoa coordinates)
        let x = v.origin.x + margin
        let y = v.origin.y + margin
        let width = v.width - 2 * margin
        let height = v.height - 2 * margin

        let newCocoaRect = CGRect(x: x, y: y, width: width, height: height)
        let newAXRect = cocoaToAX(newCocoaRect)

        var newPos = newAXRect.origin
        var newSize = newAXRect.size

        if let posValue = AXValueCreate(.cgPoint, &newPos),
           let sizeValue = AXValueCreate(.cgSize, &newSize) {
            AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, posValue)
            AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
        }
    }
}
