import 'dart:convert';
import 'dart:io';
import 'package:DeliveryBoyApp/AppTheme.dart';
import 'package:DeliveryBoyApp/api/api_util.dart';
import 'package:DeliveryBoyApp/models/DeliveryBoy.dart';
import 'package:DeliveryBoyApp/models/MyResponse.dart';
import 'package:DeliveryBoyApp/services/PushNotificationsManager.dart';
import 'package:DeliveryBoyApp/utils/InternetUtils.dart';
import 'package:DeliveryBoyApp/utils/SizeConfig.dart';
import 'package:DeliveryBoyApp/utils/TextUtils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class

AuthController {


  /*-----------------   Log In     ----------------------*/

  static Future<MyResponse> loginUser(String email, String password) async {

    //Get FCM
    PushNotificationsManager pushNotificationsManager = PushNotificationsManager();
    await pushNotificationsManager.init();
    String fcmToken = await pushNotificationsManager.getToken();

    String loginUrl = ApiUtil.MAIN_API_URL + ApiUtil.AUTH_LOGIN;

    //Body data
    Map data = {'email': email, 'password': password, 'fcm_token':fcmToken};

    //Encode
    String body = json.encode(data);


    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try{
    Response response = await http.post(loginUrl,
        headers: ApiUtil.getHeader(requestType: RequestType.Post), body: body);

    MyResponse myResponse = MyResponse(response.statusCode);
    if (response.statusCode == 200) {
      SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

      Map<String, dynamic> data = json.decode(response.body);
      Map<String, dynamic> user = data['delivery_boy'];
      String token = data['token'];

      await saveUser(user);
      await sharedPreferences.setString('token', token);

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



  /*-----------------   Register     ----------------------*/

  static Future<MyResponse> registerUser(String name, String email,
      String password) async {
    //Get FCM
    PushNotificationsManager pushNotificationsManager = PushNotificationsManager();
    await pushNotificationsManager.init();
    String fcmToken = await pushNotificationsManager.getToken();

    String registerUrl = ApiUtil.MAIN_API_URL + ApiUtil.AUTH_REGISTER;

    //Body date
    Map data = {
      'name': name,
      'email': email,
      'password': password,
      'fcm_token': fcmToken
    };

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      Response response = await http.post(registerUrl,
          headers: ApiUtil.getHeader(requestType: RequestType.Post),
          body: body);

      MyResponse myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

        Map<String, dynamic> data = json.decode(response.body);
        Map<String, dynamic> user = data['delivery_boy'];
        String token = data['token'];

        await saveUser(user);
        await sharedPreferences.setString('token', token);

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


  /*-----------------   Forgot Password     ----------------------*/

  static forgotPassword(String email) async {
    String url = ApiUtil.MAIN_API_URL + ApiUtil.FORGOT_PASSWORD;

    //Body date
    Map data = {
      'email': email
    };

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      Response response = await http.post(url,
          headers: ApiUtil.getHeader(requestType: RequestType.Post),
          body: body);



      MyResponse myResponse = MyResponse(response.statusCode);

      if (response.statusCode==200) {
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


  /*-----------------   Log Out    ----------------------*/

  static Future<bool> logoutUser() async {

    //Remove FCM
    PushNotificationsManager pushNotificationsManager = PushNotificationsManager();
    await pushNotificationsManager.removeFCM();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    await sharedPreferences.remove('name');
    await sharedPreferences.remove('email');
    await sharedPreferences.remove('avatar_url');
    await sharedPreferences.remove('is_offline');
    await sharedPreferences.remove('mobile');
    await sharedPreferences.remove('email');
    await sharedPreferences.remove('token');

    return true;
  }



  /*-----------------   Save user in cache   ----------------------*/

  static saveUser(Map<String, dynamic> user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('name', user['name']);
    await sharedPreferences.setString('email', user['email']);
    await sharedPreferences.setString('avatar_url', user['avatar_url']);
    await sharedPreferences.setBool('is_offline', TextUtils.parseBool(user['is_offline']));
    await sharedPreferences.setString('mobile', user['mobile']);
  }

  static saveUserFromDeliveryBoy(DeliveryBoy deliveryBoy) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('name', deliveryBoy.name);
    await sharedPreferences.setString('email', deliveryBoy.email);
    await sharedPreferences.setString('avatar_url', deliveryBoy.avatarUrl);
    await sharedPreferences.setBool('is_offline', deliveryBoy.isOffline);
    await sharedPreferences.setString('mobile', deliveryBoy.mobile);
  }


  /*-----------------   Get user from cache     ----------------------*/

  static Future<DeliveryBoy> getUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String name = sharedPreferences.getString('name');
    String email = sharedPreferences.getString('email');
    String token = sharedPreferences.getString('token');
    String avatarUrl = sharedPreferences.getString('avatar_url');
    String mobile = sharedPreferences.getString('mobile');
    bool isOffline = sharedPreferences.getBool('is_offline');

    return DeliveryBoy(name, email, token, avatarUrl, mobile,isOffline);
  }


  /*-----------------   Update user     ----------------------*/

  static Future<MyResponse> updateUser(String mobile,String password,File imageFile) async {

    //Get Token
    String token = await AuthController.getApiToken();
    String registerUrl = ApiUtil.MAIN_API_URL + ApiUtil.UPDATE_PROFILE;

    Map data = {};
    if(mobile.isNotEmpty)
      data['mobile'] = mobile;

    if(password.isNotEmpty)
      data['password']=password;

    if(imageFile!=null){
      final bytes = imageFile.readAsBytesSync();
      String img64 =base64Encode(bytes);
      data['avatar_image'] = img64;
    }


    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      Response response = await http.post(registerUrl,
        headers: ApiUtil.getHeader(requestType: RequestType.PostWithAuth,token: token),
        body: body,);


      MyResponse myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        await saveUser(json.decode(response.body)['delivery_boy']);
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


  /*-----------------   Check user login or not     ----------------------*/

  static Future<bool> isLoginUser() async {
    String token = await getApiToken();
    if (token == null) {
      return false;
    }
    return true;
  }

  /*-----------------   Get user login token     ----------------------*/

  static Future<String> getApiToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("token");
  }


  /*-----------------   Change status (online/offline)     ----------------------*/

  static Future<MyResponse> changeStatus(bool status) async {

    String token = await getApiToken();
    String registerUrl = ApiUtil.MAIN_API_URL + ApiUtil.CHANGE_STATUS;

    //Body date
    Map data = {
      'is_offline': TextUtils.parseBool(status),
    };

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<DeliveryBoy>();
    }

    try {
      Response response = await http.post(registerUrl,
          headers: ApiUtil.getHeader(requestType: RequestType.PostWithAuth,token: token),
          body: body);

      MyResponse myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        await saveUser(json.decode(response.body)['delivery_boy']);
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

  static Widget notice(ThemeData themeData){
    return Container(
      margin: Spacing.fromLTRB(24, 36, 24, 24),
      child: RichText(
        text: TextSpan(
            children: [
              TextSpan(
                  text: "Note: ",
                  style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,color: themeData.colorScheme.primary,fontWeight: 600)
              ),
              TextSpan(
                  text: "After testing please logout, because there is many user testing with same IDs so it can be possible that you can get unnecessary notifications",
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,color: themeData.colorScheme.onBackground,fontWeight: 500,letterSpacing: 0)
              ),
            ]
        ),
      ),
    );
  }

}
