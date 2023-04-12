import 'package:DeliveryBoyApp/models/DeliveryBoyReview.dart';
import 'package:flutter/material.dart';

import 'Cart.dart';
import 'Coupon.dart';
import 'OrderPayment.dart';
import 'Shop.dart';
import 'UserAddress.dart';

class Order{
  int id, couponId, addressId, shopId, orderPaymentId;
  int status,otp;
  double order, tax, deliveryFee, total;
  List<Cart> carts;
  DateTime createdAt;
  Shop shop;
  Coupon coupon;
  UserAddress address;
  OrderPayment orderPayment;
  DeliveryBoyReview deliveryBoyReview;



  Order(
      this.id,
      this.couponId,
      this.addressId,
      this.shopId,
      this.orderPaymentId,
      this.status,
      this.otp,
      this.order,
      this.tax,
      this.deliveryFee,
      this.total,
      this.carts,
      this.createdAt,
      this.shop,
      this.coupon,
      this.address,
      this.orderPayment,this.deliveryBoyReview);

  static Order fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    int addressId = int.parse(jsonObject['address_id'].toString());
    int shopId = int.parse(jsonObject['shop_id'].toString());
    int orderPaymentId = int.parse(jsonObject['order_payment_id'].toString());

    int status = int.parse(jsonObject['status'].toString());
    int otp = int.parse(jsonObject['otp'].toString());
    double order = double.parse(jsonObject['order'].toString());
    double tax = double.parse(jsonObject['tax'].toString());
    double deliveryFee = double.parse(jsonObject['delivery_fee'].toString());
    double total = double.parse(jsonObject['total'].toString());
    List<Cart> carts = Cart.getListFromJson(jsonObject['carts']);

    int couponId;
    if (jsonObject['coupon_id'] != null)
      couponId = int.parse(jsonObject['coupon_id'].toString());

    Coupon coupon;
    if (jsonObject['coupon'] != null)
      coupon = Coupon.fromJson(jsonObject['coupon']);

    UserAddress address;
    if (jsonObject['address'] != null)
      address = UserAddress.fromJson(jsonObject['address']);

    Shop shop;
    if (jsonObject['shop'] != null) shop = Shop.fromJson(jsonObject['shop']);

    DateTime createdAt = DateTime.parse(jsonObject['created_at'].toString());

    OrderPayment orderPayment;
    if (jsonObject['order_payment']!=null)
      orderPayment = OrderPayment.fromJson(jsonObject['order_payment']);

    DeliveryBoyReview deliveryBoyReview;
    if(jsonObject['delivery_boy_review']!=null)
      deliveryBoyReview = DeliveryBoyReview.fromJson(jsonObject['delivery_boy_review']);


    return Order(
        id,
        couponId,
        addressId,
        shopId,
        orderPaymentId,
        status,
        otp,
        order,
        tax,
        deliveryFee,
        total,
        carts,
        createdAt,
        shop,
        coupon,
        address,
        orderPayment,deliveryBoyReview);
  }

  static List<Order> getListFromJson(List<dynamic> jsonArray) {
    List<Order> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Order.fromJson(jsonArray[i]));
    }
    return list;
  }


  static String getTextFromOrderStatus(int status){
    switch(status){
      case 1:
        return "Wait for confirmation";
      case 2:
        return "Accepted";
      case 3:
        return "Pick up order from shop";
      case 4:
        return "On the way";
      case 5:
        return "Delivered";
      case 6:
        return "Reviewed";
      default:
        return getTextFromOrderStatus(1);
    }
  }

  static Color getColorFromOrderStatus(int status){
    switch(status){
      case 1:
        return Color.fromRGBO(255, 170, 85,1.0);
      case 2:
        return Color.fromRGBO(90, 149, 154,1.0);
      case 3:
        return Color.fromRGBO(255, 170, 85,1.0);
      case 4:
        return Color.fromRGBO(34,187,51,1.0);
      case 5:
        return Color.fromRGBO(34,187,51,1.0);
      default:
        return getColorFromOrderStatus(1);
    }
  }

  static bool checkStatusDelivered(int status){
    return status==5;

  }

  static bool checkStatusReviewed(int status){
    return status==6;
  }

  static bool checkIsActiveOrder(int status){
    return status>2 && status<5;
  }


  static String getPaymentTypeText(int paymentType){
    switch(paymentType){
      case 1:
        return "Cash on Delivery";
      case 2:
        return "Razorpay";
      case 3:
        return "Paystack";
    }
    return getPaymentTypeText(1);
  }


  static double getDiscountFromCoupon(double originalOrderPrice, int offer){
    return originalOrderPrice*offer/100;
  }

  static String convertCurrencyToString(double num){
    return num.toString().replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
  }




}