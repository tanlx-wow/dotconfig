#!/usr/bin/swift

// Required parameters:
// @alfred.schemaVersion 1
// @alfred.title Window Tools
// @alfred.mode silent

// Optional parameters:
// @alfred.icon ⬅️

// Documentation:
// @alfred.description Resize the front window, arrange all windows, or hide other apps
// @alfred.author TLX & Opencode

import Cocoa
import ApplicationServices

let args = CommandLine.arguments
let command = args.count > 1 ? args[1].lowercased() : "reset"
let usage = """
Usage: swift tilt_window_arg.swift [command]

Front window (animated):
  left, right          Tile to the left or right half
  up, top             Tile to the top half
  bottom, down        Tile to the bottom half
  max, maximize       Maximize with margins
  plus                Grow by 20%, capped to the screen
  reset, center       Resize and center (default: reset)
                      WezTerm reset uses its native window size

All visible apps (on each window's current screen):
  all-half            Tile eligible windows to the left half
  all-max             Maximize eligible windows
  hide-others         Hide other apps using visibility/stacking detection

  -h, --help          Show this help
"""
if ["-h", "--help", "help"].contains(command), args.count == 2 {
    print(usage)
    exit(0)
}
let validCommands: Set<String> = [
    "left", "right", "up", "top", "bottom", "down", "max", "maximize",
    "plus", "reset", "center", "all-half", "all-max", "hide-others",
]
guard args.count <= 2, validCommands.contains(command) else {
    print("Invalid arguments.\n\n\(usage)")
    exit(1)
}
let direction = command

let margin: CGFloat = 16
let animationDuration: TimeInterval = 0.32

func animateWindow(_ window: AXUIElement, from start: CGRect, to target: CGRect, resize: Bool) {
    guard !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion, animationDuration > 0 else { return }

    let startTime = ProcessInfo.processInfo.systemUptime
    let frameInterval: TimeInterval = 1.0 / 120.0
    while true {
        let frameTime = ProcessInfo.processInfo.systemUptime
        let progress = min((frameTime - startTime) / animationDuration, 1)
        // Smootherstep has zero velocity and acceleration at both endpoints.
        let eased = CGFloat(progress * progress * progress * (progress * (progress * 6 - 15) + 10))
        var position = CGPoint(
            x: start.minX + (target.minX - start.minX) * eased,
            y: start.minY + (target.minY - start.minY) * eased
        )
        var size = CGSize(
            width: start.width + (target.width - start.width) * eased,
            height: start.height + (target.height - start.height) * eased
        )
        if let value = AXValueCreate(.cgPoint, &position) {
            AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, value)
        }
        if resize, let value = AXValueCreate(.cgSize, &size) {
            AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, value)
        }
        if progress >= 1 { break }
        // Include Accessibility call time in the frame budget rather than adding it.
        let remaining = frameInterval - (ProcessInfo.processInfo.systemUptime - frameTime)
        if remaining > 0 {
            Thread.sleep(forTimeInterval: remaining)
        }
    }
}

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

func visibleFrame(for frame: CGRect) -> CGRect {
    var targetScreen = NSScreen.main ?? primaryScreen
    var maxIntersectionArea: CGFloat = 0
    for screen in NSScreen.screens {
        let intersection = frame.intersection(screen.frame)
        let area = intersection.isNull ? 0 : intersection.width * intersection.height
        if area > maxIntersectionArea {
            maxIntersectionArea = area
            targetScreen = screen
        }
    }
    var visible = targetScreen.visibleFrame
    let primaryTopInset = primaryScreen.frame.maxY - primaryScreen.visibleFrame.maxY
    let currentTopInset = targetScreen.frame.maxY - visible.maxY
    if currentTopInset < primaryTopInset - 5 {
        visible.size.height -= primaryTopInset - currentTopInset
    }
    return visible
}

func windowFrame(_ window: AXUIElement) -> CGRect? {
    var posValue: AnyObject?
    var sizeValue: AnyObject?
    guard AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &posValue) == .success,
          AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeValue) == .success,
          let posValue = posValue, CFGetTypeID(posValue) == AXValueGetTypeID(),
          let sizeValue = sizeValue, CFGetTypeID(sizeValue) == AXValueGetTypeID() else { return nil }
    var position = CGPoint.zero
    var size = CGSize.zero
    guard AXValueGetValue(posValue as! AXValue, .cgPoint, &position),
          AXValueGetValue(sizeValue as! AXValue, .cgSize, &size) else { return nil }
    return CGRect(origin: position, size: size)
}

func setWindowFrame(_ window: AXUIElement, to frame: CGRect) {
    var position = frame.origin
    var size = frame.size
    if let value = AXValueCreate(.cgPoint, &position) {
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, value)
    }
    if let value = AXValueCreate(.cgSize, &size) {
        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, value)
    }
}

func resizeAllWindows(half: Bool) {
    var skippedBundles: Set<String> = [
        "com.apple.finder", "com.apple.systempreferences", "com.cisco.secureclient.gui",
        "com.microsoft.teams2", "com.teamviewer.TeamViewer",
    ]
    if half {
        skippedBundles.formUnion(["com.microsoft.Outlook", "com.ThomsonResearchSoft.EndNote"])
    }
    for app in NSWorkspace.shared.runningApplications {
        guard !app.isHidden, app.activationPolicy == .regular,
              let bundleID = app.bundleIdentifier, !skippedBundles.contains(bundleID) else { continue }
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        var value: AnyObject?
        guard AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &value) == .success,
              let windows = value as? [AXUIElement] else { continue }
        for window in windows {
            if half {
                var minimized: AnyObject?
                if AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &minimized) == .success,
                   minimized as? Bool == true { continue }
            }
            guard let frame = windowFrame(window) else { continue }
            let visible = visibleFrame(for: axToCocoa(frame))
            let width = half ? (visible.width - 3 * margin) / 2 : visible.width - 2 * margin
            let target = CGRect(x: visible.minX + margin, y: visible.minY + margin,
                                width: width, height: visible.height - 2 * margin)
            setWindowFrame(window, to: cocoaToAX(target))
        }
    }
}

func hideOtherApps() {
    guard let frontApp = NSWorkspace.shared.frontmostApplication else {
        print("No frontmost application found")
        return
    }
    var keepPIDs = Set<pid_t>([frontApp.processIdentifier])
    struct Point: Hashable {
        let x: Int
        let y: Int
    }
    var samplePoints = Set<Point>()
    let step: CGFloat = 50
    for screen in NSScreen.screens {
        let frame = cocoaToAX(screen.frame)
        var y = frame.minY + step / 2
        while y < frame.maxY {
            var x = frame.minX + step / 2
            while x < frame.maxX {
                samplePoints.insert(Point(x: Int(x), y: Int(y)))
                x += step
            }
            y += step
        }
    }
    let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
    guard let windows = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
        print("Unable to get window list")
        exit(1)
    }
    var frontWindowBounds: CGRect?
    for entry in windows {
        guard let layer = entry[kCGWindowLayer as String] as? Int, layer == 0,
              let pid = entry[kCGWindowOwnerPID as String] as? pid_t,
              let boundsDict = entry[kCGWindowBounds as String] as? [String: Any],
              let bounds = CGRect(dictionaryRepresentation: boundsDict as CFDictionary) else { continue }
        var isStacked = false
        if let frontBounds = frontWindowBounds {
            let intersection = bounds.intersection(frontBounds)
            if !intersection.isNull {
                isStacked = intersection.width * intersection.height > 0.5 * frontBounds.width * frontBounds.height
            }
        } else {
            frontWindowBounds = bounds
        }
        var hits = false
        samplePoints = samplePoints.filter { point in
            if bounds.contains(CGPoint(x: Double(point.x), y: Double(point.y))) {
                hits = true
                return false
            }
            return true
        }
        if hits && !isStacked { keepPIDs.insert(pid) }
        if samplePoints.isEmpty { break }
    }
    for app in NSWorkspace.shared.runningApplications {
        guard app.activationPolicy == .regular else { continue }
        if !keepPIDs.contains(app.processIdentifier) { app.hide() }
    }
}

// Hiding apps does not require Accessibility permission.
if command == "hide-others" {
    hideOtherApps()
    exit(0)
}

let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
guard AXIsProcessTrustedWithOptions(options) else {
    print("Grant Accessibility permissions in System Settings → Privacy & Security → Accessibility.")
    exit(1)
}

if command == "all-half" || command == "all-max" {
    resizeAllWindows(half: command == "all-half")
    exit(0)
}

guard let frontApp = NSWorkspace.shared.frontmostApplication else {
    print("No frontmost application found")
    exit(0)
}

let isWeztermReset = direction == "reset" && frontApp.bundleIdentifier == "com.github.wez.wezterm"
if isWeztermReset {
    frontApp.activate()
    Thread.sleep(forTimeInterval: 0.1)

    let flags: CGEventFlags = [.maskControl, .maskAlternate]
    for keyDown in [true, false] {
        if let event = CGEvent(keyboardEventSource: nil, virtualKey: 15, keyDown: keyDown) {
            event.flags = flags
            event.post(tap: .cghidEventTap)
        }
    }
    Thread.sleep(forTimeInterval: 0.2)
}

let appElement = AXUIElementCreateApplication(frontApp.processIdentifier)
var value: AnyObject?
let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &value)
guard result == .success else {
    print("No focused window found")
    exit(0)
}

let window = value as! AXUIElement
guard let currentFrame = windowFrame(window) else {
    print("Unable to get focused window frame")
    exit(1)
}
let currentPos = currentFrame.origin
let currentSize = currentFrame.size
let v = visibleFrame(for: axToCocoa(currentFrame))

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
case "plus":
    let scale: CGFloat = 1.2
    let maxWidth = v.width - 2 * margin
    let maxHeight = v.height - 2 * margin
    targetWidth = min(currentSize.width * scale, maxWidth)
    targetHeight = min(currentSize.height * scale, maxHeight)
case "up", "top", "bottom", "down":
    targetWidth = v.width - 2 * margin
    targetHeight = (v.height - totalGapY) / 2
case "reset" where isWeztermReset:
    targetWidth = currentSize.width
    targetHeight = currentSize.height
default: // "reset" and "center"
    targetWidth = v.width * 0.4
    targetHeight = v.height * 0.5
}

// 1. Calculate Target Position based on Target Size
var x: CGFloat = 0
var y: CGFloat = 0

switch direction {
case "left":
    x = v.minX + margin
    y = v.minY + margin
case "right":
    x = v.maxX - margin - targetWidth
    y = v.minY + margin
case "maximize", "max":
    x = v.minX + margin
    y = v.minY + margin
case "up", "top":
    x = v.minX + margin
    y = v.maxY - margin - targetHeight
case "bottom", "down":
    x = v.minX + margin
    y = v.minY + margin
default: // reset
    x = v.midX - targetWidth / 2
    y = v.midY - targetHeight / 2
}

// 2. Set Position (First pass)
// We set position first to ensure the window has room to grow into the target size
let newCocoaRect = CGRect(x: x, y: y, width: targetWidth, height: targetHeight)
let newAXRect = cocoaToAX(newCocoaRect)
animateWindow(window, from: CGRect(origin: currentPos, size: currentSize), to: newAXRect, resize: !isWeztermReset)
// Apply the exact final frame after animation (or immediately with Reduce Motion).
var newPos = newAXRect.origin

if let p = AXValueCreate(.cgPoint, &newPos) {
    AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, p)
}

// 3. Set Size
var newSize = CGSize(width: targetWidth, height: targetHeight)
if !isWeztermReset, let s = AXValueCreate(.cgSize, &newSize) {
    AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, s)
}

// 4. (Optional) For "reset", re-center if actual size differs from target
if direction == "reset" || direction == "center" {
    var axSizeValue: AnyObject?
    var actualSize = newSize
    if AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &axSizeValue) == .success,
       let val = axSizeValue as! AXValue?,
       AXValueGetType(val) == .cgSize {
        AXValueGetValue(val, .cgSize, &actualSize)
    }
    
    // Recalculate center with actual size
    let centerX = v.midX - actualSize.width / 2
    let centerY = v.midY - actualSize.height / 2
    
    let finalCocoaRect = CGRect(x: centerX, y: centerY, width: actualSize.width, height: actualSize.height)
    let finalAXRect = cocoaToAX(finalCocoaRect)
    var finalPos = finalAXRect.origin
    
    if let p = AXValueCreate(.cgPoint, &finalPos) {
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, p)
    }
}
