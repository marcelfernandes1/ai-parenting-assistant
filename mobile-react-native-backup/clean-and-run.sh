#!/bin/bash

# AI Parenting Assistant - Complete Clean and Run Script
# This script performs a nuclear clean and starts the app fresh

set -e  # Exit on any error

echo "🧹 Step 1: Killing all Metro processes..."
pkill -9 -f "metro" 2>/dev/null || true
pkill -9 -f "react-native start" 2>/dev/null || true
pkill -9 -f "node.*8083" 2>/dev/null || true

echo "🧹 Step 2: Cleaning Metro caches..."
rm -rf node_modules/.cache 2>/dev/null || true
rm -rf $TMPDIR/metro-* 2>/dev/null || true
rm -rf $TMPDIR/haste-map-* 2>/dev/null || true
rm -rf $TMPDIR/react-* 2>/dev/null || true

echo "🧹 Step 3: Cleaning iOS build artifacts..."
rm -rf ios/build 2>/dev/null || true
rm -rf ~/Library/Developer/Xcode/DerivedData/AIParentingAssistant-* 2>/dev/null || true

echo "🧹 Step 4: Cleaning watchman (if installed)..."
watchman watch-del-all 2>/dev/null || true

echo "✅ Clean complete!"
echo ""
echo "📱 Now run these commands in separate terminals:"
echo ""
echo "Terminal 1 (Backend):"
echo "  cd backend && npm run dev"
echo ""
echo "Terminal 2 (Metro):"
echo "  cd mobile && npm start"
echo ""
echo "Terminal 3 (iOS App):"
echo "  cd mobile && npm run ios"
echo ""
