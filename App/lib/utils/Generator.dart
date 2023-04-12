import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../AppTheme.dart';

class Generator {

  static const Color starColor = Color(0xfff9c700);


  static String convertDateTimeToText(DateTime dateTime,{bool showSecond=true,bool showDate=true,bool showTime=true}){

    String date = dateTime.day <10 ? "0"+ dateTime.day.toString() : dateTime.day.toString();
    String month = dateTime.month <10 ? "0"+ dateTime.month.toString() : dateTime.month.toString();
    String year = dateTime.year.toString();

    String hour = dateTime.hour.toString();
    String minute = dateTime.minute < 10 ? "0"+dateTime.minute.toString() : dateTime.minute.toString();
    String second="";
    if(showSecond) second = dateTime.second < 10 ? "0"+dateTime.second.toString() : dateTime.second.toString();

    String meridian = dateTime.hour<12 ?  "AM" : "PM";

    if(showDate && !showTime){
      return date + "-" + month +"-"+year;
    }else if(!showDate && showTime){
      return hour + ":" + minute + (showSecond?":":"") + second+" "+meridian;
    }
    return date + "-" + month +"-"+year +" " +hour + ":" + minute + (showSecond?":":"") + second+" "+meridian;
  }

  static Widget buildRatingStar(
      {double rating = 5,
        Color activeColor = starColor,
        Color inactiveColor = Colors.black,
        double size = 16,
        double spacing = 0,
        bool inactiveStarFilled = false,
        bool showInactive = true}) {
    int ratingCount = rating.floor();
    bool isHalf = (ratingCount != rating);
    List<Widget> _stars = [];
    for (int i = 0; i < 5; i++) {
      if (i < ratingCount) {
        _stars.add(Icon(
          MdiIcons.star,
          color: activeColor,
          size: size,
        ));

        _stars.add(SizedBox(width: spacing));
      } else {
        if (isHalf) {
          isHalf = false;
          _stars.add(Icon(
            MdiIcons.starHalfFull,
            color: activeColor,
            size: size,
          ));
        } else if (showInactive) {
          _stars.add(Icon(
            inactiveStarFilled ? MdiIcons.star : MdiIcons.starOutline,
            color: inactiveColor,
            size: size,
          ));
        }
        _stars.add(SizedBox(width: spacing));
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: _stars);
  }


  static List<Color> getColorByRating(CustomAppTheme customAppTheme){
    return [
      customAppTheme.colorError,                    //For 0 star color
      customAppTheme.colorError,                    //For 1 star color
      customAppTheme.colorError.withAlpha(200),     //For 2 star color
      CustomAppTheme.starColor,                     //For 3 star color
      customAppTheme.colorSuccess.withAlpha(200),   //For 4 star color
      customAppTheme.colorSuccess                   //For 5 star color
    ];
  }

}
