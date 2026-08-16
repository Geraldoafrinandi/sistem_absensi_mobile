import 'package:device_info_plus/device_info_plus.dart';

class DeviceHelper {
  static Future<String> getUniqueDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    
    try {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; 
    } catch (e) {
      return 'unknown_android_device'; 
    }
  }
}