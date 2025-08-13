import Cocoa
import ApplicationServices

/// Desktop App Manager - メインディスプレイのスペース1に配置
class DesktopAppManagerSpace1: DesktopAppManagerBase {
    
    // MARK: - Public Methods
    
    /// メインディスプレイのスペース1でアプリを配置
    func arrangeAppsOnMainDisplaySpace1() {
        let collection = CollectionConfig(
            targetApps: ["Slack"],
            collectAllWindows: false
        )
        
        let placement = PlacementConfig(
            targetSpace: 1,
            appPlacements: [
                "Slack": .full  // Full screen on main display
            ],
            displayType: .main,
            displayName: "Main Display"
        )
        
        // Collect apps first
        let runningApps = collectApps(config: collection)
        
        // Then place them
        if !runningApps.isEmpty {
            placeApps(config: placement)
        }
    }
}
