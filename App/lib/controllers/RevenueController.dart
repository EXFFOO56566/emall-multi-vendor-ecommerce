import 'dart:convert';

import 'package:DeliveryBoyApp/api/api_util.dart';
import 'package:DeliveryBoyApp/models/MyResponse.dart';
import 'package:DeliveryBoyApp/models/Revenue.dart';
import 'package:DeliveryBoyApp/utils/InternetUtils.dart';

import 'AuthController.dart';
import 'package:http/http.dart' as http;

class RevenueController {


  /*-----------------   Get all time revenue for currently login user    ----------------------*/

  static Future<MyResponse<List<Revenue>>> getRevenue() async {
    //Get Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.REVENUES;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Revenue>>();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<List<Revenue>> myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        myResponse.success = true;
        myResponse.data = Revenue.getListFromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      return MyResponse.makeServerProblemError<List<Revenue>>();
    }
  }


  static double calculateTotalRevenue(List<Revenue> list){
    double total = 0;
    for(Revenue revenue in list){
      total+=revenue.revenue;
    }
    return total;
  }

  static int calculateTotalOrder(List<Revenue> list){
      return list.length;
  }

  /*-----------------   Getting revenue data for last 7 days for graph   ----------------------*/

  static List<RevenueData> getRevenueData(List<Revenue> list){
    List<RevenueData> revenueData = [];
    DateTime today = DateTime.now();
    for(int i=6;i>=0;i--){
      DateTime dateTime = today.subtract(Duration(days: i));
      double singleRevenue = countRevenueForSpecificDate(list,dateTime);
      revenueData.add(RevenueData(singleRevenue,dateTime));
    }
    return revenueData;
  }

  static double countRevenueForSpecificDate(List<Revenue> list,DateTime dateTime){

    double totalRevenue =0;

    for(Revenue revenue in list){
      if(revenue.createdAt.day == dateTime.day && revenue.createdAt.month == dateTime.month && revenue.createdAt.year == dateTime.year){
        totalRevenue+=revenue.revenue;

      }
    }
    return totalRevenue;
  }


  /*-----------------   Getting total orders for last 7 days for graph  ----------------------*/

  static List<OrderData> getOrderData(List<Revenue> list){
    List<OrderData> orderData = [];
    DateTime today = DateTime.now();
    for(int i=6;i>=0;i--){
      DateTime dateTime = today.subtract(Duration(days: i));
      int singleOrder = countOrderForSpecificDate(list,dateTime);
      orderData.add(OrderData(singleOrder,dateTime));
    }
    return orderData;
  }

  static int countOrderForSpecificDate(List<Revenue> list,DateTime dateTime){
    int totalOrder =0;
    for(Revenue revenue in list){

      if(revenue.createdAt.day == dateTime.day && revenue.createdAt.month == dateTime.month && revenue.createdAt.year == dateTime.year){
        totalOrder++;
      }
    }
    return totalOrder;
  }

}

class RevenueData{
  double revenue;
  DateTime dateTime;
  RevenueData(this.revenue, this.dateTime);
}

class OrderData{
  int order;
  DateTime dateTime;
  OrderData(this.order, this.dateTime);
}