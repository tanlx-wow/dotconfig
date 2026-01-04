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

let args = CommandLine.arguments
var direction = "reset"
if args.count > 1 {
    direction = args[1].lowercased()
}

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

let v = screen.visibleFrame
let totalGapX = margin * 3
let totalGapY = margin * 3

var targetWidth: CGFloat = 0
var targetHeight: CGFloat = 0

switch direction {
case "left", "right":
    targetWidth = (v.width - totalGapX) / 2
    targetHeight = v.height - 2 * margin
case "maximize", "max":
    targetWidth = v.width - 2 * margin
    targetHeight = v.height - 2 * margin
case "up", "top", "bottom", "down":
    targetWidth = v.width - 2 * margin
    targetHeight = (v.height - totalGapY) / 2
default: // "reset", "center", and any unknown arg
    targetWidth = v.width * 0.75
    targetHeight = v.height * 0.75
}

// 1. Set Size
var newSize = CGSize(width: targetWidth, height: targetHeight)
if let s = AXValueCreate(.cgSize, &newSize) {
    AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, s)
}

// 2. Read Actual Size (in case it was constrained)
var axSizeValue: AnyObject?
var actualSize = newSize
if AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &axSizeValue) == .success,
   let val = axSizeValue as! AXValue?,
   AXValueGetType(val) == .cgSize {
    AXValueGetValue(val, .cgSize, &actualSize)
}

// 3. Calculate Position based on Actual Size
var x: CGFloat = 0
var y: CGFloat = 0

switch direction {
case "left":
    x = v.minX + margin
    y = v.minY + margin
case "right":
    x = v.maxX - margin - actualSize.width
    y = v.minY + margin
case "maximize", "max":
    x = v.minX + margin
    y = v.minY + margin
case "up", "top":
    x = v.minX + margin
    y = v.maxY - margin - actualSize.height
case "bottom", "down":
    x = v.minX + margin
    y = v.minY + margin
default: // reset
    x = v.midX - actualSize.width / 2
    y = v.midY - actualSize.height / 2
}

// 4. Set Position
let newCocoaRect = CGRect(x: x, y: y, width: actualSize.width, height: actualSize.height)
let newAXRect = cocoaToAX(newCocoaRect)
var newPos = newAXRect.origin

if let p = AXValueCreate(.cgPoint, &newPos) {
    AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, p)
}
