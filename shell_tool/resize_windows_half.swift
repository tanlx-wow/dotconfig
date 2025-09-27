#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title tile windows (left/right halves)
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 🧱
// @raycast.packageName Window Tools

import Cocoa
import ApplicationServices

// ---------- layout settings ----------
let margin: CGFloat = 16           // outer margin & middle gap
let alternateSides = false         // true → distribute L/R; false → all to left
enum Side { case left, right }
let defaultSide: Side = .left
// ------------------------------------

// Convert a Cocoa rect (bottom-left origin) to AX rect (top-left origin)
func cocoaToAX(_ rect: CGRect, on screen: NSScreen) -> CGRect {
    let screenH = screen.frame.height
    let axY = screenH - rect.origin.y - rect.size.height
    return CGRect(x: rect.origin.x, y: axY, width: rect.size.width, height: rect.size.height)
}

guard let screen = NSScreen.main else {
    print("No screen available.")
    exit(1)
}

// Use visibleFrame so we don't collide with dock/menu bar
let v = screen.visibleFrame

let totalGapX = margin * 3          // left outer + middle gap + right outer
let colWidth  = (v.width - totalGapX) / 2.0
let xLeft     = v.origin.x + margin
let xRight    = v.origin.x + margin * 2 + colWidth

// Ensure BOTH top & bottom margins in Cocoa coordinates
let yCocoa    = v.origin.y + margin
let colHeight = v.height - 2 * margin

let frameLeftCocoa  = CGRect(x: xLeft,  y: yCocoa, width: colWidth, height: colHeight)
let frameRightCocoa = CGRect(x: xRight, y: yCocoa, width: colWidth, height: colHeight)

// Precompute AX-space frames (top-left origin)
let frameLeftAX  = cocoaToAX(frameLeftCocoa,  on: screen)
let frameRightAX = cocoaToAX(frameRightCocoa, on: screen)

// Ask for Accessibility (shows prompt if needed)
let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
guard AXIsProcessTrustedWithOptions(options) else {
    print("Grant Accessibility permissions in System Settings → Privacy & Security → Accessibility.")
    exit(1)
}

let workspace = NSWorkspace.shared

// Skip some bundles that often manage their own windows
let skipBundleIdentifier: Set<String> = [
    "com.apple.finder",
    "com.apple.systempreferences",
    "com.microsoft.Outlook",
    "com.cisco.secureclient.gui",
"com.microsoft.teams2",
]

func setWindowAX(_ win: AXUIElement, to frameAX: CGRect) {
    var pos = frameAX.origin
    var size = frameAX.size
    if let posValue = AXValueCreate(.cgPoint, &pos) {
        AXUIElementSetAttributeValue(win, kAXPositionAttribute as CFString, posValue)
    }
    if let sizeValue = AXValueCreate(.cgSize, &size) {
        AXUIElementSetAttributeValue(win, kAXSizeAttribute as CFString, sizeValue)
    }
}

var placeOnRightNext = false

for app in workspace.runningApplications {
    guard !app.isHidden, app.activationPolicy == .regular else { continue }
    guard let bundleID = app.bundleIdentifier, !skipBundleIdentifier.contains(bundleID) else { continue }

    let appElement = AXUIElementCreateApplication(app.processIdentifier)

    var value: AnyObject?
    let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &value)
    guard result == .success, let windows = value as? [AXUIElement] else { continue }

    for window in windows {
        // Skip minimized windows
        var minimizedObj: AnyObject?
        if AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &minimizedObj) == .success,
           let minimized = minimizedObj as? Bool, minimized { continue }

        let side: Side
        if alternateSides {
            side = placeOnRightNext ? .right : .left
            placeOnRightNext.toggle()
        } else {
            side = defaultSide
        }

        switch side {
        case .left:  setWindowAX(window, to: frameLeftAX)
        case .right: setWindowAX(window, to: frameRightAX)
        }
    }
}
