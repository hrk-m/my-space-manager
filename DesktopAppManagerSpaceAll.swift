import Cocoa
import ApplicationServices

/// Desktop App Manager - 全スペースからSpace 1にアプリを移動
class DesktopAppManagerSpaceAll: DesktopAppManagerBase {
    
    // MARK: - Public Methods
    
    /// 全スペースからSpace 1にアプリを移動
    func arrangeAllApps() {
        print("🚀 Collecting all apps from all spaces to Space 1")
        print("=" * 50)
        
        // アクセシビリティ権限チェック
        guard checkAccessibilityPermission() else {
            print("❌ Accessibility permission required")
            print("Please grant permission in:")
            print("System Preferences > Security & Privacy > Privacy > Accessibility")
            requestAccessibilityPermission()
            return
        }
        
        // 外部モニターの検出
        print("\n🖥️ Detecting monitors...")
        let monitors = monitorManager.detectMonitors()
        let hasExternalMonitor = monitors.count > 1
        
        if hasExternalMonitor {
            print("✅ External monitor detected")
            // モニター側のSpace 2-4を巡回してアプリを収集
            collectAppsFromExternalMonitorSpaces()
        } else {
            print("ℹ️ No external monitor detected, collecting from main display spaces only")
            // メインディスプレイのSpace 1-4を巡回
            collectAppsFromMainDisplaySpaces()
        }
        
        // 最終的にSpace 1に切り替え
        print("\n📍 Final step: Returning to Space 1")
        switchToSpace(1)
        Thread.sleep(forTimeInterval: 1.0)
        
        print("\n✅ All apps have been collected to Space 1!")
        print("💡 Tip: Press Control+1 to verify all apps are on Space 1")

        moveAppsToSpace()
    }

    // MARK: - Private Methods

    /// Space 1からSpace 4にアプリを移動
    private func moveAppsToSpace() {
        let placement1 = PlacementConfig(
            targetSpace: 1,
            appPlacements: [
                "Slack": .full  // Full screen on main display
            ],
            displayType: .main,
            displayName: "Main Display"
        )
        
        // Then place them
        placeApps(config: placement1)

        let placement2 = PlacementConfig(
            targetSpace: 2,
            appPlacements: [
                "TablePlus": .left,   // 左半分に配置
                "Postman": .right     // 右半分に配置
            ],
            displayType: .external,
            displayName: "External Monitor"
        )
        
        // Then place them
        placeApps(config: placement2)

        let placement3 = PlacementConfig(
            targetSpace: 3,
            appPlacements: [
                "iTerm": .left,
                "Cursor": .right,
                "Kiro": .right
            ],
            displayType: .external,
            displayName: "External Monitor"
        )
        
        // Then place them
        placeApps(config: placement3)

        let placement4 = PlacementConfig(
            targetSpace: 4,
            appPlacements: [
                "Google Chrome": .full  // 全画面（中央80%x80%）
            ],
            displayType: .external,
            displayName: "External Monitor"
        )
        
        // Then place them
        placeApps(config: placement4)
    }
    
    /// 外部モニターのSpace 2-4からアプリを収集
    private func collectAppsFromExternalMonitorSpaces() {
        print("\n📱 Collecting apps from external monitor spaces...")
        
        // 外部モニターを取得
        let monitors = monitorManager.detectMonitors()
        guard let externalMonitor = monitors.first(where: { !$0.isMain }) else {
            print("⚠️ Could not identify external monitor")
            return
        }
        
        // Space 2-4を巡回（外部モニター側）
        for spaceNumber in 2...4 {
            print("\n[Space \(spaceNumber)] Checking external monitor...")
            
            // 外部モニターのスペースに移動
            moveMouseToExternalMonitor(externalMonitor)
            Thread.sleep(forTimeInterval: 0.3)
            switchToSpace(spaceNumber)
            Thread.sleep(forTimeInterval: 1.0)
            
            // アクティブなアプリを取得して Space 1 に移動
            moveActiveAppsToSpace1FromCurrentSpace(spaceNumber: spaceNumber, isExternal: true)
        }
        
        // メインディスプレイのSpace 2-4もチェック
        print("\n📱 Checking main display spaces...")
        for spaceNumber in 2...4 {
            print("\n[Space \(spaceNumber)] Checking main display...")
            switchToSpace(spaceNumber)
            Thread.sleep(forTimeInterval: 1.0)
            
            // アクティブなアプリを取得して Space 1 に移動
            moveActiveAppsToSpace1FromCurrentSpace(spaceNumber: spaceNumber, isExternal: false)
        }
    }
    
    /// メインディスプレイのSpace 1-4からアプリを収集
    private func collectAppsFromMainDisplaySpaces() {
        print("\n📱 Collecting apps from main display spaces...")
        
        // Space 2-4を巡回（Space 1は既に収集先なのでスキップ）
        for spaceNumber in 2...4 {
            print("\n[Space \(spaceNumber)] Checking...")
            switchToSpace(spaceNumber)
            Thread.sleep(forTimeInterval: 1.0)
            
            // アクティブなアプリを取得して Space 1 に移動
            moveActiveAppsToSpace1FromCurrentSpace(spaceNumber: spaceNumber, isExternal: false)
        }
    }
    
    /// 現在のスペースからアクティブなアプリをSpace 1に移動
    private func moveActiveAppsToSpace1FromCurrentSpace(spaceNumber: Int, isExternal: Bool) {
        let activeApps = getAllActiveAppNames()
        
        if activeApps.isEmpty {
            print("  → No active apps found in Space \(spaceNumber)\(isExternal ? " (external)" : "")")
            return
        }
        
        print("  → Found \(activeApps.count) active app(s) in Space \(spaceNumber)\(isExternal ? " (external)" : "")")
        for appName in activeApps {
            print("    • \(appName)")
        }
        
        // Space 1に移動
        print("  → Moving apps to Space 1...")
        switchToSpace(1)
        Thread.sleep(forTimeInterval: 0.8)
        
        // 各アプリをアクティブ化して Space 1 に固定
        for appName in activeApps {
            if let app = NSWorkspace.shared.runningApplications.first(where: { $0.localizedName == appName }) {
                activateApp(app)
                Thread.sleep(forTimeInterval: 0.3)
                
                // ウィンドウを少しずつオフセットして配置
                let windows = getAllAppWindows(app)
                for (index, window) in windows.enumerated() {
                    let offset = CGFloat(index * 30)
                    positionWindowAt(window, 
                                   x: 100 + offset, 
                                   y: 100 + offset, 
                                   width: 1200, 
                                   height: 800)
                }
                
                print("    ✓ Moved \(appName) to Space 1")
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// 全ての実行中アプリの名前を取得
    private func getAllActiveAppNames() -> [String] {
        let workspace = NSWorkspace.shared
        let allApps = workspace.runningApplications
        
        // システムアプリやバックグラウンドアプリを除外してアプリ名を取得
        let userAppNames = allApps.compactMap { app -> String? in
            guard let bundleId = app.bundleIdentifier,
                  let appName = app.localizedName else { return nil }
            
            // システムアプリを除外
            let systemApps = [
                "com.apple.finder",
                "com.apple.dock",
                "com.apple.systemuiserver",
                "com.apple.controlcenter",
                "com.apple.notificationcenterui",
                "com.apple.WindowManager",
                "com.apple.loginwindow",
                "com.apple.spotlight",
                "com.apple.Safari.SocialHelper",
                "com.apple.Safari.History",
                "com.apple.Safari.GeolocationService"
            ]
            
            if systemApps.contains(bundleId) {
                return nil
            }
            
            // ウィンドウを持つアプリのみを対象
            if app.activationPolicy == .regular && hasVisibleWindows(app) {
                return appName
            }
            
            return nil
        }
        
        return userAppNames
    }
    
    /// アプリが可視ウィンドウを持っているかチェック
    private func hasVisibleWindows(_ app: NSRunningApplication) -> Bool {
        let pid = app.processIdentifier
        let appElement = AXUIElementCreateApplication(pid)
        
        var windowsValue: CFTypeRef?
        if AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue) == .success,
           let windows = windowsValue as? [AXUIElement],
           !windows.isEmpty {
            
            // 最小化されていないウィンドウがあるかチェック
            for window in windows {
                var minimized: CFTypeRef?
                if AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &minimized) == .success,
                   let isMinimized = minimized as? Bool,
                   !isMinimized {
                    return true
                }
            }
        }
        
        return false
    }
}
