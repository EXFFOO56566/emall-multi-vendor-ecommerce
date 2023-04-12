
import 'package:DeliveryBoyApp/utils/TextUtils.dart';

class Coupon{

  int id;
  String code;
  String description;
  int offer;
  bool isActive;
  DateTime startedAt,expiredAt;

  Coupon(this.id, this.code, this.description, this.offer, this.isActive,
      this.startedAt, this.expiredAt);


  static Coupon fromJson(Map<String, dynamic> jsonObject) {


    int id = int.parse(jsonObject['id'].toString());
    String code = jsonObject['code'].toString();
    String description = jsonObject['description'].toString();
    int offer = int.parse(jsonObject['offer'].toString());
    bool isActivate = TextUtils.parseBool(jsonObject['is_active'].toString());
    DateTime startedAt = DateTime.parse(jsonObject['started_at'].toString());
    DateTime expiredAt = DateTime.parse(jsonObject['expired_at'].toString());
    return Coupon(id, code, description, offer, isActivate, startedAt, expiredAt);
  }

  static List<Coupon> getListFromJson(List<dynamic> jsonArray) {
    List<Coupon> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Coupon.fromJson(jsonArray[i]));
    }
    return list;
  }

}