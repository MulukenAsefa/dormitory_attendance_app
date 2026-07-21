import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static const String _deviceIdKey = 'device_id';
  static const String _deviceInfoKey = 'device_info';
  
  /// Get unique device identifier
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedDeviceId = prefs.getString(_deviceIdKey);
    
    if (storedDeviceId != null) {
      return storedDeviceId;
    }
    
    // Generate new device ID
    final deviceInfo = await _getDeviceInfo();
    final deviceString = '${deviceInfo['model']}_${deviceInfo['id']}_${deviceInfo['brand']}';
    final bytes = utf8.encode(deviceString);
    final digest = sha256.convert(bytes);
    final deviceId = digest.toString();
    
    // Store device ID
    await prefs.setString(_deviceIdKey, deviceId);
    
    return deviceId;
  }
  
  /// Get comprehensive device information
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final storedInfo = prefs.getString(_deviceInfoKey);
    
    if (storedInfo != null) {
      return Map<String, dynamic>.from(json.decode(storedInfo));
    }
    
    final deviceInfo = await _getDeviceInfo();
    
    // Store device info
    await prefs.setString(_deviceInfoKey, json.encode(deviceInfo));
    
    return deviceInfo;
  }
  
  /// Get device information based on platform
  static Future<Map<String, dynamic>> _getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = {};
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData = {
          'platform': 'Android',
          'id': androidInfo.id,
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'manufacturer': androidInfo.manufacturer,
          'product': androidInfo.product,
          'device': androidInfo.device,
          'hardware': androidInfo.hardware,
          'fingerprint': androidInfo.fingerprint,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceData = {
          'platform': 'iOS',
          'id': iosInfo.identifierForVendor ?? 'unknown',
          'model': iosInfo.model,
          'brand': 'Apple',
          'manufacturer': 'Apple',
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'localizedModel': iosInfo.localizedModel,
          'utsname': iosInfo.utsname.machine,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        deviceData = {
          'platform': 'Windows',
          'id': windowsInfo.deviceId,
          'computerName': windowsInfo.computerName,
          'userName': windowsInfo.userName,
          'majorVersion': windowsInfo.majorVersion,
          'minorVersion': windowsInfo.minorVersion,
          'buildNumber': windowsInfo.buildNumber,
          'platformId': windowsInfo.platformId,
          'csdVersion': windowsInfo.csdVersion,
          'servicePackMajor': windowsInfo.servicePackMajor,
          'servicePackMinor': windowsInfo.servicePackMinor,
          'suitMask': windowsInfo.suitMask,
          'productType': windowsInfo.productType,
          'reserved': windowsInfo.reserved,
          'buildLab': windowsInfo.buildLab,
          'buildLabEx': windowsInfo.buildLabEx,
          'digitalProductId': windowsInfo.digitalProductId,
          'displayVersion': windowsInfo.displayVersion,
          'editionId': windowsInfo.editionId,
          'installDate': windowsInfo.installDate?.toIso8601String(),
          'productId': windowsInfo.productId,
          'productName': windowsInfo.productName,
          'registeredOwner': windowsInfo.registeredOwner,
          'releaseId': windowsInfo.releaseId,
          'deviceId': windowsInfo.deviceId,
        };
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfoPlugin.linuxInfo;
        deviceData = {
          'platform': 'Linux',
          'id': linuxInfo.machineId ?? 'unknown',
          'name': linuxInfo.name,
          'version': linuxInfo.version,
          'versionCodename': linuxInfo.versionCodename,
          'versionId': linuxInfo.versionId,
          'prettyName': linuxInfo.prettyName,
          'buildId': linuxInfo.buildId,
          'variant': linuxInfo.variant,
          'variantId': linuxInfo.variantId,
          'machineId': linuxInfo.machineId,
        };
      } else if (Platform.isMacOS) {
        final macOsInfo = await deviceInfoPlugin.macOsInfo;
        deviceData = {
          'platform': 'macOS',
          'id': macOsInfo.systemGUID ?? 'unknown',
          'computerName': macOsInfo.computerName,
          'hostName': macOsInfo.hostName,
          'arch': macOsInfo.arch,
          'model': macOsInfo.model,
          'kernelVersion': macOsInfo.kernelVersion,
          'majorVersion': macOsInfo.majorVersion,
          'minorVersion': macOsInfo.minorVersion,
          'patchVersion': macOsInfo.patchVersion,
          'osRelease': macOsInfo.osRelease,
          'activeCPUs': macOsInfo.activeCPUs,
          'memorySize': macOsInfo.memorySize,
          'cpuFrequency': macOsInfo.cpuFrequency,
          'systemGUID': macOsInfo.systemGUID,
        };
      }
      
      // Add timestamp
      deviceData['registeredAt'] = DateTime.now().toIso8601String();
      
    } catch (e) {
      print('Error getting device info: $e');
      deviceData = {
        'platform': 'Unknown',
        'id': 'unknown',
        'error': e.toString(),
        'registeredAt': DateTime.now().toIso8601String(),
      };
    }
    
    return deviceData;
  }
  
  /// Check if device is registered
  static Future<bool> isDeviceRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_deviceIdKey);
  }
  
  /// Clear device registration (for testing or reset)
  static Future<void> clearDeviceRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
    await prefs.remove(_deviceInfoKey);
  }
  
  /// Validate device integrity (anti-tampering)
  static Future<bool> validateDeviceIntegrity() async {
    try {
      final currentDeviceInfo = await _getDeviceInfo();
      final storedDeviceInfo = await getDeviceInfo();
      
      // Check critical device identifiers
      final criticalFields = ['platform', 'id', 'model', 'brand'];
      
      for (final field in criticalFields) {
        if (currentDeviceInfo[field] != storedDeviceInfo[field]) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      print('Error validating device integrity: $e');
      return false;
    }
  }
  
  /// Get device fingerprint for additional security
  static Future<String> getDeviceFingerprint() async {
    final deviceInfo = await _getDeviceInfo();
    final fingerprintData = {
      'platform': deviceInfo['platform'],
      'model': deviceInfo['model'],
      'brand': deviceInfo['brand'],
      'id': deviceInfo['id'],
    };
    
    final fingerprintString = json.encode(fingerprintData);
    final bytes = utf8.encode(fingerprintString);
    final digest = sha256.convert(bytes);
    
    return digest.toString();
  }
  
  /// Check if device is emulator/simulator
  static Future<bool> isEmulator() async {
    final deviceInfo = await _getDeviceInfo();
    
    if (Platform.isAndroid) {
      final isPhysical = deviceInfo['isPhysicalDevice'] as bool? ?? true;
      return !isPhysical;
    } else if (Platform.isIOS) {
      final isPhysical = deviceInfo['isPhysicalDevice'] as bool? ?? true;
      return !isPhysical;
    }
    
    return false;
  }
  
  /// Get device security level
  static Future<Map<String, dynamic>> getDeviceSecurityInfo() async {
    final deviceInfo = await getDeviceInfo();
    final isEmulator = await DeviceService.isEmulator();
    final isIntegrityValid = await validateDeviceIntegrity();
    
    return {
      'deviceId': await getDeviceId(),
      'fingerprint': await getDeviceFingerprint(),
      'isEmulator': isEmulator,
      'isIntegrityValid': isIntegrityValid,
      'platform': deviceInfo['platform'],
      'registeredAt': deviceInfo['registeredAt'],
      'securityLevel': _calculateSecurityLevel(isEmulator, isIntegrityValid),
    };
  }
  
  static String _calculateSecurityLevel(bool isEmulator, bool isIntegrityValid) {
    if (isEmulator) return 'LOW';
    if (!isIntegrityValid) return 'MEDIUM';
    return 'HIGH';
  }
}