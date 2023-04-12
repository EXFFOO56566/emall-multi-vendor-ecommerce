

import 'package:ManagerApp/services/AppLocalizations.dart';

import 'Cart.dart';
import 'Coupon.dart';
import 'DeliveryBoy.dart';
import 'OrderPayment.dart';
import 'Shop.dart';
import 'User.dart';
import 'UserAddress.dart';

class Order {
  int id, couponId, addressId, shopId, orderPaymentId, userId, orderType;
  int status, otp;
  double order, tax, deliveryFee, total, couponDiscount,shopRevenue,adminRevenue;
  List<Cart> carts;
  DateTime createdAt;
  Shop shop;
  User user;
  Coupon coupon;
  UserAddress address;
  OrderPayment orderPayment;
  DeliveryBoy deliveryBoy;

  Order(
      this.id,
      this.couponId,
      this.addressId,
      this.shopId,
      this.orderPaymentId,
      this.userId,
      this.orderType,
      this.status,
      this.otp,
      this.order,
      this.tax,
      this.deliveryFee,
      this.total,
      this.couponDiscount,
      this.shopRevenue,this.adminRevenue,
      this.carts,
      this.createdAt,
      this.shop,
      this.user,
      this.coupon,
      this.address,
      this.orderPayment,
      this.deliveryBoy);

  static Order fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    int orderType = int.parse(jsonObject['order_type'].toString());
    int addressId;
    if (jsonObject['address_id'] != null)
      addressId = int.parse(jsonObject['address_id'].toString());
    int shopId = int.parse(jsonObject['shop_id'].toString());
    int orderPaymentId = int.parse(jsonObject['order_payment_id'].toString());
    int userId = int.parse(jsonObject['user_id'].toString());

    int status = int.parse(jsonObject['status'].toString());
    int otp = int.parse(jsonObject['otp'].toString());
    double order = double.parse(jsonObject['order'].toString());
    double tax = double.parse(jsonObject['tax'].toString());
    double deliveryFee = double.parse(jsonObject['delivery_fee'].toString());
    double total = double.parse(jsonObject['total'].toString());
    double adminRevenue = double.parse(jsonObject['admin_revenue'].toString());
    double shopRevenue = double.parse(jsonObject['shop_revenue'].toString());
    double couponDiscount;
    if(jsonObject['coupon_discount']!=null)
    couponDiscount =
        double.parse(jsonObject['coupon_discount'].toString());
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

    User user;
    if (jsonObject['user'] != null) user = User.fromJson(jsonObject['user']);

    DateTime createdAt = DateTime.parse(jsonObject['created_at'].toString());

    OrderPayment orderPayment;
    if (jsonObject['order_payment'] != null)
      orderPayment = OrderPayment.fromJson(jsonObject['order_payment']);

    DeliveryBoy deliveryBoy;
    if (jsonObject['delivery_boy'] != null)
      deliveryBoy = DeliveryBoy.fromJson(jsonObject['delivery_boy']);

    return Order(id, couponId, addressId, shopId, orderPaymentId, userId, orderType, status, otp, order, tax, deliveryFee, total, couponDiscount, shopRevenue, adminRevenue, carts, createdAt, shop, user, coupon, address, orderPayment, deliveryBoy);
  }

  static List<Order> getListFromJson(List<dynamic> jsonArray) {
    List<Order> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Order.fromJson(jsonArray[i]));
    }
    return list;
  }

  static const int ORDER_CANCELLED_BY_SHOP = -2;
  static const int ORDER_CANCELLED_BY_USER = -1;
  static const int ORDER_WAIT_FOR_PAYMENT = 0;
  static const int ORDER_WAIT_FOR_CONFIRMATION = 1;
  static const int ORDER_ACCEPTED = 2;
  static const int ORDER_READY_FOR_DELIVERY = 3;
  static const int ORDER_ON_THE_WAY = 4;
  static const int ORDER_DELIVERED = 5;
  static const int ORDER_REVIEWED = 6;

  static const int ORDER_TYPE_PICKUP = 1;
  static const int ORDER_TYPE_DELIVERY = 2;

  static const int ORDER_PT_COD = 1;
  static const int ORDER_PT_RAZORPAY = 2;
  static const int ORDER_PT_PAYSTACK = 3;

  static String getTextFromOrderStatus(int status, int orderType) {
    if (Order.isPickUpOrder(orderType)) {
      switch (status) {
        case ORDER_CANCELLED_BY_SHOP:
          return Translator.translate("order_cancelled_by_shop");
        case ORDER_CANCELLED_BY_USER:
          return Translator.translate("order_cancelled_by_you");
        case ORDER_WAIT_FOR_PAYMENT:
          return Translator.translate("wait_for_payment");
        case ORDER_WAIT_FOR_CONFIRMATION:
          return Translator.translate("wait_for_confirmation");
        case ORDER_ACCEPTED:
          return Translator.translate("accepted_and_packaging");
        case ORDER_READY_FOR_DELIVERY:
          return Translator.translate("pickup_order_from_shop");
        case ORDER_ON_THE_WAY:
        case ORDER_DELIVERED:
          return Translator.translate("delivered");
        case ORDER_REVIEWED:
          return Translator.translate("reviewed");
        default:
          return getTextFromOrderStatus(ORDER_TYPE_PICKUP, orderType);
      }
    } else {
      switch (status) {
        case ORDER_CANCELLED_BY_SHOP:
          return Translator.translate("order_cancelled_by_shop");
        case ORDER_CANCELLED_BY_USER:
          return Translator.translate("order_cancelled_by_you");
          case ORDER_WAIT_FOR_PAYMENT:
          return Translator.translate("wait_for_payment");
        case ORDER_WAIT_FOR_CONFIRMATION:
          return Translator.translate("wait_for_confirmation");
        case ORDER_ACCEPTED:
          return Translator.translate("accepted_and_packaging");
        case ORDER_READY_FOR_DELIVERY:
          return Translator.translate("wait_for_delivery_boy");
        case ORDER_ON_THE_WAY:
          return Translator.translate("on_the_way");
        case ORDER_DELIVERED:
          return Translator.translate("delivered");
        case ORDER_REVIEWED:
          return Translator.translate("reviewed");
        default:
          return getTextFromOrderStatus(ORDER_TYPE_PICKUP, orderType);
      }
    }
  }

  static String getTextFromOrderType(int type) {
    switch (type) {
      case ORDER_TYPE_PICKUP:
        return Translator.translate("self_pickup");
      case ORDER_TYPE_DELIVERY:
        return Translator.translate("home_delivery");
    }
    return getTextFromOrderType(ORDER_TYPE_PICKUP);
  }



  static bool checkWaitForPayment(int status) {
    return status == ORDER_WAIT_FOR_PAYMENT;
  }

  static bool checkStatusDelivered(int status) {
    return status == ORDER_DELIVERED;
  }

  static bool checkStatusReviewed(int status) {
    return status == ORDER_REVIEWED;
  }

  static bool isSuccessfulDelivered(int status){
    return status>=ORDER_DELIVERED;
  }

  static String getPaymentTypeText(int paymentType) {
    switch (paymentType) {
      case ORDER_PT_COD:
        return Translator.translate("cash_on_delivery");
      case ORDER_PT_RAZORPAY:
        return Translator.translate("razorpay");
      case ORDER_PT_PAYSTACK:
        return Translator.translate("paystack");
    }
    return getPaymentTypeText(ORDER_PT_COD);
  }

  static bool isPaymentByCOD(int paymentType) {
    return paymentType == ORDER_PT_COD;
  }

  static bool isOrderCompleteWithReview(int status) {
    return status == ORDER_REVIEWED;
  }

  static double getDiscountFromCoupon(double originalOrderPrice, int offer) {
    return originalOrderPrice * offer / 100;
  }

  static bool isPickUpOrder(int orderType) {
    return orderType == ORDER_TYPE_PICKUP;
  }

  static bool isCancellable(int orderStatus) {
    return orderStatus < ORDER_ACCEPTED;
  }

  static bool isCancelled(int orderStatus){
    return orderStatus==ORDER_CANCELLED_BY_USER || orderStatus==ORDER_CANCELLED_BY_SHOP;
  }

  static String getOrderPaymentTypeText(int paymentType){
    switch(paymentType){
      case ORDER_PT_COD:
        return Translator.translate("cash_on_delivery");
      case ORDER_PT_RAZORPAY:
        return "Razorpay";
        case ORDER_PT_PAYSTACK:
        return "Paystack";
    }
    return getOrderPaymentTypeText(ORDER_PT_COD);
  }

  @override
  String toString() {
    return 'Order{id: $id, couponId: $couponId, addressId: $addressId, shopId: $shopId, orderPaymentId: $orderPaymentId, orderType: $orderType, status: $status, order: $order, tax: $tax, deliveryFee: $deliveryFee, total: $total, couponDiscount: $couponDiscount, createdAt: $createdAt, shop: $shop, coupon: $coupon, address: $address, orderPayment: $orderPayment, deliveryBoy: $deliveryBoy}';
  }
}
