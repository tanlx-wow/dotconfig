#!/usr/bin/swift

// Required parameters:
// @alfred.schemaVersion 1
// @alfred.title Hide Others (Visible Preserved)
// @alfred.mode silent

// Optional parameters:
// @alfred.icon 🙈

// Documentation:
// @alfred.description Hides apps that are not currently visible (fully occluded). Preserves split-screen/tiled layouts.
// @alfred.author Opencode

import Cocoa
import CoreGraphics

// 1. Always keep the frontmost app (the one with focus)
guard let frontApp = NSWorkspace.shared.frontmostApplication else {
    print("No frontmost application found")
    exit(0)
}
var keepPIDs = Set<pid_t>([frontApp.processIdentifier])

// 2. Setup sampling grid to detect visible windows
guard let primaryScreen = NSScreen.screens.first else {
    exit(1)
}
let primaryHeight = primaryScreen.frame.height

struct Point: Hashable {
    let x: Int
    let y: Int
}

var samplePoints = Set<Point>()
let step: CGFloat = 50 // Check every 50 pixels

for screen in NSScreen.screens {
    let frame = screen.frame
    // Convert Cocoa frame (bottom-left origin) to Quartz frame (top-left origin)
    let qY = primaryHeight - frame.origin.y - frame.height
    let qRect = CGRect(x: frame.origin.x, y: qY, width: frame.width, height: frame.height)
    
    var y = qRect.minY + step/2
    while y < qRect.maxY {
        var x = qRect.minX + step/2
        while x < qRect.maxX {
            samplePoints.insert(Point(x: Int(x), y: Int(y)))
            x += step
        }
        y += step
    }
}

// 3. Get list of on-screen windows
let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
guard let infoList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
    print("Unable to get window list")
    exit(1)
}

// 4. Iterate windows from front to back
for entry in infoList {
    // Only consider standard windows (Layer 0)
    guard let layer = entry[kCGWindowLayer as String] as? Int, layer == 0 else { continue }
    
    // Get PID
    guard let pid = entry[kCGWindowOwnerPID as String] as? pid_t else { continue }
    
    // Get Bounds
    guard let boundsDict = entry[kCGWindowBounds as String] as? [String: Any],
          let bounds = CGRect(dictionaryRepresentation: boundsDict as CFDictionary) else { continue }
    
    // Check which sample points this window covers
    var hits = false
    
    // Remove points covered by this window
    samplePoints = samplePoints.filter { p in
        let cgP = CGPoint(x: Double(p.x), y: Double(p.y))
        if bounds.contains(cgP) {
            hits = true
            return false // Remove from set because it's now covered
        }
        return true // Keep in set
    }
    
    // If this window covered any points that weren't covered by previous windows, keep the app
    if hits {
        keepPIDs.insert(pid)
    }
    
    // Optimization: If no points left, we can stop
    if samplePoints.isEmpty {
        break
    }
}

// 5. Hide apps that are not in the keep list
for app in NSWorkspace.shared.runningApplications {
    // Only target regular applications
    guard app.activationPolicy == .regular else { continue }
    
    if !keepPIDs.contains(app.processIdentifier) {
        app.hide()
    }
}
