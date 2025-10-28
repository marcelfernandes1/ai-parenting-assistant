#!/bin/bash

# QUICK START - AI Parenting Assistant
# This script ensures EVERYTHING is clean before starting

set -e

echo "🚨 NUCLEAR CLEAN - Removing ALL caches..."
echo ""

# Kill all processes
echo "1️⃣ Killing Metro, React Native, and Simulator..."
pkill -9 -f "metro" 2>/dev/null || true
pkill -9 -f "react-native" 2>/dev/null || true
pkill -9 -f "node.*8083" 2>/dev/null || true
pkill -9 -f "Simulator" 2>/dev/null || true
sleep 2

# Clean Metro caches
echo "2️⃣ Cleaning Metro caches..."
rm -rf node_modules/.cache 2>/dev/null || true
rm -rf /tmp/metro-* 2>/dev/null || true
rm -rf /tmp/haste-* 2>/dev/null || true
rm -rf /tmp/react-* 2>/dev/null || true

# Clean Xcode
echo "3️⃣ Cleaning Xcode caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true
rm -rf ios/build 2>/dev/null || true

# Clean watchman
echo "4️⃣ Cleaning Watchman..."
watchman watch-del-all 2>/dev/null || echo "   (Watchman not installed - OK)"

echo ""
echo "✅ CLEAN COMPLETE!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "NOW START THE APP IN 3 TERMINALS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 Terminal 1 - BACKEND:"
echo "   cd backend"
echo "   npm run dev"
echo ""
echo "📍 Terminal 2 - METRO (wait for backend first!):"
echo "   cd mobile"
echo "   npm start"
echo ""
echo "📍 Terminal 3 - iOS (wait for Metro!):"
echo "   cd mobile"
echo "   npm run ios"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  IMPORTANT: Close Expo Go if it's installed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
