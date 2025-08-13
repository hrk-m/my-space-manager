import Foundation

// Swiftの文字列繰り返し拡張
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}

// コマンドライン引数を取得
let arguments = CommandLine.arguments

// ヘルプメッセージ
func showHelp() {
    print("🚀 Desktop App Manager")
    print("=" * 50)
    print("\nUsage:")
    print("  ./build/desktop-app-manager [option]")
    print("\nOptions:")
    print("  --organize-all       Organize ALL apps across all spaces")
    print("  --external-space1    Slack (left 50%) on Main Display Space 1")
    print("  --external-space2    TablePlus + Postman on External Monitor Space 2")
    print("  --external-space3    iTerm + Cursor on External Monitor Space 3")
    print("  --external-space4    Google Chrome on External Monitor Space 4")
    print("  --help              Show this help message")
    print("\nExamples:")
    print("  ./build/desktop-app-manager --organize-all     # Complete organization")
    print("  ./build/desktop-app-manager --external-space1  # Main display")
    print("  ./build/desktop-app-manager --external-space2  # External monitor")
    print("  ./build/desktop-app-manager --external-space3  # External monitor")
    print("  ./build/desktop-app-manager --external-space4  # External monitor")
}

// 引数がない場合はデフォルトでSpace 2を実行
if arguments.count < 2 {
    print("🚀 Desktop App Manager - External Monitor Space 2 (Default)")
    print("=" * 50)
    let manager = DesktopAppManagerExternalSpace2()
    manager.arrangeAppsOnExternalMonitorSpace2()
} else {
    // コマンドライン引数に応じて処理を分岐
    switch arguments[1] {
    case "--organize-all":
        let manager = DesktopAppManagerSpaceAll()
        manager.arrangeAllApps()
        
    case "--external-space1":
        let manager = DesktopAppManagerSpace1()
        manager.arrangeAppsOnMainDisplaySpace1()
        
    case "--external-space2":
        let manager = DesktopAppManagerExternalSpace2()
        manager.arrangeAppsOnExternalMonitorSpace2()
        
    case "--external-space3":
        let manager = DesktopAppManagerSpace3()
        manager.arrangeAppsOnExternalMonitorSpace3()
        
    case "--external-space4":
        let manager = DesktopAppManagerSpace4()
        manager.arrangeAppsOnExternalMonitorSpace4()
        
    case "--help", "-h":
        showHelp()
        
    default:
        print("❌ Unknown option: \(arguments[1])")
        print("Use --help to see available options")
        exit(1)
    }
}