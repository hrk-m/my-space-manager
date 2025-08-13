import Cocoa
import ApplicationServices

/// Desktop App Manager - 外部モニターのスペース2に配置
class DesktopAppManagerExternalSpace2: DesktopAppManagerBase {
    
    // MARK: - Public Methods
    
    /// 外部モニターのスペース2でアプリを配置
    func arrangeAppsOnExternalMonitorSpace2() {
        let collection = CollectionConfig(
            targetApps: ["TablePlus", "Postman"],
            collectAllWindows: false
        )
        
        let placement = PlacementConfig(
            targetSpace: 2,
            appPlacements: [
                "TablePlus": .left,   // 左半分に配置
                "Postman": .right     // 右半分に配置
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

