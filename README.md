# 🚀 Desktop App Manager

macOSの複数デスクトップ（Space）にアプリケーションを自動配置し、効率的な作業環境を構築するツールです。

![macOS](https://img.shields.io/badge/macOS-10.15+-blue)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## 📌 概要

Desktop App Managerは、macOSの仮想デスクトップ（Space）機能を活用して、用途別にアプリケーションを自動配置します。毎朝の作業環境セットアップや、プレゼン・会議後の環境復元を瞬時に行えます。

### こんな方におすすめ
- 🎯 複数のデスクトップを使い分けて作業している
- 🎯 毎日同じアプリ配置で作業を始めたい
- 🎯 外部モニターと内蔵ディスプレイを効率的に使いたい
- 🎯 プレゼン後に素早く作業環境を復元したい

## 🎬 クイックスタート

### 1. リポジトリのクローン
```bash
git clone https://github.com/yourusername/desktop-app-manager.git
cd desktop-app-manager
```

### 2. ビルド
```bash
make build
```

### 3. 実行
```bash
# 開発環境をセットアップ（Space 3: iTerm + Cursor）
make dev

# または、データベース作業環境（Space 2: TablePlus + Postman）
make db
```

## 🛠 環境構築

### 前提条件

#### システム要件
- ✅ macOS 10.15 (Catalina) 以降
- ✅ 外部モニター（Space 2-4を使用する場合）
- ✅ Xcode Command Line Tools

#### 必要なアプリケーション
以下のアプリケーションを事前にインストールしてください：

| Space | 必要なアプリ | インストール方法 |
|-------|------------|--------------|
| Space 1 | Slack | [公式サイト](https://slack.com/downloads/mac) or `brew install --cask slack` |
| Space 2 | TablePlus | [公式サイト](https://tableplus.com/) or `brew install --cask tableplus` |
| Space 2 | Postman | [公式サイト](https://www.postman.com/downloads/) or `brew install --cask postman` |
| Space 3 | iTerm2 | [公式サイト](https://iterm2.com/) or `brew install --cask iterm2` |
| Space 3 | Cursor | [公式サイト](https://cursor.sh/) |
| Space 4 | Google Chrome | [公式サイト](https://www.google.com/chrome/) or `brew install --cask google-chrome` |

### セットアップ手順

#### 1️⃣ アクセシビリティ権限の設定（重要）

本ツールはウィンドウを操作するため、アクセシビリティ権限が必要です。

1. **システム環境設定** を開く
2. **セキュリティとプライバシー** → **プライバシー** タブ
3. 左側のリストから **アクセシビリティ** を選択
4. 🔒 左下の鍵をクリックして変更を許可
5. ➕ ボタンをクリックして **ターミナル.app** を追加
6. チェックボックスを有効にする

<details>
<summary>📸 スクリーンショットで確認</summary>

設定画面の例：
- ターミナル.app にチェックが入っていることを確認
- 実行後、desktop-app-manager が自動的に追加される場合もあります

</details>

#### 2️⃣ キーボードショートカットの設定

Space（デスクトップ）切り替えのショートカットを設定します。

1. **システム環境設定** → **キーボード** → **ショートカット**
2. 左側から **Mission Control** を選択
3. 以下のように設定：
   - 「デスクトップ1へ切り替え」: `Control + 1`
   - 「デスクトップ2へ切り替え」: `Control + 2`
   - 「デスクトップ3へ切り替え」: `Control + 3`
   - 「デスクトップ4へ切り替え」: `Control + 4`

#### 3️⃣ ビルド

```bash
# Makefileを使用
make build

# または直接ビルドスクリプトを実行
./build.sh
```

## 📱 アプリケーション配置

### Space構成

| Space | 用途 | 配置アプリ | モニター |
|-------|------|-----------|----------|
| **Space 1** | 📨 コミュニケーション | Slack（左50%） | メインディスプレイ |
| **Space 2** | 🗄️ データベース作業 | TablePlus（左50%）<br>Postman（右50%） | 外部モニター |
| **Space 3** | 💻 開発環境 | iTerm（左50%）<br>Cursor（右50%） | 外部モニター |
| **Space 4** | 🌐 ブラウジング | Google Chrome（中央80%） | 外部モニター |

### 配置イメージ

```
[Space 1 - メインディスプレイ]
┌─────────────────────────┐
│                         │
│      Slack (左50%)      │
│                         │
└─────────────────────────┘

[Space 2-4 - 外部モニター]
┌───────────┬───────────┐
│           │           │
│  App 1    │   App 2   │
│  (左50%)  │  (右50%)  │
│           │           │
└───────────┴───────────┘
```

## 🎮 使い方

### Makeコマンド（推奨）

```bash
# 個別のSpace配置
make space1    # Space 1: Slack
make space2    # Space 2: TablePlus + Postman
make space3    # Space 3: iTerm + Cursor
make space4    # Space 4: Google Chrome

# エイリアス（覚えやすい）
make slack     # = make space1
make db        # = make space2
make dev       # = make space3
make browser   # = make space4

# 全Space一括配置
make all       # すべてのSpaceを順番に配置

# その他
make help      # ヘルプ表示
make check     # 権限確認
```

### 直接実行

```bash
# ビルド済みの実行ファイルを直接実行
./build/desktop-app-manager --external-space1  # Space 1
./build/desktop-app-manager --external-space2  # Space 2（デフォルト）
./build/desktop-app-manager --external-space3  # Space 3
./build/desktop-app-manager --external-space4  # Space 4
./build/desktop-app-manager --organize-all     # 全Space
```

## 🔧 カスタマイズ

### アプリケーションの追加・変更

`DesktopAppManagerBase.swift` の `bundleIds` 辞書に追加：

```swift
internal let bundleIds: [String: String] = [
    "iTerm": "com.googlecode.iterm2",
    "Cursor": "com.todesktop.230313mzl4w4u92",
    "YourApp": "com.yourcompany.yourapp",  // 追加
    // ...
]
```

Bundle IDの確認方法：
```bash
osascript -e 'id of app "アプリ名"'
```

### 配置位置の調整

各 `DesktopAppManagerSpaceX.swift` ファイルで配置をカスタマイズできます。

## 🐛 トラブルシューティング

### よくある問題と解決方法

| 問題 | 解決方法 |
|------|---------|
| 「アクセシビリティ権限がありません」エラー | 上記の[アクセシビリティ権限の設定](#1️⃣-アクセシビリティ権限の設定重要)を確認 |
| アプリが起動しない | アプリがインストールされているか確認<br>`brew list --cask` で確認 |
| ウィンドウが移動しない | アプリが最小化されていないか確認<br>Space切り替えショートカットが設定されているか確認 |
| 外部モニターが認識されない | モニター接続を確認<br>システム環境設定 → ディスプレイで認識されているか確認 |

### デバッグモード

問題の詳細を確認：
```bash
# 権限状態を確認
make check

# ヘルプを表示
make test
```

## 📁 プロジェクト構成

```
desktop-app-manager/
├── 📄 main.swift                    # エントリーポイント
├── 📄 DesktopAppManagerBase.swift   # 基底クラス（共通機能）
├── 📄 DesktopAppManagerSpace1.swift # Space 1配置ロジック
├── 📄 DesktopAppManagerSpace2.swift # Space 2配置ロジック
├── 📄 DesktopAppManagerSpace3.swift # Space 3配置ロジック
├── 📄 DesktopAppManagerSpace4.swift # Space 4配置ロジック
├── 📄 DesktopAppManagerSpaceAll.swift # 全Space一括配置
├── 📄 MonitorManager.swift          # モニター検出・管理
├── 📄 Makefile                      # ビルド・実行コマンド
├── 📄 build.sh                      # ビルドスクリプト
├── 📄 README.md                     # このファイル
├── 📄 REQUIREMENTS.md               # 詳細要件定義
└── 📁 build/                        # ビルド出力ディレクトリ
    └── desktop-app-manager          # 実行ファイル
```

## 🤝 貢献

プルリクエストを歓迎します！

1. Fork it
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 🙏 謝辞

- macOSのアクセシビリティAPIを活用
- Swift言語の強力な機能を使用

---

**問題が発生した場合**: [Issue](https://github.com/yourusername/desktop-app-manager/issues) を作成してください。