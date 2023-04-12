import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/controllers/ShopCouponController.dart';
import 'package:ManagerApp/models/Coupon.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/services/AppLocalizations.dart';
import 'package:ManagerApp/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../AppTheme.dart';
import '../AppThemeNotifier.dart';
import 'LoadingScreens.dart';

class EditCouponsScreen extends StatefulWidget {

  @override
  _EditCouponsScreenState createState() =>
      _EditCouponsScreenState();
}

class _EditCouponsScreenState
    extends State<EditCouponsScreen> {
  //ThemeData
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = new GlobalKey<ScaffoldMessengerState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Other Variables
  bool isInProgress = false;
  Map<String, List<Coupon>> coupons;

  @override
  void initState() {
    super.initState();
    _getAllCoupon();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getAllCoupon() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Map<String, List<Coupon>>> myResponse =
        await ShopCouponController.getAllCoupon();
    if (myResponse.success) {
      coupons = myResponse.data;
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  _manageCoupon(int couponId) async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse =
        await ShopCouponController.manageCoupon(couponId);

    if (myResponse.success) {
      _refresh();
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  Future<void> _refresh() async {
    _getAllCoupon();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return MaterialApp(
          scaffoldMessengerKey: _scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(themeType),
            home: Scaffold(
                key: _scaffoldKey,
                backgroundColor: customAppTheme.bgLayer1,
                appBar: AppBar(
                  leading: InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Icon(MdiIcons.chevronLeft,size: MySize.size20,color: themeData.colorScheme.onBackground,),
                  ),
                  elevation: 0,
                  title: Text(
                    Translator.translate("manage_coupons"),
                    style: AppTheme.getTextStyle(themeData.textTheme.headline6,
                        color: themeData.colorScheme.onBackground,
                        fontWeight: 600),
                  ),
                  centerTitle: true,
                ),
                body: RefreshIndicator(
                    onRefresh: _refresh,
                    backgroundColor: customAppTheme.bgLayer1,
                    color: themeData.colorScheme.primary,
                    key: _refreshIndicatorKey,
                    child: Column(
                      children: [
                        Container(
                          height: MySize.size3,
                          child: isInProgress
                              ? LinearProgressIndicator(
                                  minHeight: MySize.size3,
                                )
                              : Container(
                                  height: MySize.size3,
                                ),
                        ),
                        Expanded(child: _buildBody())
                      ],
                    ))));
      },
    );
  }

  _buildBody() {
    if (coupons != null) {
      return _getCouponsView(coupons);
    } else if (isInProgress) {
      return LoadingScreens.getOrderLoadingScreen(
          context, themeData, customAppTheme);
    } else {
      return Center(
        child: Text(Translator.translate("loading")),
      );
    }
  }

  _getCouponsView(Map<String, List<Coupon>> coupons) {
    List<Widget> views = [];

    views.add(Text(
      Translator.translate("my_coupons"),
      style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
          color: themeData.colorScheme.onBackground,
          fontWeight: 700),
    ));

    views.add(SizedBox(height: MySize.size8,));


    for (Coupon coupon
        in coupons[Coupon.SELECTED_COUPONS_KEY]) {
      views.add(
          _singleCoupon(coupon,Coupon.SELECTED_COUPONS_KEY));
    }

    if(coupons[Coupon.SELECTED_COUPONS_KEY].length==0){
      views.add(Center(
        child: Text(
          Translator.translate("you_have_not_any_selected_coupons"),
          style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
              color: themeData.colorScheme.onBackground,
              fontWeight: 600,
              muted: true),
        ),
      ));
    }

    views.add(Divider());

    views.add(SizedBox(height: MySize.size16,));


    views.add(Text(
      Translator.translate("other_coupons"),
      style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
          color: themeData.colorScheme.onBackground,
          fontWeight: 700),
    ));

    views.add(SizedBox(height: MySize.size8,));


    for (Coupon coupon
    in coupons[Coupon.UNSELECTED_COUPONS_KEY]) {
      views.add(
          _singleCoupon(coupon, Coupon.UNSELECTED_COUPONS_KEY));
    }


    if(coupons[Coupon.UNSELECTED_COUPONS_KEY].length==0){
      views.add(Center(
        child: Text(
          Translator.translate("there_is_no_any_other_coupons"),
          style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
              color: themeData.colorScheme.onBackground,
              fontWeight: 600,
              muted: true),
        ),
      ));
    }




    return Container(
      child: ListView(
        padding: Spacing.all(16),
        children: views,
      ),
    );
  }

  _singleCoupon(Coupon coupon, String type) {
    Widget actionWidget;
    if (type == Coupon.UNSELECTED_COUPONS_KEY) {
      actionWidget = ElevatedButton(
          style: ButtonStyle(
              padding: MaterialStateProperty.all(Spacing.xy(24,12)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius:  BorderRadius.circular(8),
              ))
          ),
          onPressed: () {
            _manageCoupon(coupon.id);
            },
          child: Text(
            Translator.translate("add"),
            style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                color:  themeData.colorScheme.onPrimary),
          ));
    } else {
      actionWidget = ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(customAppTheme.colorError),
              padding: MaterialStateProperty.all(Spacing.xy(24,12)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius:  BorderRadius.circular(8),
              ))
          ),
          onPressed: () {
            _manageCoupon(coupon.id);
          },
          child: Text(
            Translator.translate("delete"),
            style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                color: customAppTheme.onError),
          ));
    }

    return Container(
      margin: Spacing.vertical(8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("#"+coupon.code,style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,color: themeData.colorScheme.onBackground,fontWeight: 600,),),
                Text(coupon.description,style: AppTheme.getTextStyle(themeData.textTheme.caption,color: themeData.colorScheme.onBackground,fontWeight: 500,),)
              ],
            ),
          ),
          actionWidget
        ],
      ),
    );
  }

  void showMessage({String message = "Something wrong", Duration duration}) {
    if (duration == null) {
      duration = Duration(seconds: 3);
    }
    _scaffoldMessengerKey.currentState.showSnackBar(
      SnackBar(
        duration: duration,
        content: Text(message,
            style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                letterSpacing: 0.4, color: themeData.colorScheme.onPrimary)),
        backgroundColor: themeData.colorScheme.primary,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }
}
