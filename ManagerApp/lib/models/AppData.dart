

import 'Manager.dart';

class AppData{


  final int BUILD_VERSION = 140;
  final Manager manager;


  int minBuildVersion;

  AppData(this.minBuildVersion,this.manager);

  static AppData fromJson(Map<String, dynamic> jsonObject){
    int minBuildVersion = int.parse(jsonObject['min_build_version'].toString());

    Manager manager;
    if(jsonObject['manager']!=null)
      manager = Manager.fromJson(jsonObject['manager']);

    return AppData(minBuildVersion,manager);
  }

  bool isAppUpdated(){
    return BUILD_VERSION >= minBuildVersion;
  }

  @override
  String toString() {
    return 'AppData{BUILD_VERSION: $BUILD_VERSION, minBuildVersion: $minBuildVersion}';
  }
}