
import 'package:DeliveryBoyApp/controllers/AuthController.dart';
import 'package:DeliveryBoyApp/views/MaintenanceScreen.dart';
import 'package:DeliveryBoyApp/views/auth/LoginScreen.dart';
import 'package:flutter/material.dart';

enum RequestType { Post, Get, PostWithAuth, GetWithAuth }

class ApiUtil {


  /*----------------- Fpr development server -----------------*/
  static const String IP_ADDRESS = "192.168.1.15";

  static const String PORT = "8000";
  static const String API_VERSION = "v1";
  static const String USER_MODE = "delivery-boy/";

  //static const String BASE_URL = "http://" + IP_ADDRESS + ":" + PORT + "/";






  /*------------ For Production server ----------------------*/

  //TODO: Change base URL as per your server
  static const String BASE_URL = "http://emall.coderthemes.com/";

  static const String MAIN_API_URL_DEV =
      BASE_URL + "api/" + API_VERSION + "/" + USER_MODE;

  static const String MAIN_API_URL_PRODUCTION = BASE_URL + "api/" + API_VERSION + "/" + USER_MODE;

  //Final Url for testing and production
  static const String MAIN_API_URL = MAIN_API_URL_PRODUCTION;

  // ------------------ Status Code ------------------------//
  static const int SUCCESS_CODE = 200;
  static const int ERROR_CODE = 400;
  static const int UNAUTHORIZED_CODE = 401;

  //Custom codes
  static const int INTERNET_NOT_AVAILABLE_CODE = 500;
  static const int SERVER_ERROR_CODE = 501;
  static const int MAINTENANCE_CODE = 503;

  //------------------ Header ------------------------------//

  static Map<String, String> getHeader(
      {RequestType requestType = RequestType.Get, String token = ""}) {
    switch (requestType) {
      case RequestType.Post:
        return {
          "Accept": "application/json",
          "Content-type": "application/json"
        };
      case RequestType.Get:
        return {
          "Accept": "application/json",
        };
      case RequestType.PostWithAuth:
        return {
          "Accept": "application/json",
          "Content-type": "application/json",
          "Authorization": "Bearer " + token
        };
      case RequestType.GetWithAuth:
        return {
          "Accept": "application/json",
          "Authorization": "Bearer " + token
        };
    }
    //Not reachable
    return {"Accept": "application/json"};
  }

  // ----------------------  Body --------------------------//
  static Map<String, String> getPatchRequestBody() {
    return {'_method': 'PATCH'};
  }

  //------------------- API Prefix ------------------------//

  //Maintenance
  static const String MAINTENANCE = "maintenance/";

  //Maintenance
  static const String APP_DATA = "app_data/";

  //DeliveryBoy
  static const String DELIVERY_BOY = "delivery_boy/";

  //Auth
  static const String AUTH_LOGIN = "login/";
  static const String AUTH_REGISTER = "register/";
  static const String UPDATE_PROFILE = "update_profile/";

  //forgot password
  static const String FORGOT_PASSWORD = "password/email";

  //change status
  static const String CHANGE_STATUS = "change_status/";

  //order
  static const String ORDERS = "orders/";

  //Revenue
  static const String REVENUES = "revenues/";

  //Transactions
  static const String Transactions = "transactions/";

  //shop
  static const String SHOP = "shop/";

  //receipt
  static const String RECEIPT = "receipt/";



  //Reviews
  static const String REVIEWS = "reviews/";

  //----------------- Redirects ----------------------------------//
  static checkRedirectNavigation(BuildContext context, int statusCode) async {
    switch (statusCode) {
      case SUCCESS_CODE:
      case ERROR_CODE:
        return;
      case UNAUTHORIZED_CODE:
        await AuthController.logoutUser();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => LoginScreen(),
          ),
          (route) => false,
        );
        return;
      case MAINTENANCE_CODE:
      case SERVER_ERROR_CODE:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MaintenanceScreen(),
          ),
          (route) => false,
        );
        return;
    }
    return;
  }

  static bool isResponseSuccess(int responseCode){
    return responseCode>=200 && responseCode<300;
  }

}
