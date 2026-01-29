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
    "com.ThomsonResearchSoft.EndNote",
    "com.teamviewer.TeamViewer",
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

        // Get current frame to find screen
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
        let screen = targetScreen ?? NSScreen.main!
        
        // Calculate frames for this screen
        let v = screen.visibleFrame
        let totalGapX = margin * 3
        let colWidth  = (v.width - totalGapX) / 2.0
        let xLeft     = v.origin.x + margin
        let xRight    = v.origin.x + margin * 2 + colWidth
        let yCocoa    = v.origin.y + margin
        let colHeight = v.height - 2 * margin
        
        let frameLeftCocoa  = CGRect(x: xLeft,  y: yCocoa, width: colWidth, height: colHeight)
        let frameRightCocoa = CGRect(x: xRight, y: yCocoa, width: colWidth, height: colHeight)
        
        let frameLeftAX  = cocoaToAX(frameLeftCocoa)
        let frameRightAX = cocoaToAX(frameRightCocoa)

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
