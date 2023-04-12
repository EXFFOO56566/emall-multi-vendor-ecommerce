import 'dart:convert';
import 'dart:developer';

import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/services/Network.dart';
import 'package:EMallApp/utils/InternetUtils.dart';


class MaintenanceController {

  //------------------------ Checking maintenance  -----------------------------------------//
  static Future<MyResponse> checkMaintenance() async {
    String maintenanceUrl = ApiUtil.MAIN_API_URL + ApiUtil.MAINTENANCE;

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.get(maintenanceUrl,
          headers: ApiUtil.getHeader(requestType: RequestType.Post));

      log(response.body);
      MyResponse myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        myResponse.success = true;
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      log(e.toString());
      //If any server error...
      return MyResponse.makeServerProblemError();
    }
  }
}