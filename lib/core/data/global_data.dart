import 'package:flutter/foundation.dart'; 
import 'package:geolocator/geolocator.dart';

class GlobalData {
  static Position? currentPosition;

  static double? latitude;
  static double? longitude;
  static double? accuracy;

 static ValueNotifier<bool> isGpsReady = ValueNotifier<bool>(false);

  static void updatePosition(Position position) {
    currentPosition = position;
    latitude = position.latitude;
    longitude = position.longitude;
    accuracy = position.accuracy;

    isGpsReady.value = true;
  }

  static void clearPosition() {
    currentPosition = null;
    latitude = null;
    longitude = null;
    accuracy = null;
    isGpsReady.value = false;
  }
}