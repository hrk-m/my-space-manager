import Cocoa
import ApplicationServices

/// Desktop App Manager - 外部モニターのスペース3に配置
class DesktopAppManagerSpace3: DesktopAppManagerBase {
    
    // MARK: - Public Methods
    
    /// 外部モニターのスペース3でアプリを配置
    func arrangeAppsOnExternalMonitorSpace3() {
        let collection = CollectionConfig(
            targetApps: ["iTerm", "Cursor", "Kiro"],
            collectAllWindows: true  // Collect all windows from all spaces
        )
        
        let placement = PlacementConfig(
            targetSpace: 3,
            appPlacements: [
                "iTerm": .full,
                "Cursor": .right,
                "Kiro": .right
            ],
            displayType: .external,
            displayName: "External Monitor"
        )
        
        // Collect apps first
        let runningApps = collectApps(config: collection)
        
        // Then place them
        if !runningApps.isEmpty {
            placeApps(config: placement)
        }
    }
}