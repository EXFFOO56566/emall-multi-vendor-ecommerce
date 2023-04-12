
import 'package:ManagerApp/utils/TextUtils.dart';

class DeliveryBoy{


  // ignore: non_constant_identifier_names
  static final String SHOP_DELIVERY_BOYS_KEY = "shop_delivery_boys";
  // ignore: non_constant_identifier_names
  static final String ALLOCATED_DELIVERY_BOYS_KEY = "allocated_delivery_boys";
  // ignore: non_constant_identifier_names
  static final String UNALLOCATED_DELIVERY_BOYS_KEY = "unallocated_delivery_boys";

  int id;
  String name,email,avatarUrl,mobile;
  double latitude,longitude;
  double farFromShop;


  DeliveryBoy(this.id, this.name, this.email, this.avatarUrl, this.mobile,
      this.latitude, this.longitude,this.farFromShop);

  static DeliveryBoy fromJson(Map<String, dynamic> jsonObject) {

    int id = int.parse(jsonObject['id'].toString());
    String name = jsonObject['name'].toString();
    String email = jsonObject['email'].toString();
    String avatarUrl = TextUtils.getImageUrl(jsonObject['avatar_url'].toString());
    String mobile = jsonObject['mobile'].toString();

    double latitude;
    if(jsonObject['latitude']!=null)
      latitude = double.parse(jsonObject['latitude'].toString()) ;
    double longitude;
    if(jsonObject['longitude']!=null)
      longitude = double.parse(jsonObject['longitude'].toString()) ;

    double farFromShop;
    if(jsonObject['far_from_shop']!=null)
      farFromShop = double.parse(jsonObject['far_from_shop'].toString()) ;

    return DeliveryBoy(id, name, email, avatarUrl, mobile, latitude, longitude,farFromShop);
  }

  static List<DeliveryBoy> getListFromJson(List<dynamic> jsonArray) {
    List<DeliveryBoy> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(DeliveryBoy.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'DeliveryBoy{id: $id, name: $name, email: $email, avatarUrl: $avatarUrl, mobile: $mobile, latitude: $latitude, longitude: $longitude}';
  }
}