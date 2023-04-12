import 'dart:convert';

import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/models/Shop.dart';
import 'package:ManagerApp/utils/InternetUtils.dart';
import 'package:ManagerApp/utils/TextUtils.dart';

import 'AuthController.dart';
import 'package:http/http.dart' as http;

class ShopRequestController {



  //------------------------ Get shop -----------------------------------------//
  static Future<MyResponse<Map<String,dynamic>>> getRequestedShop() async {

    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.SHOP_REQUESTS;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<Map<String,dynamic>> myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        myResponse.success = true;
        Map<String,dynamic> body = json.decode(response.body);
        Map<String,dynamic> data = {};
        if(TextUtils.parseBool(body['requested'].toString())){
          data['requested'] = true;
          data['shop'] = Shop.fromJson(body['shop']);
        }else{
          data['requested'] = false;
          data['shops'] = Shop.getListFromJson(body['shops']);
        }
        myResponse.data = data;
      } else {
        Map<String, dynamic> data = json.decode(response.body);

        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<Map<String,dynamic>>();
    }
  }



  //------------------------ Request shop -----------------------------------------//
  static Future<MyResponse<Map<String,dynamic>>> requestShop(int shopId) async {

    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.SHOP_REQUESTS;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    Map data = {};
    data['shop_id'] = shopId;

    String body = json.encode(data);

    try {
      http.Response response = await http.post(url, headers: headers,body:body);
       MyResponse<Map<String,dynamic>> myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        myResponse.success = true;
        myResponse.data = json.decode(response.body);
      } else {
        Map<String, dynamic> data = json.decode(response.body);

        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<Map<String,dynamic>>();
    }
  }

 //------------------------ Request shop -----------------------------------------//
  static Future<MyResponse<Map<String,dynamic>>> deleteRequestShop() async {

    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.SHOP_REQUESTS;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    Map data = ApiUtil.getDeleteRequestBody();

    String body = json.encode(data);

    try {
      http.Response response = await http.post(url, headers: headers,body:body);
      MyResponse<Map<String,dynamic>> myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        myResponse.success = true;
        myResponse.data = json.decode(response.body);
      } else {
        Map<String, dynamic> data = json.decode(response.body);

        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<Map<String,dynamic>>();
    }
  }



}
