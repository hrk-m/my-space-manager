import Foundation

/// スリープ時間の設定を管理する構造体
struct SleepTimeConfig {
    
    // MARK: - 基本的な待機時間（最速設定）
    
    /// キーボードイベント間の最小待機時間（キーダウンとキーアップの間）
    static let keyEventInterval: TimeInterval = 0.02
    
    /// スペース切り替え後の安定化待機時間
    static let spaceSwitch: TimeInterval = 0.3
    
    /// アプリケーションのアクティブ化後の待機時間
    static let appActivation: TimeInterval = 0.15
    
    /// ウィンドウ配置後の待機時間（配置精度を保証）
    static let windowPositioning: TimeInterval = 0.1
    
    // MARK: - 外部モニター関連
    
    /// マウスを外部モニターに移動後の待機時間
    static let mouseToExternalMonitor: TimeInterval = 0.15
    
    /// 外部モニターのスペースにフォーカス後の待機時間  
    static let externalMonitorFocus: TimeInterval = 0.2
    
    // MARK: - 複数ウィンドウ処理
    
    /// 複数ウィンドウ間の処理待機時間
    static let betweenWindows: TimeInterval = 0.08
    
    /// Space間を移動してアプリを収集する際の待機時間
    static let spaceCollection: TimeInterval = 0.25
    
    // MARK: - 初期化・最終処理
    
    /// アプリ起動後の初期化待機時間
    static let appLaunchWait: TimeInterval = 0.4
    
    /// 処理完了後の最終確認待機時間
    static let finalVerification: TimeInterval = 0.4
    
    /// 大きな処理グループ間の待機時間
    static let betweenMajorOperations: TimeInterval = 0.5
    
    // MARK: - シンプルな待機時間取得（常に最速）
    
    /// 待機時間を取得（調整なし、常に最速値を返す）
    static func adjustedTime(_ baseTime: TimeInterval) -> TimeInterval {
        return baseTime
    }
}