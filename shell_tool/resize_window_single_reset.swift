#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Reset Window Size
// @raycast.mode silent

// Optional parameters:
// @raycast.icon ↩️

// Documentation:
// @raycast.description Resize the frontmost window to a reasonable central size (75% of screen)
// @raycast.author Opencode

import Cocoa
import ApplicationServices

guard let primaryScreen = NSScreen.screens.first else {
    print("No screens available")
    exit(1)
}
let primaryHeight = primaryScreen.frame.height

func axToCocoa(_ axFrame: CGRect) -> CGRect {
    let y = primaryHeight - axFrame.origin.y - axFrame.size.height
    return CGRect(x: axFrame.origin.x, y: y, width: axFrame.size.width, height: axFrame.size.height)
}

func cocoaToAX(_ cocoaFrame: CGRect) -> CGRect {
    let y = primaryHeight - cocoaFrame.origin.y - cocoaFrame.size.height
    return CGRect(x: cocoaFrame.origin.x, y: y, width: cocoaFrame.size.width, height: cocoaFrame.size.height)
}

let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
guard AXIsProcessTrustedWithOptions(options) else {
    print("Grant Accessibility permissions in System Settings → Privacy & Security → Accessibility.")
    exit(1)
}

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

let currentCocoaFrame = axToCocoa(CGRect(origin: currentPos, size: currentSize))

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

let v = screen.visibleFrame

// Calculate "Reasonable" Size (e.g., 75% of screen width/height, centered)
let width = v.width * 0.75
let height = v.height * 0.75
let x = v.origin.x + (v.width - width) / 2
let y = v.origin.y + (v.height - height) / 2

let newCocoaRect = CGRect(x: x, y: y, width: width, height: height)
let newAXRect = cocoaToAX(newCocoaRect)

var newPos = newAXRect.origin
var newSize = newAXRect.size
if let p = AXValueCreate(.cgPoint, &newPos), let s = AXValueCreate(.cgSize, &newSize) {
    AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, p)
    AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, s)
}
