import 'package:DeliveryBoyApp/controllers/ShopController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../AppTheme.dart';
import '../AppThemeNotifier.dart';
import '../api/api_util.dart';
import '../api/currency_api.dart';
import '../models/MyResponse.dart';
import '../models/Shop.dart';
import '../services/AppLocalizations.dart';
import '../utils/SizeConfig.dart';
import '../utils/UrlUtils.dart';

class ShopScreen extends StatefulWidget {
  final int shopId;

  const ShopScreen({Key key, this.shopId}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  //ThemeData
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = new GlobalKey<ScaffoldMessengerState>();


  //Other variables
  Shop shop;
  bool isInProgress = false;

  @override
  void initState() {
    super.initState();
    _getShopData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getShopData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Shop> myResponse =
        await ShopController.getMyShop();
    if (myResponse.success) {
      shop = myResponse.data;
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
        builder: (BuildContext context, AppThemeNotifier value, Widget child) {
      themeData = AppTheme.getThemeFromThemeMode(value.themeMode());
      customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
      return MaterialApp(
        scaffoldMessengerKey: _scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
          home: Scaffold(
              key: _scaffoldKey,

              appBar: AppBar(
                backgroundColor: customAppTheme.bgLayer1,
                elevation: 0,
                leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(MdiIcons.chevronLeft),
                ),
                centerTitle: true,
                title: Text(
                    shop != null ? shop.name : Translator.translate("loading"),
                    style: AppTheme.getTextStyle(
                        themeData.appBarTheme.textTheme.headline6,
                        fontWeight: 600)),
              ),
              backgroundColor: customAppTheme.bgLayer1,
              body: Container(
                child: ListView(
                  padding: Spacing.zero,
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
                    _buildBody()
                  ],
                ),
              )));
    });
  }

  _buildBody() {
    if (shop != null) {
      return _buildShop();
    } else if(isInProgress) {
      return Center(
        child: Container(
          margin: EdgeInsets.only(top: MySize.size24),
          child: Text(
            Translator.translate('loading') + "...",
            style: AppTheme.getTextStyle(
                themeData.textTheme.bodyText1,
                color: themeData.colorScheme.onBackground,
                fontWeight: 600,
                letterSpacing: 0.2),
          ),
        ),
      );
    }
      else{
        return Container(
          child: Column(
            children: [
              Container(
                child: Image(
                  image: AssetImage('./assets/images/illustration/sad.png'),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: MySize.size24),
                child: Text(
                  Translator.translate('you_have_not_any_shop_yet'),
                  style: AppTheme.getTextStyle(
                      themeData.textTheme.bodyText1,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 600,
                      letterSpacing: 0.2),
                ),
              ),
            ],
          ),
        );
      }
  }

  _buildShop() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Center(
              child: Image.network(
                shop.imageUrl,
                width: MySize.safeWidth,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: Spacing.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: shop.availableForDelivery
                                    ? themeData.colorScheme.primary
                                    .withAlpha(150)
                                    : customAppTheme.colorError.withAlpha(150),
                                width: 1),
                            borderRadius:
                            BorderRadius.all(Radius.circular(MySize.size4)),
                            color: shop.availableForDelivery
                                ? themeData.colorScheme.primary.withAlpha(40)
                                : customAppTheme.colorError.withAlpha(40)),
                        child: Column(
                          children: [
                            Icon(
                              shop.availableForDelivery
                                  ? MdiIcons.check
                                  : MdiIcons.close,
                              color: shop.availableForDelivery
                                  ? themeData.colorScheme.primary
                                  : customAppTheme.colorError,
                            ),
                            Text(
                              Translator.translate("delivery"),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color: shop.availableForDelivery
                                      ? themeData.colorScheme.primary
                                      : customAppTheme.colorError),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MySize.size16,
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: Spacing.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: themeData.colorScheme.primary
                                    .withAlpha(150),
                                width: 1),
                            borderRadius:
                            BorderRadius.all(Radius.circular(MySize.size4)),
                            color: themeData.colorScheme.primary.withAlpha(40)),
                        child: Column(
                          children: [
                            Text(
                              CurrencyApi.getSign(afterSpace: true) +
                                  CurrencyApi.doubleToString(shop.minimumDeliveryCharge),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText1,
                                  fontWeight: 600,
                                  color: themeData.colorScheme.primary),
                            ),Text(
                              "(+" + CurrencyApi.getSign() +
                                  CurrencyApi.doubleToString(shop.deliveryCostMultiplier) + " per KM)",
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.caption,
                                  fontWeight: 600,
                                  color: themeData.colorScheme.primary),
                            ),
                            Text(
                              Translator.translate("charges"),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color: themeData.colorScheme.primary),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MySize.size16,
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: Spacing.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: shop.isOpen
                                    ? themeData.colorScheme.primary
                                    .withAlpha(150)
                                    : customAppTheme.colorError.withAlpha(150),
                                width: 1),
                            borderRadius:
                            BorderRadius.all(Radius.circular(MySize.size4)),
                            color: shop.isOpen
                                ? themeData.colorScheme.primary.withAlpha(40)
                                : customAppTheme.colorError.withAlpha(40)),
                        child: Column(
                          children: [
                            Icon(
                              shop.isOpen ? MdiIcons.check : MdiIcons.close,
                              color: shop.isOpen
                                  ? themeData.colorScheme.primary
                                  : customAppTheme.colorError,
                            ),
                            Text(
                              shop.isOpen
                                  ? Translator.translate("open")
                                  : Translator.translate("close"),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color: shop.isOpen
                                      ? themeData.colorScheme.primary
                                      : customAppTheme.colorError),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius:  BorderRadius.circular(4),
                        ))
                    ),  onPressed: () {
                    UrlUtils.callFromNumber(shop.mobile);
                  },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MdiIcons.phoneOutline,
                            size: MySize.size18,
                            color: themeData.colorScheme.onPrimary),
                        SizedBox(
                          width: MySize.size8,
                        ),
                        Text(
                          Translator.translate("call_to_shop"),
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyText2,
                              color: themeData.colorScheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MySize.size16,
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius:  BorderRadius.circular(4),
                        ))
                    ), onPressed: () {
                    UrlUtils.openMap(shop.latitude, shop.longitude);
                  },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MdiIcons.mapMarkerOutline,
                            size: MySize.size18,
                            color: themeData.colorScheme.onPrimary),
                        SizedBox(
                          width: MySize.size8,
                        ),
                        Text(
                          Translator.translate("go_to_shop"),
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyText2,
                              color: themeData.colorScheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 16, 16, 0),
            padding: Spacing.all(8),
            decoration: BoxDecoration(
                color: customAppTheme.bgLayer1,
                borderRadius: BorderRadius.all(Radius.circular(MySize.size4)),
                border: Border.all(color: customAppTheme.bgLayer4, width: 1)),
            child: Html(
              shrinkWrap: true,
              data: shop.description,
            ),
          ),

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
