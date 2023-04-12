import 'dart:convert';
import 'dart:io';

import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/models/Shop.dart';
import 'package:ManagerApp/utils/InternetUtils.dart';

import 'AuthController.dart';
import 'package:http/http.dart' as http;

class ShopController {



  //------------------------ Get shop -----------------------------------------//
  static Future<MyResponse<Shop>> getShop() async {

    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.SHOPS;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<Shop> myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        myResponse.success = true;
        myResponse.data = Shop.fromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);

        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<Shop>();
    }
  }

   //------------------------ Update shop -----------------------------------------//
  static Future<MyResponse> updateShop({int id,String name,String email,String mobile,String description,String address,String longitude,String latitude,String tax,String adminCommission,String minimumDeliveryCharge,String deliveryChargeMultiplier ,String deliveryRange, bool open,bool availableForDelivery, File imageFile}) async {


    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.SHOPS + id.toString();
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    Map data = ApiUtil.getPatchRequestBody();


    if(imageFile!=null) {
      final bytes = imageFile.readAsBytesSync();
      String img64 = base64Encode(bytes);
      data['image'] = img64;
    }

    data['name'] = name;
    data['email'] = email;
    data['mobile'] = mobile;
    data['description'] = description;
    data['address'] = address;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['default_tax'] = tax;
    data['minimum_delivery_charge'] = minimumDeliveryCharge;
    data['delivery_cost_multiplier'] = deliveryChargeMultiplier;
    data['delivery_range'] = deliveryRange;
    data['admin_commission'] = adminCommission;
    if(open)
      data['open']= true;

    if(availableForDelivery)
      data['available_for_delivery'] = true;

    //Encode
    String body = json.encode(data);

    try {
      http.Response response = await http.post(url, headers: headers,body: body);

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
