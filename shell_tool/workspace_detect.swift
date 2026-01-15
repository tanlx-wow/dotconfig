import Foundation

// 1. Force Dock to update the configuration file (Crucial step)
// This makes the screen blink once, but ensures the count is real.
let task = Process()
task.launchPath = "/usr/bin/killall"
task.arguments = ["Dock"]
task.launch()
task.waitUntilExit()

// Wait briefly for the file to be written
Thread.sleep(forTimeInterval: 0.5)

// 2. Read the file
let spacesPath = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent("Library/Preferences/com.apple.spaces.plist")

struct SpacesConfig: Decodable {
    let SpacesDisplayConfiguration: DisplayConfig
}

struct DisplayConfig: Decodable {
    let ManagementData: ManagementData
    
    enum CodingKeys: String, CodingKey {
        case ManagementData = "Management Data"
    }
}

struct ManagementData: Decodable {
    let Monitors: [Monitor]
}

struct Monitor: Decodable {
    // We make this optional to skip Sidecar/ghost monitors safely
    let Spaces: [SpaceInfo]?
}

struct SpaceInfo: Decodable {
    let uuid: String
}

func main() {
    do {
        let data = try Data(contentsOf: spacesPath)
        let decoder = PropertyListDecoder()
        let config = try decoder.decode(SpacesConfig.self, from: data)
        
        for (index, monitor) in config.SpacesDisplayConfiguration.ManagementData.Monitors.enumerated() {
            if let spaces = monitor.Spaces {
                print("Monitor \(index + 1): \(spaces.count) Workspaces")
            }
        }
    } catch {
        // If it fails, it usually means the plist format changed in a macOS update
        print("Could not read spaces. (Note: This script requires macOS Sonoma or newer)")
    }
}

main()
