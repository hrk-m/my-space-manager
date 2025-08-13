import Cocoa
import ApplicationServices

/// Desktop App Manager - 外部モニターのスペース4に配置
class DesktopAppManagerSpace4: DesktopAppManagerBase {
    
    // MARK: - Public Methods
    
    /// 外部モニターのスペース4でアプリを配置
    func arrangeAppsOnExternalMonitorSpace4() {
        let collection = CollectionConfig(
            targetApps: ["Google Chrome"],
            collectAllWindows: true  // Collect all Chrome windows from all spaces
        )
        
        let placement = PlacementConfig(
            targetSpace: 4,
            appPlacements: [
                "Google Chrome": .full  // 全画面（中央80%x80%）
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