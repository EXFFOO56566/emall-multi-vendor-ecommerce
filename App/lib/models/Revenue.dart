class Revenue{

  int id,orderId,shopId,deliveryBoyId,productCount;
  double revenue;
  DateTime createdAt;

  Revenue(this.id, this.orderId, this.shopId, this.deliveryBoyId,
      this.productCount, this.revenue, this.createdAt);


  static Revenue fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    int orderId = int.parse(jsonObject['order_id'].toString());
    int shopId = int.parse(jsonObject['shop_id'].toString());
    int deliveryBoyId = int.parse(jsonObject['delivery_boy_id'].toString());
    int productCount = int.parse(jsonObject['products_count'].toString());
    double revenue = double.parse(jsonObject['revenue'].toString());
    DateTime createdAt = DateTime.parse(jsonObject['created_at'].toString());

    return Revenue(id, orderId, shopId, deliveryBoyId, productCount, revenue, createdAt);

  }

  static List<Revenue> getListFromJson(List<dynamic> jsonArray) {
    List<Revenue> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Revenue.fromJson(jsonArray[i]));
    }
    return list;
  }

}