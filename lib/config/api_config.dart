import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration for the application
///
/// Auto-detects platform and uses appropriate base URL:
/// - Android Emulator: 10.0.2.2 (maps to host's localhost)
/// - iOS Simulator/Web/Desktop: localhost
/// - Physical devices: Use your computer's IP address (manually configure)

class ApiConfig {
  /// Auto-detects platform and returns appropriate base URL
  /// 
  /// - Android Emulator: 'http://10.0.2.2:60491'
  /// - iOS Simulator/Web/Desktop: 'http://localhost:60491'
  /// - For physical devices, manually set IP address below
  static String get baseUrl {
    // Web platform (Flutter web)
    if (kIsWeb) {
      return 'http://localhost:60491';
    }
    
    // Mobile platforms
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:60491'; // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:60491'; // iOS simulator
    }
    
    // Desktop platforms (Windows, macOS, Linux)
    return 'http://localhost:60491'; // Default for desktop
  }
  
  /// For physical devices on same WiFi network, use this method
  /// Replace with your computer's IP address (e.g., '192.168.1.100')
  /// Find your IP: Windows (ipconfig) or macOS/Linux (ifconfig)
  static String getBaseUrlForPhysicalDevice(String ipAddress) {
    return 'http://$ipAddress:60491';
  }
}
