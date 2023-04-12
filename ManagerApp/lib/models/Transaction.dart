
import 'package:ManagerApp/models/DeliveryBoy.dart';
import 'package:ManagerApp/models/Order.dart';
import 'package:ManagerApp/models/OrderPayment.dart';
import 'package:ManagerApp/utils/TextUtils.dart';

import 'Shop.dart';

class Transaction {
  int id,orderId,orderPaymentId,shopId,deliveryBoyId;
  bool captured,refunded,success;
  double adminRevenue,adminToShop,adminToDeliveryBoy,shopToAdmin,deliveryBoyToAdmin,total;
  Order order;
  OrderPayment orderPayment;
  Shop shop;
  DeliveryBoy deliveryBoy;


  Transaction(
      this.id,
      this.orderId,
      this.orderPaymentId,
      this.shopId,
      this.deliveryBoyId,
      this.captured,
      this.refunded,
      this.success,
      this.adminRevenue,
      this.adminToShop,
      this.adminToDeliveryBoy,
      this.shopToAdmin,
      this.deliveryBoyToAdmin,
      this.total,
      this.order,
      this.orderPayment,
      this.shop,
      this.deliveryBoy);

  static Transaction fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    int orderId = int.parse(jsonObject['order_id'].toString());
    int orderPaymentId = int.parse(jsonObject['order_payment_id'].toString());
    int shopId = int.parse(jsonObject['shop_id'].toString());
    int deliveryBoyId;
    if(jsonObject['delivery_boy_id']!=null)
      deliveryBoyId = int.parse(jsonObject['delivery_boy_id'].toString());

    bool captured = TextUtils.parseBool(jsonObject['captured'].toString());
    bool refunded = TextUtils.parseBool(jsonObject['refunded'].toString());
    bool success = TextUtils.parseBool(jsonObject['success'].toString());

    double adminRevenue = double.parse(jsonObject['admin_revenue'].toString());
    double adminToShop = double.parse(jsonObject['admin_to_shop'].toString());
    double adminToDeliveryBoy = double.parse(jsonObject['admin_to_delivery_boy'].toString());
    double shopToAdmin = double.parse(jsonObject['shop_to_admin'].toString());
    double deliveryBoyToAdmin = double.parse(jsonObject['delivery_boy_to_admin'].toString());
    double total = double.parse(jsonObject['total'].toString());


    Order order;
    if(jsonObject['order']!=null)
      order = Order.fromJson(jsonObject['order']);


    Shop shop;
    if (jsonObject['shop'] != null) shop = Shop.fromJson(jsonObject['shop']);


    OrderPayment orderPayment;
    if (jsonObject['order_payment'] != null)
      orderPayment = OrderPayment.fromJson(jsonObject['order_payment']);

    DeliveryBoy deliveryBoy;
    if (jsonObject['delivery_boy'] != null)
      deliveryBoy = DeliveryBoy.fromJson(jsonObject['delivery_boy']);



    return Transaction(id, orderId, orderPaymentId, shopId, deliveryBoyId, captured, refunded, success, adminRevenue, adminToShop, adminToDeliveryBoy, shopToAdmin, deliveryBoyToAdmin, total, order, orderPayment, shop, deliveryBoy);
  }

  static List<Transaction> getListFromJson(List<dynamic> jsonArray) {
    List<Transaction> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Transaction.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'Transaction{id: $id, orderId: $orderId, orderPaymentId: $orderPaymentId, shopId: $shopId, deliveryBoyId: $deliveryBoyId, captured: $captured, refunded: $refunded, success: $success, adminRevenue: $adminRevenue, adminToShop: $adminToShop, adminToDeliveryBoy: $adminToDeliveryBoy, shopToAdmin: $shopToAdmin, deliveryBoyToAdmin: $deliveryBoyToAdmin, total: $total, order: $order, orderPayment: $orderPayment, shop: $shop, deliveryBoy: $deliveryBoy}';
  }

}
