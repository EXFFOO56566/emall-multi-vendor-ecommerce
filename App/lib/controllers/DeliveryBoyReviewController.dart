import 'dart:convert';
import 'package:DeliveryBoyApp/api/api_util.dart';
import 'package:DeliveryBoyApp/models/DeliveryBoyReview.dart';
import 'package:DeliveryBoyApp/models/MyResponse.dart';
import 'package:DeliveryBoyApp/models/Order.dart';
import 'package:DeliveryBoyApp/utils/InternetUtils.dart';
import 'AuthController.dart';
import 'package:http/http.dart' as http;

class DeliveryBoyReviewController {


  /*-----------------   Get all order for currently login user  ----------------------*/
  static Future<MyResponse<List<DeliveryBoyReview>>> getAllReviews() async {

    //Get Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.REVIEWS;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Order>>();
    }

    try {
      http.Response response = await http.get(url, headers: headers);

      MyResponse<List<DeliveryBoyReview>> myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        myResponse.success = true;
        myResponse.data = DeliveryBoyReview.getListFromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      return MyResponse.makeServerProblemError<List<Order>>();

    }
  }
}
