import 'dart:convert';
import 'dart:developer';

import 'package:DeliveryBoyApp/api/api_util.dart';
import 'package:DeliveryBoyApp/models/MyResponse.dart';
import 'package:DeliveryBoyApp/utils/InternetUtils.dart';
import 'package:http/http.dart';

import 'package:http/http.dart' as http;

class MaintenanceController {


  /*-----------------   Check for maintenance mode     ----------------------*/

  static Future<MyResponse> checkMaintenance() async {
    String maintenanceUrl = ApiUtil.MAIN_API_URL + ApiUtil.MAINTENANCE;

    log("1");
    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      log("2");
      Response response = await http.get(maintenanceUrl,
          headers: ApiUtil.getHeader(requestType: RequestType.Get));

      log("3");
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
    }catch(e){
      log(e.toString());
      return MyResponse.makeServerProblemError();
    }
  }

}