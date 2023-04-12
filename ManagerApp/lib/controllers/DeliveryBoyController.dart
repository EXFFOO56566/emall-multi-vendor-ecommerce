import 'dart:convert';

import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/models/DeliveryBoy.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/utils/InternetUtils.dart';

import 'AuthController.dart';
import 'package:http/http.dart' as http;

class DeliveryBoyController {



  //------------------------ Get  Delivery Boy  -----------------------------------------//
  static Future<MyResponse<Map<String,List<DeliveryBoy>>>> getDeliveryBoys() async {

    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.DELIVERY_BOYS + ApiUtil.GET_ALL ;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<Map<String,List<DeliveryBoy>>> myResponse = MyResponse(response.statusCode);

      Map<String,List<DeliveryBoy>> responseData = {};
      dynamic data = json.decode(response.body);
      if (response.statusCode == 200) {
        myResponse.success = true;
        responseData[DeliveryBoy.SHOP_DELIVERY_BOYS_KEY] = DeliveryBoy.getListFromJson(data[DeliveryBoy.SHOP_DELIVERY_BOYS_KEY]);
        responseData[DeliveryBoy.ALLOCATED_DELIVERY_BOYS_KEY] = DeliveryBoy.getListFromJson(data[DeliveryBoy.ALLOCATED_DELIVERY_BOYS_KEY]);
        responseData[DeliveryBoy.UNALLOCATED_DELIVERY_BOYS_KEY] = DeliveryBoy.getListFromJson(data[DeliveryBoy.UNALLOCATED_DELIVERY_BOYS_KEY]);
        myResponse.data = responseData;
      } else {
        Map<String, dynamic> data = json.decode(response.body);

        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<Map<String,List<DeliveryBoy>>>();
    }
  }

  //------------------------ Manage Delivery Boy -----------------------------------------//
  static Future<MyResponse> manageDeliveryBoy(int deliveryBoyId) async {

    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.DELIVERY_BOYS + deliveryBoyId.toString() + "/" + ApiUtil.MANAGE ;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.post(url, headers: headers);
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
      //If any server error...
      return MyResponse.makeServerProblemError();
    }
  }

}
