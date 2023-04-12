import 'package:DeliveryBoyApp/utils/TextUtils.dart';

class DeliveryBoy{

  int id;
  bool isOffline = false;
  String name,email,token,avatarUrl,mobile;


  DeliveryBoy(this.name, this.email, this.token,
      this.avatarUrl, this.mobile,this.isOffline);


  static DeliveryBoy fromJson(Map<String, dynamic> jsonObject){


    String name = jsonObject['name'];
    String email = jsonObject['email'];
    String avatarUrl = jsonObject['avatar_url'];
    String mobile = jsonObject['mobile'];
    bool isOffline = TextUtils.parseBool(jsonObject['is_offline']);

    return DeliveryBoy(name, email, null, avatarUrl, mobile, isOffline);
  }

  @override
  String toString() {
    return 'DeliveryBoy{id: $id, isOffline: $isOffline, name: $name, email: $email, token: $token, avatarUrl: $avatarUrl, mobile: $mobile}';
  }

  String getAvatarUrl(){
    return TextUtils.getImageUrl(avatarUrl);
  }
}