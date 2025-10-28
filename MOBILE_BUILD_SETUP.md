# Mobile App Build Setup Guide

This guide covers setting up the React Native mobile app for iOS and Android builds.

---

## Prerequisites

### General Requirements

- **Node.js 20+** ✅ (Already installed)
- **npm** ✅ (Already installed)
- **Xcode 14+** (for iOS development - macOS only)
- **Android Studio** (for Android development)
- **CocoaPods** (for iOS dependencies)

---

## iOS Setup (macOS only)

### 1. Install Xcode

1. Download Xcode from the Mac App Store
2. Open Xcode and accept the license agreement
3. Install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

### 2. Install CocoaPods

CocoaPods is required for managing iOS dependencies.

```bash
# Install CocoaPods using Homebrew (recommended)
brew install cocoapods

# Or install using Ruby gem
sudo gem install cocoapods
```

Verify installation:
```bash
pod --version
```

### 3. Install iOS Dependencies

```bash
cd mobile/ios
pod install
```

This will:
- Download all iOS dependencies
- Create `AIParentingAssistant.xcworkspace` file
- Configure the project for building

**Important:** Always open `AIParentingAssistant.xcworkspace` in Xcode, NOT the `.xcodeproj` file.

### 4. Build and Run iOS App

#### Option 1: Using React Native CLI (Recommended for Development)

```bash
cd mobile
npm run ios
```

This will:
- Start the Metro bundler
- Build the app
- Launch iOS Simulator
- Install and run the app

#### Option 2: Using Xcode

1. Open `mobile/ios/AIParentingAssistant.xcworkspace` in Xcode
2. Select a simulator or connected device
3. Press Cmd+R to build and run

#### Common iOS Build Issues

**Error: "Command not found: pod"**
```bash
# Install CocoaPods (see step 2 above)
```

**Error: "The workspace does not contain any scheme"**
```bash
cd ios
pod install
# Then open AIParentingAssistant.xcworkspace in Xcode
```

**Error: "No bundle URL present"**
```bash
# Make sure Metro bundler is running
npm start

# In another terminal
npm run ios
```

---

## Android Setup

### 1. Install Java Development Kit (JDK)

React Native requires JDK 17:

```bash
# macOS (using Homebrew)
brew install openjdk@17

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
```

Verify installation:
```bash
java -version
# Should show version 17.x.x
```

### 2. Install Android Studio

1. Download from https://developer.android.com/studio
2. Run the installer
3. During installation, make sure these components are selected:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device (AVD)

### 3. Configure Android SDK

1. Open Android Studio
2. Go to Settings → Appearance & Behavior → System Settings → Android SDK
3. Install the following SDK platforms:
   - Android 14.0 (API Level 34) - Latest
   - Android 13.0 (API Level 33)

4. Switch to "SDK Tools" tab and install:
   - Android SDK Build-Tools
   - Android Emulator
   - Android SDK Platform-Tools
   - Android SDK Command-line Tools
   - Intel x86 Emulator Accelerator (HAXM) - for Intel Macs
   - Google Play services

### 4. Set Up Environment Variables

Add to your `~/.zshrc` or `~/.bash_profile`:

```bash
# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
```

Apply changes:
```bash
source ~/.zshrc  # or source ~/.bash_profile
```

Verify:
```bash
echo $ANDROID_HOME
# Should print: /Users/yourusername/Library/Android/sdk

adb --version
# Should show Android Debug Bridge version
```

### 5. Create Android Virtual Device (AVD)

1. Open Android Studio
2. Go to Tools → Device Manager
3. Click "Create Device"
4. Select a device (e.g., Pixel 5)
5. Select a system image (e.g., Android 14.0 / API 34)
6. Click "Finish"

Or via command line:
```bash
# List available system images
sdkmanager --list | grep system-images

# Create AVD
avdmanager create avd -n Pixel_5_API_34 -k "system-images;android-34;google_apis;arm64-v8a"
```

### 6. Build and Run Android App

#### Option 1: Using React Native CLI (Recommended)

```bash
cd mobile

# List available emulators
npx react-native run-android --list-devices

# Run on emulator
npm run android
```

This will:
- Start the Metro bundler
- Build the Android APK
- Launch the emulator (if not running)
- Install and run the app

#### Option 2: Using Android Studio

1. Open `mobile/android` folder in Android Studio
2. Wait for Gradle sync to complete
3. Select your AVD or connected device
4. Click the "Run" button

#### Common Android Build Issues

**Error: "ANDROID_HOME not set"**
```bash
# Set up environment variables (see step 4 above)
source ~/.zshrc
```

**Error: "SDK location not found"**
```bash
# Create local.properties file
cd mobile/android
echo "sdk.dir=$HOME/Library/Android/sdk" > local.properties
```

**Error: "Could not find or load main class org.gradle.wrapper.GradleWrapperMain"**
```bash
cd mobile/android
./gradlew clean
./gradlew build
```

**Error: "Unable to locate adb"**
```bash
# Add Android SDK platform-tools to PATH
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

---

## Testing the Setup

### Quick Verification

```bash
cd mobile

# Test Metro bundler
npm start

# In another terminal:

# Test iOS build (macOS only)
npm run ios

# Test Android build
npm run android
```

### Expected Results

✅ **iOS:**
- iOS Simulator launches
- App installs successfully
- App shows default React Native welcome screen
- No errors in Metro bundler logs

✅ **Android:**
- Android Emulator launches
- App installs successfully
- App shows default React Native welcome screen
- No errors in Metro bundler logs

---

## Development Workflow

### Running the App

1. **Start Metro bundler** (in one terminal):
   ```bash
   cd mobile
   npm start
   ```

2. **Run on iOS** (in another terminal):
   ```bash
   npm run ios
   ```

3. **Run on Android** (in another terminal):
   ```bash
   npm run android
   ```

### Fast Refresh

When you edit code:
- Changes automatically reload in the app
- No need to rebuild or restart
- Press `r` in Metro bundler to manually reload
- Press `d` to open developer menu in app

### Debugging

- **iOS:** Cmd+D to open debug menu
- **Android:** Cmd+M (or Ctrl+M on Windows/Linux)
- **Chrome DevTools:** Select "Debug JS Remotely" from debug menu

### Building for Testing

#### iOS Development Build
```bash
npm run ios --configuration Debug
```

#### Android Debug APK
```bash
cd android
./gradlew assembleDebug
# APK location: android/app/build/outputs/apk/debug/app-debug.apk
```

---

## Troubleshooting

### Metro Bundler Won't Start

```bash
# Clear cache and restart
npx react-native start --reset-cache
```

### Build Fails After Installing New Package

```bash
# iOS: Reinstall pods
cd ios
pod install
cd ..

# Android: Clean Gradle
cd android
./gradlew clean
cd ..

# Clear React Native cache
npm start -- --reset-cache
```

### App Crashes Immediately on Launch

1. Check Metro bundler for errors
2. Verify all dependencies are installed: `npm install`
3. Rebuild the app: `npm run ios` or `npm run android`
4. Check Xcode or Android Studio logs for native errors

### Simulator/Emulator Performance Issues

**iOS Simulator:**
- Close other apps to free memory
- Restart simulator: Device → Restart

**Android Emulator:**
- Increase RAM allocation in AVD settings
- Enable hardware acceleration (HAXM on Intel, Hypervisor.framework on M1/M2)
- Use ARM64 system images on Apple Silicon Macs

---

## Next Steps

Once builds are working:

1. ✅ Verify iOS and Android builds run successfully
2. ✅ Test Fast Refresh by editing App.tsx
3. ✅ Open developer menu and explore options
4. ✅ Set up physical device testing (optional)
5. 🚀 Ready to start Phase 1 development!

---

*Last Updated: 2025-10-28*
