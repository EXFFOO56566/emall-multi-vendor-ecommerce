import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api_util.dart';
import '../models/MyResponse.dart';
import '../models/Shop.dart';
import '../utils/InternetUtils.dart';
import 'AuthController.dart';

class ShopController {
  //------------------------ Get single shop -----------------------------------------//
  static Future<MyResponse<Shop>> getMyShop() async {
    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.SHOP;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<Shop>();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<Shop> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode)) {
        myResponse.success = true;
        if (response.body.isEmpty)
          myResponse.data = null;
        else
          myResponse.data = Shop.fromJson(json.decode(response.body));
      } else {
        myResponse.success = false;
        myResponse.setError(json.decode(response.body));
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError<Shop>();
    }
  }
}
