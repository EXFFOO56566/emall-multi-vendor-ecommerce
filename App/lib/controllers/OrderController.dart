import 'dart:convert';
import 'package:DeliveryBoyApp/api/api_util.dart';
import 'package:DeliveryBoyApp/models/MyResponse.dart';
import 'package:DeliveryBoyApp/models/Order.dart';
import 'package:DeliveryBoyApp/utils/InternetUtils.dart';
import 'AuthController.dart';
import 'package:http/http.dart' as http;

class OrderController {


  /*-----------------   Get all order for currently login user  ----------------------*/
  static Future<MyResponse<List<Order>>> getAllOrder() async {

    //Get Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ORDERS;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Order>>();
    }

    try {
      http.Response response = await http.get(url, headers: headers);

      MyResponse<List<Order>> myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        myResponse.success = true;
        myResponse.data = Order.getListFromJson(json.decode(response.body));
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


  /*-----------------   update order    ----------------------*/
  // Order Status
  // current location in latitude and longitude

  static Future<MyResponse> updateOrder(int orderId,
      {int status = -1, double latitude = -1, double longitude = -1,int otp}) async {
    //Get Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ORDERS + orderId.toString();
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Body data
    Map data = {};
    if (status != -1) {
      data['status'] = status;
    }
    if (latitude != -1) {
      data['latitude'] = latitude;
    }
    if (longitude != -1) {
      data['longitude'] = longitude;
    }

    if(otp!=null){
      data['otp']=otp;
    }


    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.post(
          url, headers: headers, body: body);
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
      return MyResponse.makeServerProblemError();
    }
  }


  /*-----------------   Get single order from order id    ----------------------*/

  static Future<MyResponse<Order>> getSingleOrder(int id) async {

    //Get Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ORDERS + id.toString();
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<Order>();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<Order> myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        myResponse.success = true;
        myResponse.data = Order.fromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      return MyResponse.makeServerProblemError<Order>();
    }

  }
}
