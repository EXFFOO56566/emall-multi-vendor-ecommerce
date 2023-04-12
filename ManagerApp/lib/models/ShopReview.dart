
import 'User.dart';

class ShopReview{

  int id,rating,userId,shopId;
  String review;
  DateTime createdAt;

  User user;


  ShopReview(this.id, this.rating, this.userId, this.shopId, this.review,
      this.createdAt, this.user);

  static ShopReview fromJson(Map<String, dynamic> jsonObject) {

    int id = int.parse(jsonObject['id'].toString());
    int rating = int.parse(jsonObject['rating'].toString());
    int shopId = int.parse(jsonObject['shop_id'].toString());
    int userId = int.parse(jsonObject['user_id'].toString());

    DateTime createdAt = DateTime.parse(jsonObject['created_at'].toString());

    User user;
    if(jsonObject['user']!=null)
      user = User.fromJson(jsonObject['user']);

    String review;
    if(jsonObject['review']!=null)
      review = jsonObject['review'].toString();



    return ShopReview(id, rating, userId, shopId, review, createdAt, user);
  }

  static List<ShopReview> getListFromJson(List<dynamic> jsonArray) {
    List<ShopReview> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(ShopReview.fromJson(jsonArray[i]));
    }
    return list;
  }



}