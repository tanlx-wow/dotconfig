#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Tilt Window Bottom
// @raycast.mode silent

// Optional parameters:
// @raycast.icon ⬇️

// Documentation:
// @raycast.description Align the frontmost window to the bottom edge of the screen it is currently on
// @raycast.author Opencode

import Cocoa
import ApplicationServices

let margin: CGFloat = 16

// helper: get the height of the primary screen (screen 0) for coordinate flipping
guard let primaryScreen = NSScreen.screens.first else {
    print("No screens available")
    exit(1)
}
let primaryHeight = primaryScreen.frame.height

func axToCocoa(_ axFrame: CGRect) -> CGRect {
    // AX: Origin top-left, Y down
    // Cocoa: Origin bottom-left, Y up (relative to primary screen bottom-left)
    // y_cocoa = H_primary - y_ax - h_rect
    let y = primaryHeight - axFrame.origin.y - axFrame.size.height
    return CGRect(x: axFrame.origin.x, y: y, width: axFrame.size.width, height: axFrame.size.height)
}

func cocoaToAX(_ cocoaFrame: CGRect) -> CGRect {
    // y_ax = H_primary - y_cocoa - h_rect
    let y = primaryHeight - cocoaFrame.origin.y - cocoaFrame.size.height
    return CGRect(x: cocoaFrame.origin.x, y: y, width: cocoaFrame.size.width, height: cocoaFrame.size.height)
}

// 1. Check Permissions
let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
guard AXIsProcessTrustedWithOptions(options) else {
    print("Grant Accessibility permissions in System Settings → Privacy & Security → Accessibility.")
    exit(1)
}

// 2. Get Frontmost App and Window
guard let frontApp = NSWorkspace.shared.frontmostApplication else {
    print("No frontmost application found")
    exit(0)
}

let appElement = AXUIElementCreateApplication(frontApp.processIdentifier)
var value: AnyObject?

let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &value)
guard result == .success else {
    print("No focused window found")
    exit(0)
}

let window = value as! AXUIElement

// 3. Get Window Current Position/Size
var posValue: AnyObject?
var sizeValue: AnyObject?
AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &posValue)
AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeValue)

var currentPos = CGPoint.zero
var currentSize = CGSize.zero

if let posValue = posValue, AXValueGetType(posValue as! AXValue) == .cgPoint {
    AXValueGetValue(posValue as! AXValue, .cgPoint, &currentPos)
}
if let sizeValue = sizeValue, AXValueGetType(sizeValue as! AXValue) == .cgSize {
    AXValueGetValue(sizeValue as! AXValue, .cgSize, &currentSize)
}

let currentAXFrame = CGRect(origin: currentPos, size: currentSize)
let currentCocoaFrame = axToCocoa(currentAXFrame)

// 4. Determine which screen the window is on
// We'll pick the screen with the largest intersection area
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

// Fallback to main if no intersection (e.g. window off screen)
let screen = targetScreen ?? NSScreen.main!

// 5. Calculate New Frame
let v = screen.visibleFrame

// Logic: Bottom Half
let totalGapY = margin * 3
let newWidth = v.width - 2 * margin
let newHeight = (v.height - totalGapY) / 2

// Align to bottom of visible frame
let newX = v.origin.x + margin
let newY = v.origin.y + margin

let newCocoaRect = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
let newAXRect = cocoaToAX(newCocoaRect)

// 6. Apply Changes
var newPos = newAXRect.origin
var newSizeVal = newAXRect.size

if let newPosValue = AXValueCreate(.cgPoint, &newPos),
   let newSizeValue = AXValueCreate(.cgSize, &newSizeVal) {
    AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, newPosValue)
    AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, newSizeValue)
}
