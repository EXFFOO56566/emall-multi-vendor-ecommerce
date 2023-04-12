import 'package:DeliveryBoyApp/models/Order.dart';
import 'package:DeliveryBoyApp/models/Shop.dart';
class Transaction {

  int id;
  int orderId;
  int shopId;

  double adminToDeliveryBoy,deliveryBoyToAdmin;

  Order order;
  Shop shop;


  Transaction(this.id, this.orderId, this.shopId, this.adminToDeliveryBoy,
      this.deliveryBoyToAdmin, this.order, this.shop);

  static Transaction fromJson(Map<String, dynamic> jsonObject) {


    int id = int.parse(jsonObject['id'].toString());
    int orderId = int.parse(jsonObject['order_id'].toString());
    int shopId = int.parse(jsonObject['shop_id'].toString());

    double adminToDeliveryBoy = double.parse(jsonObject['admin_to_delivery_boy'].toString());
    double deliveryBoyToAdmin = double.parse(jsonObject['delivery_boy_to_admin'].toString());

    Order order;
    if(jsonObject['order']!=null){
      order = Order.fromJson(jsonObject['order']);
    }

    Shop shop;
    if(jsonObject['shop']!=null){
      shop = Shop.fromJson(jsonObject['shop']);
    }

   return Transaction(id, orderId, shopId, adminToDeliveryBoy, deliveryBoyToAdmin, order, shop);
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
    return 'Transaction{id: $id, orderId: $orderId, shopId: $shopId, adminToDeliveryBoy: $adminToDeliveryBoy, deliveryBoyToAdmin: $deliveryBoyToAdmin, order: $order, shop: $shop}';
  }
}