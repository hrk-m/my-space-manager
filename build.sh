#!/bin/bash

# Desktop App Manager - ビルドスクリプト

echo "🔨 Building Desktop App Manager..."

# ビルドディレクトリを作成
mkdir -p build

# Swiftファイルをコンパイル
swiftc -o build/desktop-app-manager \
    -framework Cocoa \
    -framework ApplicationServices \
    -framework CoreGraphics \
    MonitorManager.swift \
    DesktopAppManagerBase.swift \
    DesktopAppManagerSpace1.swift \
    DesktopAppManagerSpace2.swift \
    DesktopAppManagerSpace3.swift \
    DesktopAppManagerSpace4.swift \
    DesktopAppManagerSpaceAll.swift \
    main.swift

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📦 Output: build/desktop-app-manager"
    echo ""
    echo "Usage:"
    echo "  ./build/desktop-app-manager [option]"
    echo ""
    echo "Options:"
    echo "  --organize-all       Organize ALL apps across all spaces"
    echo "  --external-space1    Slack on Main Display Space 1"
    echo "  --external-space2    TablePlus + Postman on External Monitor Space 2"
    echo "  --external-space3    iTerm + Cursor on External Monitor Space 3"
    echo "  --external-space4    Google Chrome on External Monitor Space 4"
    echo "  --help              Show help message"
    echo ""
    echo "⚠️  Note: The app requires Accessibility permission"
    echo "   Grant it in System Preferences > Security & Privacy > Privacy > Accessibility"
else
    echo "❌ Build failed!"
    exit 1
fi