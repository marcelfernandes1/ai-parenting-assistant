#!/bin/bash

# ========================================
# AI PARENTING ASSISTANT - START SCRIPT
# ========================================
# This script starts Metro bundler with a completely clean slate
# Run this AFTER starting the backend

set -e

echo ""
echo "🚀 Starting AI Parenting Assistant Mobile App"
echo "=============================================="
echo ""

# Kill any existing Metro processes
echo "1️⃣ Stopping any running Metro processes..."
pkill -9 -f "metro" 2>/dev/null || true
pkill -9 -f "react-native start" 2>/dev/null || true
lsof -ti:8083 | xargs kill -9 2>/dev/null || true
sleep 1

# Clean Metro cache
echo "2️⃣ Cleaning Metro cache..."
rm -rf node_modules/.cache 2>/dev/null || true
rm -rf $TMPDIR/metro-* 2>/dev/null || true
rm -rf $TMPDIR/haste-* 2>/dev/null || true

echo "3️⃣ Starting Metro bundler on port 8083..."
echo ""
echo "⏳ Please wait for Metro to fully start..."
echo "   You should see: 'Loading dependency graph, done.'"
echo ""

# Start Metro with full reset
npx react-native start --port 8083 --reset-cache
