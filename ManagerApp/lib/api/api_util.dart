
import 'package:ManagerApp/controllers/AuthController.dart';
import 'package:ManagerApp/views/MaintenanceScreen.dart';
import 'package:ManagerApp/views/auth/LoginScreen.dart';
import 'package:ManagerApp/views/shop/ShopRequestScreen.dart';
import 'package:flutter/material.dart';

enum RequestType { Post, Get, PostWithAuth, GetWithAuth }

class ApiUtil {


  /*----------------- Fpr development server -----------------*/
  static const String IP_ADDRESS = "192.168.1.15";

  static const String PORT = "8000";
  static const String API_VERSION = "v1";
  static const String USER_MODE = "manager/";

  //static const String BASE_URL = "http://" + IP_ADDRESS + ":" + PORT + "/";




  /*------------ For Production server ----------------------*/

  //TODO: Change base URL as per your server
  static const String BASE_URL = "http://emall.coderthemes.com/";
  //static const String BASE_URL = "https://siapboss.id/";


  static const String MAIN_API_URL_DEV =
      BASE_URL + "api/" + API_VERSION + "/" + USER_MODE;
  static const String MAIN_API_URL_PRODUCTION =  BASE_URL + "api/" + API_VERSION + "/" + USER_MODE;


  //Main Url for production and testing
  static const String MAIN_API_URL = MAIN_API_URL_DEV;

  // ------------------ Status Code ------------------------//
  static const int SUCCESS_CODE = 200;
  static const int ERROR_CODE = 400;
  static const int UNAUTHORIZED_CODE = 401;


  //Custom codes
  static const int INTERNET_NOT_AVAILABLE_CODE = 500;
  static const int SERVER_ERROR_CODE = 501;
  static const int MAINTENANCE_CODE = 503;
  static const int NO_SHOP = 504;


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
  static Map<String, dynamic> getPatchRequestBody() {
    return {'_method': 'PATCH'};
  }

  static Map<String, dynamic> getDeleteRequestBody() {
    return {'_method': 'DELETE'};
  }

  //------------------- API LINKS ------------------------//

  //Maintenance
  static const String MAINTENANCE = "maintenance/";

  //App Data
  static const String APP_DATA = "app_data/";

  //User
  static const String MANAGER = "manager/";

  //Auth
  static const String AUTH_LOGIN = "login";
  static const String AUTH_REGISTER = "register";

  //Update
  static const String UPDATE_PROFILE = "update_profile/";

  //Forgot password
  static const String FORGOT_PASSWORD = "password/email";

  //Dashboard
  static const String DASHBOARD = "dashboard/";

  //Product
  static const String PRODUCTS = "products/";

  //Product Images
  static const String PRODUCT_IMAGES = "productImages/";

  //cart
  static const String CARTS = "carts/";

  //user address
  static const String ADDRESSES = "addresses/";

  //category
  static const String CATEGORIES = "categories/";

  //order
  static const String ORDERS = "orders/";

  //Favorite
  static const String FAVORITES = "favorites/";

  //Review
  static const String REVIEWS = "reviews/";

  //Coupon
  static const String COUPONS = "coupons/";

  //shop
  static const String SHOPS = "shops/";

  //Get all
  static const String GET_ALL = "get_all/";

  //Manage
  static const String MANAGE = "manage/";

  //receipt
  static const String RECEIPT = "receipt/";

  //Images
  static const String IMAGES = "images/";

  //shop reviews
  static const String SHOP_REVIEWS = "shop-reviews/";

  //shop reviews
  static const String PRODUCT_REVIEWS = "product-reviews/";

  //Delivery boys
  static const String DELIVERY_BOYS = "delivery_boys/";

  //Assign
  static const String ASSIGN = "assign/";

  //Transaction
  static const String TRANSACTIONS = "transactions/";


  //Shop Request
  static const String SHOP_REQUESTS = "shop_requests/";


  //delivery boy reviews
  static const String DELIVERY_BOY_REVIEWS = "delivery-boy-reviews/";



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
      case NO_SHOP:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ShopRequestScreen(),
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
