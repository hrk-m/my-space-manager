# Desktop App Manager - 要件定義書

## 概要
macOSの仮想デスクトップで管理される複数のデスクトップ間で、アプリケーションの配置を自動管理するmacOSネイティブアプリケーション。

## 目的
- 複数デスクトップ間でのアプリケーション配置の自動化
- 作業環境の迅速な構築と復元
- デスクトップごとの用途別アプリ配置の最適化

## 機能要件

### 1. デスクトップ識別機能
- macOSの仮想デスクトップ1〜4を識別
- 現在アクティブなデスクトップの表示

### 2. アプリケーション自動配置機能

#### 2.1 配置設定
| デスクトップ |  アプリケーション | 配置方法 | 
|------------|--------------|------|-----------------|
| Desktop 1 | Slack | 通常表示 |
| Desktop 2 |  TablePlus（左）<br>Postman（右） | 並列配置 
| Desktop 3 |iTerm（左）<br>Cursor（右） | 並列配置 |
| Desktop 4 |  Google Chrome | 通常表示 |

#### 2.2 配置タイプ
- **通常表示**: 画面中央に配置、画面の幅80%×高さ80%
- **並列配置**: 画面を左右50%ずつに分割、位置は固定

## 非機能要件

### 1. エラーハンドリング
- アプリケーション起動失敗時は通知でユーザーに通知
- デスクトップ切り替え失敗時の適切なエラー処理
- 設定ファイル読み込み/書き込みエラーの処理

### 2. パフォーマンス
- デスクトップ切り替えとアプリ配置は5秒以内に完了
- UIの応答性を維持（100ms以内のレスポンス）

### 3. 互換性
- macOS 10.15 (Catalina) 以降をサポート
- Appleシリコン（M1/M2）およびIntel Macに対応

## 技術仕様

### 使用技術
- **言語**: Swift 5.0+
- **UI Framework**: SwiftUI
- **ビルドツール**: Xcode
- **システム連携**: 
  - Accessibility API（ウィンドウ管理）
  - NSWorkspace（アプリケーション管理）
  - CGWindowListCopyWindowInfo（ウィンドウ情報取得）

### 使用言語・フレームワーク
- Swift 5（macOS App）
- AppKit
- CoreGraphics
- AXUIElement（アクセシビリティAPI）

### 必要な権限
- アクセシビリティアクセス（ユーザーに許可を要求）
- サンドボックス無効（開発・配布形態に応じて）

---

## 🔌 利用APIと目的

| API | 概要 |
|-----|------|
| `NSWorkspace.shared.runningApplications` | 起動中アプリ一覧の取得 |
| `AXUIElementCreateApplication(pid)` | アプリケーションのAXUI要素を取得 |
| `AXUIElementCopyAttributeValue(..., kAXPositionAttribute)` | ウィンドウの位置取得 |
| `AXUIElementCopyAttributeValue(..., kAXSizeAttribute)` | ウィンドウのサイズ取得 |
| `CGWindowListCopyWindowInfo(...)` | 補助的なウィンドウ情報取得（名前、バウンド等） |
| `NSScreen.screens` | ディスプレイ構成と座標空間の取得 |
| `NSWorkspace.shared.activeSpace` | 現在のSpace（デスクトップ）情報取得 |
| `CGSMoveWindowsToManagedSpace` | ウィンドウを特定のSpaceへ移動（Private API） |
| `NSWorkspace.notificationCenter` | アプリ起動イベントの監視 |

---