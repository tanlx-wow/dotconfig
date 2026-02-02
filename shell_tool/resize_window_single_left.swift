#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Resize Front Window Left
// @raycast.mode silent

// Optional parameters:
// @raycast.icon ⬅️

// Documentation:
// @raycast.description Resize the frontmost window to the left half of the current screen
// @raycast.author TLX & Opencode

import Cocoa
import ApplicationServices

let margin: CGFloat = 16

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

var v = screen.visibleFrame

if let primary = NSScreen.screens.first {
    let primaryTopInset = primary.frame.maxY - primary.visibleFrame.maxY
    let currentTopInset = screen.frame.maxY - v.maxY
    if currentTopInset < (primaryTopInset - 5) {
        let missingHeight = primaryTopInset - currentTopInset
        v.size.height -= missingHeight
    }
}

let totalGapX = margin * 3
let width = (v.width - totalGapX) / 2
let height = v.height - 2 * margin
let x = v.origin.x + margin
let y = v.origin.y + margin

let newCocoaRect = CGRect(x: x, y: y, width: width, height: height)
let newAXRect = cocoaToAX(newCocoaRect)

var newPos = newAXRect.origin
var newSize = newAXRect.size
if let p = AXValueCreate(.cgPoint, &newPos), let s = AXValueCreate(.cgSize, &newSize) {
    AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, p)
    AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, s)
}
