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
let margin: CGFloat = 32           // outer margin & gap between columns
let alternateSides = true           // true → distribute L/R; false → all to left
enum Side { case left, right }
let defaultSide: Side = .left
// ------------------------------------

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
let yPos      = v.origin.y + margin
let colHeight = v.height - 2 * margin

let frameLeft  = CGRect(x: xLeft,  y: yPos, width: colWidth, height: colHeight)
let frameRight = CGRect(x: xRight, y: yPos, width: colWidth, height: colHeight)

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
]

func setWindow(_ win: AXUIElement, to frame: CGRect) {
    var pos = frame.origin
    var size = frame.size
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
        // Skip minimized / invisible windows
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
        case .left:  setWindow(window, to: frameLeft)
        case .right: setWindow(window, to: frameRight)
        }
    }
}
