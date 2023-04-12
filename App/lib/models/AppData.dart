

import 'package:DeliveryBoyApp/models/DeliveryBoy.dart';

class AppData{


  final int BUILD_VERSION = 140;


  int minBuildVersion;
  DeliveryBoy deliveryBoy;

  AppData(this.minBuildVersion,this.deliveryBoy);

  static AppData fromJson(Map<String, dynamic> jsonObject){
    int minBuildVersion = int.parse(jsonObject['min_build_version'].toString());

    DeliveryBoy deliveryBoy;
    if(jsonObject['delivery_boy']!=null){
      deliveryBoy = DeliveryBoy.fromJson(jsonObject['delivery_boy']);
    }

    return AppData(minBuildVersion,deliveryBoy);
  }

  bool isAppUpdated(){
    return BUILD_VERSION >= minBuildVersion;
  }

  @override
  String toString() {
    return 'AppData{BUILD_VERSION: $BUILD_VERSION, minBuildVersion: $minBuildVersion}';
  }
}