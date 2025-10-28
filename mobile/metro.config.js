const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config');

/**
 * Metro configuration for React Native bundler
 * https://reactnative.dev/docs/metro
 *
 * Custom configuration:
 * - Port 8083: Using non-standard port to avoid conflicts with other services
 *   (8080, 8081, 8082 are commonly used by other dev servers)
 *
 * @type {import('@react-native/metro-config').MetroConfig}
 */
const config = {
  server: {
    // Use port 8083 to avoid conflicts with other development servers
    port: 8083,
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
