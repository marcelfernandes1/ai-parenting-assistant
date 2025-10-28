import UIKit
import React
import React_RCTAppDelegate

/**
 * AppDelegate for React Native 0.74 application
 * Inherits from RCTAppDelegate which provides React Native initialization and lifecycle management
 * This implementation is compatible with React Native 0.74
 *
 * Key differences from RN 0.82:
 * - Uses property-based configuration (moduleName, initialProps) instead of method overrides
 * - No ReactAppDependencyProvider or New Architecture factory classes
 * - Uses RCTBundleURLProvider directly for bundle URL configuration
 */
@main
class AppDelegate: RCTAppDelegate {

  /**
   * Application lifecycle entry point - called when app finishes launching
   * Sets up the root React Native module name and initial properties before
   * delegating to parent RCTAppDelegate for React Native initialization
   */
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    // Set the module name - must match AppRegistry.registerComponent in index.js
    // This tells React Native which JS module to load as the app root
    self.moduleName = "AIParentingAssistant"

    // Set initial properties to pass from native to JS on app launch
    // nil means no properties are passed (can be customized for feature flags, etc.)
    self.initialProps = nil

    // Call parent implementation to complete React Native initialization
    // This creates the bridge, loads the JS bundle, and renders the root view
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /**
   * Returns the URL where the JavaScript bundle is located
   * In DEBUG: Points to Metro bundler for hot reloading during development
   * In RELEASE: Points to pre-bundled JS file included in the app
   *
   * This method is called by RCTAppDelegate to locate and load the JS bundle
   */
  override func sourceURL(for bridge: RCTBridge) -> URL? {
    return self.bundleURL()
  }

  /**
   * Helper method to construct the bundle URL based on build configuration
   * DEBUG builds use Metro bundler at localhost:8083 for development with hot reload
   * RELEASE builds use the main.jsbundle file packaged with the app
   */
  override func bundleURL() -> URL? {
#if DEBUG
    // Development: Load JS from Metro bundler running on localhost:8083
    // The "index" parameter refers to index.js as the entry point
    // Metro port is configured in metro.config.js (using 8083 to avoid conflicts)
    return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
#else
    // Production: Load pre-packaged JS bundle from app resources
    // This bundle is created during the build process and included in the app binary
    return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
  }
}
