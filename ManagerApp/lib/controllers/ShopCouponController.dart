import 'dart:convert';

import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/models/Coupon.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/utils/InternetUtils.dart';

import 'AuthController.dart';
import 'package:http/http.dart' as http;

class ShopCouponController {



  //------------------------ Get  Delivery Boy  -----------------------------------------//
  static Future<MyResponse<Map<String,List<Coupon>>>> getAllCoupon() async {

    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.COUPONS;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<Map<String,List<Coupon>>> myResponse = MyResponse(response.statusCode);

      Map<String,List<Coupon>> responseData = {};
      dynamic data = json.decode(response.body);
      if (response.statusCode == 200) {
        myResponse.success = true;
        responseData[Coupon.SELECTED_COUPONS_KEY] = Coupon.getListFromJson(data[Coupon.SELECTED_COUPONS_KEY]);
        responseData[Coupon.UNSELECTED_COUPONS_KEY] = Coupon.getListFromJson(data[Coupon.UNSELECTED_COUPONS_KEY]);
        myResponse.data = responseData;
      } else {
        Map<String, dynamic> data = json.decode(response.body);

        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<Map<String,List<Coupon>>>();
    }
  }

  //------------------------ Get  Delivery Boy  -----------------------------------------//
  static Future<MyResponse> manageCoupon(int couponId) async {

    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.COUPONS + couponId.toString();
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);


    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    String body = json.encode(ApiUtil.getPatchRequestBody());


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
