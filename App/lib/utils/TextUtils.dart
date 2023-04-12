import 'package:DeliveryBoyApp/api/api_util.dart';

class TextUtils {

  static String getImageUrl(String url,
      {bool withoutStoragePrefix = true, bool withoutIPPrefix = true}) {
    if (withoutIPPrefix && withoutStoragePrefix) {
      return ApiUtil.BASE_URL + "storage/" + url;
    }
    return url;
  }


  static bool parseBool(dynamic text) {
    if (text.toString().compareTo("1") == 0 ||
        text.toString().compareTo("true") == 0) {
      return true;
    }
    return false;
  }


  static String getDayName(int dayNumber) {
    switch (dayNumber) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      default:
        return "Sunday";
    }
  }

  static String getShortDayName(int dayNumber) {
    switch (dayNumber) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      default:
        return "Sun";
    }
  }

  static String doubleToString(double value){
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
  }


}