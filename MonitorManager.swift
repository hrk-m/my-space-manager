import Cocoa
import CoreGraphics

/// モニター管理クラス - 外部モニターのスペースへの移動をサポート
class MonitorManager {
    
    // MARK: - Properties
    
    /// 利用可能なモニター情報
    struct MonitorInfo {
        let screen: NSScreen
        let displayID: CGDirectDisplayID
        let name: String
        let isMain: Bool
        let frame: CGRect
        let index: Int
    }
    
    // MARK: - Public Methods
    
    /// 利用可能なモニターを検出
    func detectMonitors() -> [MonitorInfo] {
        print("\n🖥️ Detecting available monitors...")
        
        var monitors: [MonitorInfo] = []
        let screens = NSScreen.screens
        
        for (index, screen) in screens.enumerated() {
            let displayID = screen.displayID
            let isMain = screen == NSScreen.main
            let name = getDisplayName(displayID: displayID) ?? "Display \(index + 1)"
            
            let info = MonitorInfo(
                screen: screen,
                displayID: displayID,
                name: name,
                isMain: isMain,
                frame: screen.frame,
                index: index
            )
            
            monitors.append(info)
            
            print("  \(index + 1). \(name)")
            print("     • Resolution: \(Int(screen.frame.width)) x \(Int(screen.frame.height))")
            print("     • Position: (\(Int(screen.frame.origin.x)), \(Int(screen.frame.origin.y)))")
            print("     • Type: \(isMain ? "Built-in (Main)" : "External")")
        }
        
        return monitors
    }
    
    /// 外部モニターを取得
    func getExternalMonitor() -> MonitorInfo? {
        let monitors = detectMonitors()
        
        // 外部モニター（メインでないモニター）を探す
        if let external = monitors.first(where: { !$0.isMain }) {
            print("\n✅ External monitor found: \(external.name)")
            return external
        }
        
        print("\n⚠️ No external monitor detected")
        return nil
    }
    
    /// 指定したモニターにウィンドウを移動
    func moveWindowToMonitor(_ app: NSRunningApplication, monitor: MonitorInfo) {
        print("\n📱 Moving \(app.localizedName ?? "app") to \(monitor.name)...")
        
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
            print("  ⚠️ Could not find window for \(app.localizedName ?? "app")")
            return
        }
        
        // ウィンドウを外部モニターの座標に移動
        let targetFrame = monitor.frame
        var position = CGPoint(x: targetFrame.origin.x + 100, y: targetFrame.origin.y + 100)
        
        if let positionValue = AXValueCreate(.cgPoint, &position) {
            AXUIElementSetAttributeValue(targetWindow, kAXPositionAttribute as CFString, positionValue)
            print("  ✅ Window moved to \(monitor.name)")
        }
    }
    
    /// アプリを外部モニターに配置（左右分割）
    func arrangeAppsOnExternalMonitor(tablePlusApp: NSRunningApplication?, postmanApp: NSRunningApplication?) {
        guard let monitor = getExternalMonitor() else {
            print("❌ No external monitor found. Please connect an external display.")
            return
        }
        
        let frame = monitor.frame
        
        // 左半分の座標
        let leftFrame = CGRect(
            x: frame.origin.x,
            y: frame.origin.y,
            width: frame.width / 2,
            height: frame.height
        )
        
        // 右半分の座標
        let rightFrame = CGRect(
            x: frame.origin.x + frame.width / 2,
            y: frame.origin.y,
            width: frame.width / 2,
            height: frame.height
        )
        
        // TablePlusを左側に配置
        if let app = tablePlusApp {
            print("\n📍 Positioning TablePlus on left side of \(monitor.name)...")
            positionWindow(app, frame: leftFrame)
        }
        
        // Postmanを右側に配置
        if let app = postmanApp {
            print("\n📍 Positioning Postman on right side of \(monitor.name)...")
            positionWindow(app, frame: rightFrame)
        }
    }
    
    // MARK: - Private Methods
    
    /// ディスプレイ名を取得
    private func getDisplayName(displayID: CGDirectDisplayID) -> String? {
        // IOKit を使用してディスプレイ名を取得（簡易版）
        if displayID == CGMainDisplayID() {
            return "Built-in Display"
        } else {
            // 外部モニターの場合
            return "External Display"
        }
    }
    
    /// ウィンドウを指定位置に配置
    private func positionWindow(_ app: NSRunningApplication, frame: CGRect) {
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
            print("  ⚠️ Could not find window")
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
        
        print("  ✅ Positioned at (\(Int(frame.origin.x)), \(Int(frame.origin.y))) with size \(Int(frame.width))x\(Int(frame.height))")
    }
}

// NSScreen拡張 - Display IDを取得
extension NSScreen {
    var displayID: CGDirectDisplayID {
        let screenNumber = self.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber
        return CGDirectDisplayID(screenNumber?.uint32Value ?? 0)
    }
}