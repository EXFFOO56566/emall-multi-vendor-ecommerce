import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/models/Product.dart';
import 'package:ManagerApp/utils/InternetUtils.dart';

import 'AuthController.dart';
import 'package:http/http.dart' as http;

class ProductController {



  //------------------------ Get all products -----------------------------------------//
  static Future<MyResponse<List<Product>>> getAllProduct() async {

    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.PRODUCTS;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<List<Product>> myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        myResponse.success = true;
        myResponse.data = Product.getListFromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);

        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<List<Product>>();
    }
  }



  static Future<MyResponse> createProduct({String name,String description,String offer,int categoryId,String items}) async {

    //Get API Token
    String token = await AuthController.getApiToken();

    log(items);
    String url = ApiUtil.MAIN_API_URL + ApiUtil.PRODUCTS;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);



    //Body Data
    Map data = {'name': name, 'description': description, 'offer': offer, 'category':categoryId,'items':items};

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.post(url, headers: headers,body: body);

      log(response.body);

      MyResponse myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        myResponse.success = true;
        //myResponse.data = Product.getListFromJson(json.decode(response.body));
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

  static Future<MyResponse> editProduct({int id,String name,String description,String offer,int categoryId,String items}) async {

    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.PRODUCTS + id.toString();
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);


    Map data = ApiUtil.getPatchRequestBody();
    data['name'] = name;
    data['description'] = description;
    data['offer'] = offer;
    data['category'] = categoryId;
    data['items'] = items;


    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.post(url, headers: headers,body: body);
      log(response.body);
      MyResponse myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        myResponse.success = true;
        //myResponse.data = Product.getListFromJson(json.decode(response.body));
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

  static Future<MyResponse<Product>> getProductImages(int productId) async{

    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.PRODUCTS + productId.toString();
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<Product> myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        myResponse.success = true;
        myResponse.data = Product.fromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);

        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<Product>();
    }
  }

  static Future<MyResponse> uploadImage(int productId,File imageFile) async {

    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.PRODUCTS + productId.toString() +"/" + ApiUtil.IMAGES;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    Map data = {};
    if(imageFile!=null){
      final bytes = imageFile.readAsBytesSync();
      String img64 =base64Encode(bytes);
      data['image'] = img64;
    }

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

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

  static Future<MyResponse> deleteImage(int productImageId) async {

    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.PRODUCT_IMAGES + productImageId.toString();
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    Map data = ApiUtil.getDeleteRequestBody();

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

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


  static Future<MyResponse<Product>> getProduct(int productId) async{

    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.PRODUCTS + productId.toString();
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<Product> myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        myResponse.success = true;
        myResponse.data = Product.fromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);

        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<Product>();
    }
  }



}
