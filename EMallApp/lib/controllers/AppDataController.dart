
import 'dart:convert';

import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/models/AppData.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/services/Network.dart';
import 'package:EMallApp/utils/InternetUtils.dart';
import 'AuthController.dart';

class AppDataController {

  //-------------------- Add user address --------------------------------//
  static Future<MyResponse<AppData>> getAppData() async {
    //Get Api Token

    String token = await AuthController.getApiToken();
    if (token!=null) {
      //Get Api Token


      String url = ApiUtil.MAIN_API_URL + ApiUtil.APP_DATA + ApiUtil.USER;
      Map<String, String> headers =
      ApiUtil.getHeader(requestType: RequestType.GetWithAuth,token: token);

      //Check Internet
      bool isConnected = await InternetUtils.checkConnection();
      if (!isConnected) {
        return MyResponse.makeInternetConnectionError<AppData>();
      }

      try {
        NetworkResponse response = await Network.get(
            url, headers: headers);

        MyResponse<AppData> myResponse = MyResponse(response.statusCode);
        if (response.statusCode == 200) {
          myResponse.success = true;
          myResponse.data = AppData.fromJson(json.decode(response.body));
        } else {
          Map<String, dynamic> data = json.decode(response.body);
          myResponse.success = false;
          myResponse.setError(data);
        }
        return myResponse;
      } catch (e) {
        //If any server error...
        return MyResponse.makeServerProblemError<AppData>();
      }
    }
    else {
      String url = ApiUtil.MAIN_API_URL + ApiUtil.APP_DATA ;
      Map<String, String> headers =
      ApiUtil.getHeader(requestType: RequestType.Get);

      //Check Internet
      bool isConnected = await InternetUtils.checkConnection();
      if (!isConnected) {
        return MyResponse.makeInternetConnectionError<AppData>();
      }

      try {
        NetworkResponse response = await Network.get(
            url, headers: headers);


        MyResponse<AppData> myResponse = MyResponse(response.statusCode);
        if (response.statusCode == 200) {
          myResponse.success = true;
          myResponse.data = AppData.fromJson(json.decode(response.body));
        } else {
          Map<String, dynamic> data = json.decode(response.body);
          myResponse.success = false;
          myResponse.setError(data);
        }
        return myResponse;
      } catch (e) {
        //If any server error...
        return MyResponse.makeServerProblemError<AppData>();
      }
    }
  }
}

