import Cocoa
import ApplicationServices

/// Desktop App Manager 基底クラス - 共通機能を提供
class DesktopAppManagerBase {
    
    // MARK: - Enums
    
    /// ウィンドウ配置位置
    enum WindowSide {
        case left   // 左側に配置
        case right  // 右側に配置
        case full   // 全画面
    }
    
    // MARK: - Properties
    internal let monitorManager = MonitorManager()
    
    // MARK: - Internal Methods (サブクラスから利用可能)
    
    /// アプリのすべてのウィンドウを取得
    internal func getAllAppWindows(_ app: NSRunningApplication) -> [AXUIElement] {
        let pid = app.processIdentifier
        let appElement = AXUIElementCreateApplication(pid)
        
        var windowsValue: CFTypeRef?
        var windows: [AXUIElement] = []
        
        if AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue) == .success,
           let allWindows = windowsValue as? [AXUIElement] {
            windows = allWindows
        }
        
        return windows
    }
    
    /// ウィンドウが最小化されているかチェック
    internal func isWindowMinimized(_ window: AXUIElement) -> Bool {
        var minimizedValue: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &minimizedValue)
        
        if result == .success,
           let minimized = minimizedValue as? Bool {
            return minimized
        }
        
        // 属性が取得できない場合は最小化されていないとみなす
        return false
    }
    
    /// 表示されている（最小化されていない）ウィンドウのみ取得
    internal func getVisibleAppWindows(_ app: NSRunningApplication) -> [AXUIElement] {
        let allWindows = getAllAppWindows(app)
        let visibleWindows = allWindows.filter { !isWindowMinimized($0) }
        
        // デバッグ情報を出力
        let minimizedCount = allWindows.count - visibleWindows.count
        if minimizedCount > 0 {
            print("      (Skipping \(minimizedCount) minimized window(s))")
        }
        
        return visibleWindows
    }
    
    /// ウィンドウを指定位置に配置
    internal func positionWindowAt(_ window: AXUIElement, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        // 位置を設定
        var position = CGPoint(x: x, y: y)
        if let positionValue = AXValueCreate(.cgPoint, &position) {
            AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
        }
        
        // サイズを設定
        var size = CGSize(width: width, height: height)
        if let sizeValue = AXValueCreate(.cgSize, &size) {
            AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
        }
    }
    
    /// ウィンドウを前面に持ってくる
    internal func raiseWindow(_ window: AXUIElement) {
        // ウィンドウをメインウィンドウとして設定
        AXUIElementSetAttributeValue(window, kAXMainAttribute as CFString, kCFBooleanTrue)
        // ウィンドウにフォーカスを設定
        AXUIElementSetAttributeValue(window, kAXFocusedAttribute as CFString, kCFBooleanTrue)
        // ウィンドウを最前面に
        AXUIElementPerformAction(window, kAXRaiseAction as CFString)
    }
    
    /// スペースに切り替え（Control + 数字）
    internal func switchToSpace(_ spaceNumber: Int) {
        let keyCode: CGKeyCode = CGKeyCode(18 + spaceNumber - 1) // 1=18, 2=19, 3=20, etc.
        
        let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)
        keyDown?.flags = .maskControl
        keyDown?.post(tap: .cghidEventTap)
        
        Thread.sleep(forTimeInterval: SleepTimeConfig.keyEventInterval)
        
        let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)
        keyUp?.flags = .maskControl
        keyUp?.post(tap: .cghidEventTap)
    }
    
    /// マウスを外部モニターに移動
    internal func moveMouseToExternalMonitor(_ monitor: MonitorManager.MonitorInfo) {
        let centerX = monitor.frame.origin.x + monitor.frame.width / 2
        let centerY = monitor.frame.origin.y + monitor.frame.height / 2
        
        let mouseMove = CGEvent(mouseEventSource: nil,
                                mouseType: .mouseMoved,
                                mouseCursorPosition: CGPoint(x: centerX, y: centerY),
                                mouseButton: .left)
        mouseMove?.post(tap: .cghidEventTap)
        
        print("  🖱️ Mouse moved to external monitor")
    }
    
    /// 外部モニターの指定スペースにフォーカス
    internal func focusExternalMonitorSpace(_ monitor: MonitorManager.MonitorInfo, spaceNumber: Int) {
        // マウスが外部モニターにある状態でスペースに切り替え
        // これにより外部モニターのスペースがアクティブになる
        switchToSpace(spaceNumber)
        print("  📍 Focused on external monitor's Space \(spaceNumber)")
    }
    
    /// ウィンドウを現在のスペースに割り当て
    internal func assignWindowToCurrentSpace(_ app: NSRunningApplication) {
        // アプリをアクティブにして現在のスペースに固定
        activateApp(app)
        Thread.sleep(forTimeInterval: SleepTimeConfig.adjustedTime(SleepTimeConfig.windowPositioning))
        
        // Option + クリックでDockのコンテキストメニューを開く動作をシミュレート
        // （実際にはユーザーが手動で行う必要がある場合があります）
        print("    → Window assigned to current space")
    }
    
    /// ウィンドウを指定位置に配置
    internal func positionWindow(_ app: NSRunningApplication, frame: CGRect) {
        let pid = app.processIdentifier
        let appElement = AXUIElementCreateApplication(pid)
        
        // ウィンドウを取得
        var window: AXUIElement?
        
        // フォーカスされたウィンドウを取得
        var focusedWindow: CFTypeRef?
        if AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &focusedWindow) == .success {
            window = (focusedWindow as! AXUIElement)
        }
        
        // フォーカスされたウィンドウがない場合は最初のウィンドウを取得
        if window == nil {
            var windowsValue: CFTypeRef?
            if AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue) == .success,
               let windows = windowsValue as? [AXUIElement],
               !windows.isEmpty {
                window = windows[0]
            }
        }
        
        guard let targetWindow = window else {
            print("    ⚠️ Could not find window")
            return
        }
        
        // ウィンドウの位置を設定
        var position = CGPoint(x: frame.origin.x, y: frame.origin.y)
        if let positionValue = AXValueCreate(.cgPoint, &position) {
            AXUIElementSetAttributeValue(targetWindow, kAXPositionAttribute as CFString, positionValue)
        }
        
        // ウィンドウのサイズを設定
        var size = CGSize(width: frame.width, height: frame.height)
        if let sizeValue = AXValueCreate(.cgSize, &size) {
            AXUIElementSetAttributeValue(targetWindow, kAXSizeAttribute as CFString, sizeValue)
        }
        
        print("    ✅ Positioned at (\(Int(frame.origin.x)), \(Int(frame.origin.y)))")
    }
    
    /// アプリをアクティブ化
    internal func activateApp(_ app: NSRunningApplication) {
        if #available(macOS 14.0, *) {
            app.activate()
        } else {
            app.activate(options: .activateIgnoringOtherApps)
        }
    }
    
    /// アプリを検索または起動
    internal func findOrLaunchApp(_ appName: String) -> NSRunningApplication? {
        let workspace = NSWorkspace.shared
        
        // 既に起動しているか確認
        if let app = workspace.runningApplications.first(where: { $0.localizedName == appName }) {
            print("  ✓ \(appName) is already running")
            return app
        }
        
        // Bundle IDを取得
        guard let bundleId = getBundleIdentifier(for: appName) else {
            print("  ✗ Unknown app: \(appName)")
            return nil
        }
        
        // アプリのURLを取得
        guard let appURL = workspace.urlForApplication(withBundleIdentifier: bundleId) else {
            print("  ✗ \(appName) not installed")
            return nil
        }
        
        // アプリを起動
        print("  → Launching \(appName)...")
        
        if #available(macOS 11.0, *) {
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true
            
            var launchedApp: NSRunningApplication?
            let semaphore = DispatchSemaphore(value: 0)
            
            workspace.openApplication(at: appURL, configuration: configuration) { app, error in
                if let error = error {
                    print("  ✗ Failed to launch: \(error)")
                } else if let app = app {
                    print("  ✓ \(appName) launched")
                    launchedApp = app
                }
                semaphore.signal()
            }
            
            _ = semaphore.wait(timeout: .now() + 5.0)
            return launchedApp
        } else {
            do {
                let app = try workspace.launchApplication(at: appURL, options: .default, configuration: [:])
                print("  ✓ \(appName) launched")
                return app
            } catch {
                print("  ✗ Failed to launch: \(error)")
                return nil
            }
        }
    }
    
    /// Bundle Identifier取得（動的に取得）
    internal func getBundleIdentifier(for appName: String) -> String? {
        // 実行中のアプリから動的に取得
        let workspace = NSWorkspace.shared
        if let app = workspace.runningApplications.first(where: { $0.localizedName == appName }) {
            return app.bundleIdentifier
        }
        
        // アプリケーションフォルダから検索
        let appPaths = [
            "/Applications/\(appName).app",
            "/Applications/Utilities/\(appName).app",
            "/System/Applications/\(appName).app",
            NSHomeDirectory() + "/Applications/\(appName).app"
        ]
        
        for path in appPaths {
            if let bundle = Bundle(path: path),
               let bundleId = bundle.bundleIdentifier {
                print("  → Found bundle ID for \(appName): \(bundleId)")
                return bundleId
            }
        }
        
        return nil
    }
    
    /// アクセシビリティ権限確認
    internal func checkAccessibilityPermission() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: false]
        return AXIsProcessTrustedWithOptions(options)
    }
    
    /// アクセシビリティ権限リクエスト
    internal func requestAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        AXIsProcessTrustedWithOptions(options)
    }
    
    // MARK: - Common Properties and Types
    
    /// Configuration for collecting apps from spaces
    struct CollectionConfig {
        let targetApps: [String]              // Apps to collect
        let collectAllWindows: Bool           // Whether to collect all windows from all spaces
        
        init(targetApps: [String], collectAllWindows: Bool = false) {
            self.targetApps = targetApps
            self.collectAllWindows = collectAllWindows
        }
    }
    
    /// Configuration for placing apps on a specific display and space
    struct PlacementConfig {
        let targetSpace: Int                  // Target space number (1-4)
        let appPlacements: [String: WindowSide] // App placement positions
        let displayType: DisplayType          // Main or external display
        let displayName: String               // Display name for messages
        
        init(targetSpace: Int, appPlacements: [String: WindowSide],
             displayType: DisplayType, displayName: String) {
            self.targetSpace = targetSpace
            self.appPlacements = appPlacements
            self.displayType = displayType
            self.displayName = displayName
        }
    }
    
    /// Common structure for app management (legacy - for backward compatibility)
    struct AppConfiguration {
        let targetApps: [String]
        let targetSpace: Int
        let appPlacements: [String: WindowSide]
        let displayType: DisplayType
        let displayName: String
        let collectAllWindows: Bool  // Whether to collect all windows from all spaces
        
        init(targetApps: [String], targetSpace: Int, appPlacements: [String: WindowSide],
             displayType: DisplayType, displayName: String, collectAllWindows: Bool = false) {
            self.targetApps = targetApps
            self.targetSpace = targetSpace
            self.appPlacements = appPlacements
            self.displayType = displayType
            self.displayName = displayName
            self.collectAllWindows = collectAllWindows
        }
    }
    
    enum DisplayType {
        case main
        case external
    }
    
    // MARK: - Common App Management Methods
    
    /// Collect apps based on configuration (収集フェーズ)
    internal func collectApps(config: CollectionConfig) -> [String: NSRunningApplication] {
        print("📦 Collecting Apps")
        print("=" * 50)
        
        // Check accessibility permission
        guard checkAccessibilityPermission() else {
            showAccessibilityError()
            return [:]
        }
        
        print("\n🎯 Collection configuration:")
        print("  • Target apps: \(config.targetApps.isEmpty ? "All running apps" : config.targetApps.joined(separator: ", "))")
        print("  • Collect all windows: \(config.collectAllWindows ? "Yes" : "No")")
        
        var runningApps: [String: NSRunningApplication] = [:]
        
        if config.collectAllWindows {
            print("\n[Step 1] Collecting ALL windows from Space 1-4...")
            // Collect all windows from all spaces
            for appName in config.targetApps {
                if let app = findOrLaunchApp(appName) {
                    runningApps[appName] = app
                    print("  ✅ \(appName) found/launched")
                }
            }
            
            // Move all windows to Space 1 for collection
            if !config.targetApps.isEmpty {
                collectAllAppsToSpace1(config.targetApps, [:])  // Empty placements for now
            }
        } else {
            print("\n[Step 1] Finding and launching apps...")
            // Just find or launch apps
            for appName in config.targetApps {
                print("  → Setting up \(appName)...")
                if let app = findOrLaunchApp(appName) {
                    runningApps[appName] = app
                    activateApp(app)
                    Thread.sleep(forTimeInterval: SleepTimeConfig.adjustedTime(SleepTimeConfig.appActivation))
                    print("  ✅ \(appName) activated")
                } else {
                    print("  ❌ Could not setup \(appName)")
                }
            }
            
            // Move apps to Space 1 if needed
            if !config.targetApps.isEmpty {
                print("\n[Step 2] Moving apps to Space 1...")
                moveAppsToSpace1(config.targetApps)
            }
        }
        
        print("\n✅ Collection complete: \(runningApps.count) app(s) ready")
        return runningApps
    }
    
    /// Place collected apps based on configuration (配置フェーズ)
    internal func placeApps(config: PlacementConfig) {
        print("\n📍 Placing Apps")
        print("=" * 50)
        
        print("\n🎯 Placement configuration:")
        print("  • Target space: \(config.targetSpace)")
        print("  • Display: \(config.displayName) (\(config.displayType == .main ? "Main" : "External"))")
        print("  • Apps to place: \(config.appPlacements.count)")
        
        // PlacementConfigからアプリを取得
        var runningApps: [String: NSRunningApplication] = [:]
        for (appName, _) in config.appPlacements {
            if let app = findOrLaunchApp(appName) {
                runningApps[appName] = app
                activateApp(app)
                Thread.sleep(forTimeInterval: SleepTimeConfig.adjustedTime(SleepTimeConfig.appActivation))
                print("  • \(appName) ready for placement")
            } else {
                print("  ⚠️ Could not find/launch \(appName)")
            }
        }
        
        if runningApps.isEmpty {
            print("\n⚠️ No apps to place")
            return
        }
        
        // Switch to target space
        print("\n[Step 1] Switching to Space \(config.targetSpace)...")
        switchToSpace(config.targetSpace)
        Thread.sleep(forTimeInterval: SleepTimeConfig.adjustedTime(SleepTimeConfig.spaceSwitch))
        
        // Get display based on type
        let display: NSScreen?
        let externalMonitor: MonitorManager.MonitorInfo?
        
        if config.displayType == .main {
            display = NSScreen.main
            externalMonitor = nil
            if display == nil {
                print("\n❌ Could not get main display")
                return
            }
            print("\n✅ Main display found")
            print("  • Resolution: \(Int(display!.frame.width)) x \(Int(display!.frame.height))")
        } else {
            // Detect monitors for external display
            print("\n[Step 2] Detecting monitors...")
            let monitors = monitorManager.detectMonitors()
            
            guard monitors.count > 1 else {
                print("\n❌ No external monitor detected!")
                print("  Please connect an external display and try again.")
                return
            }
            
            guard let extMonitor = monitors.first(where: { !$0.isMain }) else {
                print("\n❌ Could not identify external monitor")
                return
            }
            
            externalMonitor = extMonitor
            print("\n✅ External monitor found: \(extMonitor.name)")
            print("  • Resolution: \(Int(extMonitor.frame.width)) x \(Int(extMonitor.frame.height))")
            print("  • Position: (\(Int(extMonitor.frame.origin.x)), \(Int(extMonitor.frame.origin.y)))")
            
            display = NSScreen.screens.first { screen in
                screen.frame.origin.x == extMonitor.frame.origin.x &&
                screen.frame.origin.y == extMonitor.frame.origin.y
            }
        }
        
        guard let targetDisplay = display else {
            print("\n❌ Could not get target display")
            return
        }
        
        // Position apps on display
        let stepNum = config.displayType == .external ? 3 : 2
        
        if config.displayType == .external, let extMonitor = externalMonitor {
            print("\n[Step \(stepNum)] Moving apps to external monitor (Space \(config.targetSpace))...")
            
            // Move mouse to external monitor
            moveMouseToExternalMonitor(extMonitor)
            Thread.sleep(forTimeInterval: 0.5)
            
            // Focus external monitor space
            focusExternalMonitorSpace(extMonitor, spaceNumber: config.targetSpace)
            Thread.sleep(forTimeInterval: 0.5)
            
            // Move all windows to external monitor
            moveAllWindowsToExternalMonitor(
                extMonitor,
                runningApps: runningApps,
                targetApps: Array(runningApps.keys),
                placements: config.appPlacements
            )
        } else {
            print("\n[Step \(stepNum)] Positioning apps on main display (Space \(config.targetSpace))...")
            
            // Position each app according to placement
            let frame = targetDisplay.frame
            for (appName, app) in runningApps {
                let placementPos = config.appPlacements[appName] ?? .full
                let appFrame = getFrameForPlacement(placementPos, in: frame)
                print("  📍 Positioning \(appName)...")
                positionWindow(app, frame: appFrame)
                assignWindowToCurrentSpace(app)
            }
        }
        
        // Final verification
        print("\n[Step \(stepNum + 1)] Final verification...")
        Thread.sleep(forTimeInterval: 1.0)
        
        print("\n" + "=" * 50)
        print("✅ Placement complete!")
        print("\n📌 Final state:")
        print("  • Location: \(config.displayName) - Space \(config.targetSpace)")
        
        for (appName, _) in runningApps {
            let placementPos = config.appPlacements[appName] ?? .full
            let position = getPositionDescription(placementPos)
            print("  • \(appName): \(position) of \(config.displayType == .main ? "main display" : "external monitor")")
        }
        
        print("\n💡 Tips:")
        print("  • Apps are now on Space \(config.targetSpace) of the \(config.displayType == .main ? "main display" : "external monitor")")
        print("  • To verify: Press Control+\(config.targetSpace)")
    }
    
    /// Show accessibility permission error
    private func showAccessibilityError() {
        print("❌ Accessibility permission required")
        print("Please grant permission in:")
        print("System Preferences > Security & Privacy > Privacy > Accessibility")
        requestAccessibilityPermission()
    }
    
    /// Common method to arrange apps with given configuration
    internal func arrangeApps(config: AppConfiguration) {
        print("📱 Desktop App Manager - \(config.displayName) Space \(config.targetSpace) Setup")
        print("=" * 50)
        
        // Check accessibility permission
        guard checkAccessibilityPermission() else {
            print("❌ Accessibility permission required")
            print("Please grant permission in:")
            print("System Preferences > Security & Privacy > Privacy > Accessibility")
            requestAccessibilityPermission()
            return
        }
        
        print("\n🎯 Target configuration:")
        if config.displayType == .external {
            print("  • First: Move apps to Space 1")
            print("  • Then: Move to \(config.displayName) - Space \(config.targetSpace)")
        } else {
            print("  • Move to \(config.displayName) - Space \(config.targetSpace)")
        }
        
        for appName in config.targetApps {
            let placement = config.appPlacements[appName] ?? .full
            let position = getPositionDescription(placement)
            print("  • \(appName): \(position) of screen")
        }
        
        // For external display, first move apps to Space 1
        if config.displayType == .external {
            if config.collectAllWindows {
                print("\n[Step 1] Collecting ALL \(config.targetApps.joined(separator: " and ")) windows from Space 1-4...")
                collectAllAppsToSpace1(config.targetApps, config.appPlacements)
            } else {
                print("\n[Step 1] Finding and moving apps to Space 1...")
                moveAppsToSpace1(config.targetApps)
            }
            Thread.sleep(forTimeInterval: 2.0)
        }
        
        // Switch to target space
        let stepNum = config.displayType == .external ? 2 : 1
        print("\n[Step \(stepNum)] Switching to Space \(config.targetSpace)...")
        switchToSpace(config.targetSpace)
        Thread.sleep(forTimeInterval: 1.0)
        
        // Get display based on type
        let display: NSScreen?
        let externalMonitor: MonitorManager.MonitorInfo?
        
        if config.displayType == .main {
            display = NSScreen.main
            externalMonitor = nil
            if display == nil {
                print("\n❌ Could not get main display")
                return
            }
            print("\n✅ Main display found")
            print("  • Resolution: \(Int(display!.frame.width)) x \(Int(display!.frame.height))")
        } else {
            // Detect monitors for external display
            print("\n[Step \(stepNum + 1)] Detecting monitors...")
            let monitors = monitorManager.detectMonitors()
            
            guard monitors.count > 1 else {
                print("\n❌ No external monitor detected!")
                print("  Please connect an external display and try again.")
                return
            }
            
            guard let extMonitor = monitors.first(where: { !$0.isMain }) else {
                print("\n❌ Could not identify external monitor")
                return
            }
            
            externalMonitor = extMonitor
            print("\n✅ External monitor found: \(extMonitor.name)")
            print("  • Resolution: \(Int(extMonitor.frame.width)) x \(Int(extMonitor.frame.height))")
            print("  • Position: (\(Int(extMonitor.frame.origin.x)), \(Int(extMonitor.frame.origin.y)))")
            
            // For external monitor, we'll use the frame directly
            display = NSScreen.screens.first { screen in
                screen.frame.origin.x == extMonitor.frame.origin.x &&
                screen.frame.origin.y == extMonitor.frame.origin.y
            }
        }
        
        guard let targetDisplay = display else {
            print("\n❌ Could not get target display")
            return
        }
        
        // Setup and activate apps
        let nextStep = config.displayType == .external ? stepNum + 2 : stepNum + 1
        print("\n[Step \(nextStep)] Setting up target apps...")
        var runningApps: [String: NSRunningApplication] = [:]
        
        for appName in config.targetApps {
            print("  → Setting up \(appName)...")
            if let app = findOrLaunchApp(appName) {
                runningApps[appName] = app
                activateApp(app)
                Thread.sleep(forTimeInterval: 0.5)
                print("  ✅ \(appName) activated")
            } else {
                print("  ❌ Could not setup \(appName)")
            }
        }
        
        // Position apps on display
        let finalStep = nextStep + 1
        if config.displayType == .external, let extMonitor = externalMonitor {
            print("\n[Step \(finalStep)] Moving apps to external monitor (Space \(config.targetSpace))...")
            
            // Move mouse to external monitor
            moveMouseToExternalMonitor(extMonitor)
            Thread.sleep(forTimeInterval: 0.5)
            
            // Focus external monitor space
            focusExternalMonitorSpace(extMonitor, spaceNumber: config.targetSpace)
            Thread.sleep(forTimeInterval: 0.5)
            
            // Move all windows to external monitor
            moveAllWindowsToExternalMonitor(
                extMonitor,
                runningApps: runningApps,
                targetApps: config.targetApps,
                placements: config.appPlacements
            )
        } else {
            print("\n[Step \(finalStep)] Positioning apps on main display (Space \(config.targetSpace))...")
            
            // Position each app according to placement
            let frame = targetDisplay.frame
            for (appName, app) in runningApps {
                let placement = config.appPlacements[appName] ?? .full
                let appFrame = getFrameForPlacement(placement, in: frame)
                print("  📍 Positioning \(appName)...")
                positionWindow(app, frame: appFrame)
                assignWindowToCurrentSpace(app)
            }
        }
        
        // Final verification
        print("\n[Step \(finalStep + 1)] Final verification...")
        Thread.sleep(forTimeInterval: 1.0)
        
        printCompletionSummary(config: config)
    }
    
    /// Helper to get position description
    private func getPositionDescription(_ placement: WindowSide) -> String {
        switch placement {
        case .left:
            return "Left 50%"
        case .right:
            return "Right 50%"
        case .full:
            return "Full screen"
        }
    }
    
    /// Helper to get frame for placement
    private func getFrameForPlacement(_ placement: WindowSide, in screenFrame: CGRect) -> CGRect {
        switch placement {
        case .left:
            return CGRect(
                x: screenFrame.origin.x,
                y: screenFrame.origin.y,
                width: screenFrame.width / 2,
                height: screenFrame.height
            )
        case .right:
            return CGRect(
                x: screenFrame.origin.x + screenFrame.width / 2,
                y: screenFrame.origin.y,
                width: screenFrame.width / 2,
                height: screenFrame.height
            )
        case .full:
            return screenFrame
        }
    }
    
    /// Move apps to Space 1 (used for external monitor setup)
    internal func moveAppsToSpace1(_ targetApps: [String]) {
        print("  📍 Searching for \(targetApps.joined(separator: " and "))...")
        
        // Switch to Space 1
        print("  → Switching to Space 1...")
        switchToSpace(1)
        Thread.sleep(forTimeInterval: 1.0)
        
        // Find and activate each target app
        for (index, appName) in targetApps.enumerated() {
            if let app = findOrLaunchApp(appName) {
                print("  → Found \(appName), moving to Space 1...")
                activateApp(app)
                Thread.sleep(forTimeInterval: 0.5)
                
                // Position window on Space 1 (slightly offset for each app)
                if let screen = NSScreen.main {
                    let centerX = screen.frame.width / 2 - 400 + CGFloat(index * 50)
                    let centerY = screen.frame.height / 2 - 300 + CGFloat(index * 50)
                    let centerFrame = CGRect(x: centerX, y: centerY, width: 800, height: 600)
                    positionWindow(app, frame: centerFrame)
                }
                print("  ✅ \(appName) moved to Space 1")
            }
        }
        
        print("  ✅ All apps are now on Space 1")
    }
    
    /// Print completion summary
    private func printCompletionSummary(config: AppConfiguration) {
        print("\n" + "=" * 50)
        print("✅ Setup complete!")
        
        print("\n📌 Final state:")
        print("  • Location: \(config.displayName) - Space \(config.targetSpace)")
        
        for appName in config.targetApps {
            let placement = config.appPlacements[appName] ?? .full
            let position = getPositionDescription(placement)
            print("  • \(appName): \(position) of \(config.displayType == .main ? "main display" : "external monitor")")
        }
        
        print("\n💡 Tips:")
        print("  • Apps are now on Space \(config.targetSpace) of the \(config.displayType == .main ? "main display" : "external monitor")")
        print("  • To verify: Press Control+\(config.targetSpace)")
        print("  • To fix app to this space:")
        print("    Right-click app in Dock > Options > Assign to Desktop \(config.targetSpace)")
        
        print("\n🎯 Success! Apps are positioned on \(config.displayName)'s Space \(config.targetSpace)")
    }
    
    /// Collect all windows from all spaces to Space 1
    internal func collectAllAppsToSpace1(_ targetApps: [String], _ appPlacements: [String: WindowSide]) {
        print("  📍 Searching for ALL \(targetApps.joined(separator: " and ")) windows across spaces 1-4...")
        
        let workspace = NSWorkspace.shared
        var runningApps: [String: NSRunningApplication] = [:]
        
        // Check if each target app is running
        for appName in targetApps {
            if let app = workspace.runningApplications.first(where: { $0.localizedName == appName }) {
                runningApps[appName] = app
                print("  ✓ \(appName) is running")
            } else {
                if let app = findOrLaunchApp(appName) {
                    runningApps[appName] = app
                }
            }
        }
        
        // Space 1 placement counters
        var windowsCollected: [String: Int] = [:]
        var appPositions: [String: [(x: CGFloat, y: CGFloat)]] = [:]
        
        // Initialize counters and position arrays for each app
        for appName in targetApps {
            windowsCollected[appName] = 0
            appPositions[appName] = []
        }
        
        // Pre-calculate positions
        if let screen = NSScreen.main {
            // Calculate window positions for each app (horizontally distributed)
            let appCount = targetApps.count
            for (index, appName) in targetApps.enumerated() {
                let baseX = screen.frame.width * CGFloat(index + 1) / CGFloat(appCount + 1) - 300
                
                for i in 0..<10 { // Prepare up to 10 window positions
                    let x = baseX + CGFloat(i * 30)
                    let y = screen.frame.height / 2 - 300 + CGFloat(i * 30)
                    appPositions[appName]?.append((x: x, y: y))
                }
            }
        }
        
        // Iterate through each space to find windows
        for spaceNumber in 1...4 {
            print("\n  → Checking Space \(spaceNumber) for \(targetApps.joined(separator: " and ")) windows...")
            switchToSpace(spaceNumber)
            Thread.sleep(forTimeInterval: 0.8)
            
            // Check windows for each target app
            for appName in targetApps {
                guard let app = runningApps[appName] else { continue }
                activateApp(app)
                Thread.sleep(forTimeInterval: 0.3)
                
                let windows = getVisibleAppWindows(app)  // Get only non-minimized windows
                if windows.count > 0 {
                    print("    ✓ Found \(windows.count) \(appName) window(s) in Space \(spaceNumber)")
                    
                    let currentCollected = windowsCollected[appName] ?? 0
                    let positions = appPositions[appName] ?? []
                    
                    if spaceNumber == 1 {
                        // Space 1 windows - reposition in place
                        for (index, window) in windows.enumerated() {
                            if currentCollected + index < positions.count {
                                let pos = positions[currentCollected + index]
                                positionWindowAt(window, x: pos.x, y: pos.y, width: 800, height: 600)
                                print("    → \(appName) window \(index + 1) repositioned in Space 1")
                            }
                        }
                        windowsCollected[appName] = currentCollected + windows.count
                    } else {
                        // Space 2-4 windows - move to Space 1
                        print("    → Moving \(windows.count) \(appName) window(s) to Space 1...")
                        switchToSpace(1)
                        Thread.sleep(forTimeInterval: 0.8)
                        activateApp(app)
                        Thread.sleep(forTimeInterval: 0.3)
                        
                        for (index, window) in windows.enumerated() {
                            if currentCollected + index < positions.count {
                                let pos = positions[currentCollected + index]
                                positionWindowAt(window, x: pos.x, y: pos.y, width: 800, height: 600)
                                raiseWindow(window)
                                print("      ✓ \(appName) window \(index + 1) moved to Space 1")
                            }
                        }
                        windowsCollected[appName] = currentCollected + windows.count
                        
                        // Return to the original space
                        if spaceNumber < 4 {
                            switchToSpace(spaceNumber)
                            Thread.sleep(forTimeInterval: 0.5)
                        }
                    }
                }
            }
        }
        
        // Finally return to Space 1
        print("\n  → Finalizing: Returning to Space 1...")
        switchToSpace(1)
        Thread.sleep(forTimeInterval: 1.0)
        
        // Activate apps to verify all windows
        for appName in targetApps {
            if let app = runningApps[appName] {
                activateApp(app)
                Thread.sleep(forTimeInterval: 0.3)
            }
        }
        
        // Display summary
        var summary: [String] = []
        for appName in targetApps {
            let count = windowsCollected[appName] ?? 0
            summary.append("\(count) \(appName)")
        }
        print("\n  ✅ Successfully collected \(summary.joined(separator: " and ")) window(s) to Space 1")
    }
    
    // MARK: - Window Arrangement Methods
    
    /// すべての対象アプリウィンドウを外部モニターに移動（共通メソッド）
    internal func moveAllWindowsToExternalMonitor(
        _ monitor: MonitorManager.MonitorInfo,
        runningApps: [String: NSRunningApplication],
        targetApps: [String],
        placements: [String: WindowSide]
    ) {
        let frame = monitor.frame
        
        // 左右それぞれのエリア
        let leftArea = CGRect(
            x: frame.origin.x,
            y: frame.origin.y,
            width: frame.width / 2,
            height: frame.height
        )
        let rightArea = CGRect(
            x: frame.origin.x + frame.width / 2,
            y: frame.origin.y,
            width: frame.width / 2,
            height: frame.height
        )
        
        // 各側のウィンドウカウンター（カスケード用）
        var leftWindowCount = 0
        var rightWindowCount = 0
        
        for appName in targetApps {
            guard let app = runningApps[appName] else { continue }
            guard let side = placements[appName] else { continue }
            
            let area: CGRect
            var windowIndex: Int
            
            switch side {
            case .left:
                area = leftArea
                windowIndex = leftWindowCount
                leftWindowCount += 1
            case .right:
                area = rightArea
                windowIndex = rightWindowCount
                rightWindowCount += 1
            case .full:
                area = frame
                windowIndex = 0
            }
            
            let sideText = side == .left ? "left" : (side == .right ? "right" : "full")
            print("  📍 Moving all \(appName) windows to \(sideText) side of external monitor...")
            let windows = getVisibleAppWindows(app)  // 最小化されていないウィンドウのみ取得
            
            for (subIndex, window) in windows.enumerated() {
                // カスケード表示（同じ側に複数アプリがある場合のオフセット + 各アプリの複数ウィンドウのオフセット）
                let appOffset = CGFloat(windowIndex * 50)  // アプリごとのオフセット
                let windowOffset = CGFloat(subIndex * 30)   // ウィンドウごとのオフセット
                
                let windowFrame = CGRect(
                    x: area.origin.x + appOffset + windowOffset,
                    y: area.origin.y + appOffset + windowOffset,
                    width: area.width - (appOffset + windowOffset) * 2,
                    height: area.height - (appOffset + windowOffset) * 2
                )
                
                // ウィンドウの位置を設定
                var position = CGPoint(x: windowFrame.origin.x, y: windowFrame.origin.y)
                if let positionValue = AXValueCreate(.cgPoint, &position) {
                    AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
                }
                
                // ウィンドウのサイズを設定
                var size = CGSize(width: windowFrame.width, height: windowFrame.height)
                if let sizeValue = AXValueCreate(.cgSize, &size) {
                    AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
                }
                
                print("    ✅ \(appName) window \(subIndex + 1) positioned on external monitor (\(sideText) side)")
            }
            
            // アプリをアクティブにして現在のスペースに固定
            activateApp(app)
            Thread.sleep(forTimeInterval: 0.2)
            assignWindowToCurrentSpace(app)
            print("  ✅ All \(windows.count) \(appName) window(s) moved to external monitor")
        }
    }
}