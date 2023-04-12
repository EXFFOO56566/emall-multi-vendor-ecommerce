



class DistanceUtils{
  static String formatDistance(double distance){
    if(distance>1000){
      distance = distance/1000;
      return (distance/1000).toStringAsFixed(distance.truncateToDouble() == distance ? 0 : 1) + " KM";
    }else{
      return distance.floor().toString() + " Meter";
    }
  }
}