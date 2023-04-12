import 'dart:convert';

import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/models/ShopReview.dart';
import 'package:ManagerApp/utils/InternetUtils.dart';

import 'AuthController.dart';
import 'package:http/http.dart' as http;

class ShopReviewController {



  //------------------------ Get shop -----------------------------------------//
  static Future<MyResponse<List<ShopReview>>> getAllReviews() async {

    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.SHOPS  + ApiUtil.REVIEWS;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<List<ShopReview>> myResponse = MyResponse<List<ShopReview>>(response.statusCode);

      if (response.statusCode == 200) {
        myResponse.success = true;
        myResponse.data = ShopReview.getListFromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);

        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<List<ShopReview>>();
    }
  }

}
