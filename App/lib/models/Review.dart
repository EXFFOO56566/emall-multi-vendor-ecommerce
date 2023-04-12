class Review{

  int id,rating,orderId,productId,userId;
  String review;


  Review(this.id, this.rating, this.orderId, this.productId, this.userId,
      this.review);

  static Review fromJson(Map<String, dynamic> jsonObject) {

    int id = int.parse(jsonObject['id'].toString());
    int rating = int.parse(jsonObject['rating'].toString());
    int productId = int.parse(jsonObject['product_id'].toString());
    int orderId = int.parse(jsonObject['order_id'].toString());
    int userId = int.parse(jsonObject['user_id'].toString());
    String review = jsonObject['review'].toString();

    return Review(id, rating, orderId, productId, userId, review);
  }

  static List<Review> getListFromJson(List<dynamic> jsonArray) {
    List<Review> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Review.fromJson(jsonArray[i]));
    }
    return list;
  }



}