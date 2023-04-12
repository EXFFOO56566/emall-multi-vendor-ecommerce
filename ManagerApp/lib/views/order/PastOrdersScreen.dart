import 'package:ManagerApp/api/currency_api.dart';
import 'package:ManagerApp/models/Order.dart';
import 'package:ManagerApp/models/Product.dart';
import 'package:ManagerApp/services/AppLocalizations.dart';
import 'package:ManagerApp/utils/Generator.dart';
import 'package:ManagerApp/utils/SizeConfig.dart';
import 'package:ManagerApp/utils/UrlUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';
import '../LoadingScreens.dart';

class PastOrdersScreen extends StatefulWidget {
  final List<Order> orders;
  final BuildContext rootContext;

  const PastOrdersScreen({Key key, this.orders, this.rootContext}) : super(key: key);

  @override
  _PastOrdersScreenState createState() => _PastOrdersScreenState();
}

class _PastOrdersScreenState extends State<PastOrdersScreen> {
  //ThemeData
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = new GlobalKey<ScaffoldMessengerState>();


  //Other Variables
  List<Order> orders;

  @override
  void initState() {
    super.initState();
    orders = widget.orders;
  }

  @override
  void dispose() {
    super.dispose();
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
                backgroundColor: customAppTheme.bgLayer2,
                body: ListView(
                  physics: ClampingScrollPhysics(),
                  padding: Spacing.vertical(16),
                  children: [
                    _buildBody()
                  ],
                )));
      },
    );
  }

  _buildBody() {
    if (orders.length != 0) {
      return _getOrderView(orders);
    }else {
      return Center(child: Text(Translator.translate("you_have_not_any_past_orders")));
    }
  }

  _getOrderView(List<Order> orders) {
    List<Widget> listViews = [];
    for (int i = 0; i < orders.length; i++) {
      listViews.add(InkWell(
        onTap: () async {
        },
        child: _singleOrderItem(orders[i]),
      ));
    }
    return Container(
      margin: Spacing.horizontal(16),
      child: Column(
        children: listViews,
      ),
    );
  }

  _singleOrderItem(Order order) {
    double space = MySize.size16;
    double width =
        (MySize.screenWidth - MySize.getScaledSizeHeight(83) - (2 * space)) / 3;

    List<Widget> _itemWidget = [];
    for (int i = 0; i < order.carts.length; i++) {
      if (i == 2 && order.carts.length > 3) {
        _itemWidget.add(
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
            child: Container(
              color: customAppTheme.bgLayer3,
              height: width,
              width: width,
              child: Center(
                  child: Text(
                "+" + (order.carts.length - 2).toString(),
                style: AppTheme.getTextStyle(themeData.textTheme.subtitle1,
                    letterSpacing: 0.5,
                    color: themeData.colorScheme.onBackground,
                    fontWeight: 600),
              )),
            ),
          ),
        );
        break;
      } else {
        _itemWidget.add(
          Container(
              margin: (i == 2) ? Spacing.zero : Spacing.only(right: space),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
                child: order.carts[i].product.productImages.length != 0
                    ? Image.network(
                        order.carts[i].product.productImages[0].url,
                        loadingBuilder: (BuildContext ctx, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return LoadingScreens.getSimpleImageScreen(
                                context, themeData, customAppTheme,
                                width: MySize.size90, height: MySize.size90);
                          }
                        },
                        height: MySize.size90,
                        width: MySize.size90,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        Product.getPlaceholderImage(),
                        height: MySize.size90,
                        fit: BoxFit.fill,
                      ),
              )),
        );
      }
    }

    return Container(
      padding: Spacing.all(16),
      margin: Spacing.only(top: 0, bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
        color: customAppTheme.bgLayer1,
        border: Border.all(color: customAppTheme.bgLayer3, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Translator.translate("order") + " " + order.id.toString(),
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.subtitle1,
                          fontWeight: 700,
                          letterSpacing: -0.2),
                    ),
                    Container(
                      margin: Spacing.only(top: 4),
                      child: Text(
                        CurrencyApi.getSign(afterSpace: true) +
                            CurrencyApi.doubleToString(order.total),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            fontWeight: 600,
                            letterSpacing: 0),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: Spacing.fromLTRB(12, 8, 12, 8),
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(Radius.circular(MySize.size4)),
                    color: Order.isCancelled(order.status)
                        ? customAppTheme.colorError
                        : (Order.isSuccessfulDelivered(order.status)
                            ? customAppTheme.colorSuccess
                            : customAppTheme.bgLayer3)),
                child: Text(
                  Order.getTextFromOrderStatus(order.status, order.orderType)
                      .toUpperCase(),
                  style: AppTheme.getTextStyle(themeData.textTheme.caption,
                      fontSize: 11,
                      fontWeight: 700,
                      color: Order.isCancelled(order.status)
                          ? customAppTheme.onError
                          : (Order.isSuccessfulDelivered(order.status)
                              ? customAppTheme.onSuccess
                              : themeData.colorScheme.onBackground),
                      letterSpacing: 0.25),
                ),
              ),
            ],
          ),
          Container(
              margin: Spacing.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      Generator.convertDateTimeToText(order.createdAt,
                          showSecond: false),
                      style: AppTheme.getTextStyle(themeData.textTheme.caption,
                          fontWeight: 600,
                          letterSpacing: -0.1,
                          color: themeData.colorScheme.onBackground
                              .withAlpha(160))),
                  Text("OTP : " + order.otp.toString(),
                      style: AppTheme.getTextStyle(themeData.textTheme.caption,
                          fontWeight: 600,
                          color: themeData.colorScheme.onBackground)),
                ],
              )),
          Container(
            margin: Spacing.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: _itemWidget,
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(themeData.colorScheme.primary.withAlpha(28)),
                  shadowColor: MaterialStateProperty.all(themeData.colorScheme.primary.withAlpha(28)),
                    padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius:  BorderRadius.circular(4),
                    ))
                ),
                onPressed: () {
                  UrlUtils.goToOrderReceipt(order.id);
                },
                child: Text(
                  Translator.translate("receipt").toUpperCase(),
                  style: AppTheme.getTextStyle(themeData.textTheme.caption,
                      fontWeight: 600, color: themeData.colorScheme.primary),
                )),
          ),
          Container(
            margin: Spacing.top(8),
            alignment: Alignment.centerRight,
            child: Text(
              Translator.translate("you_earned") +
                  " " +
                  CurrencyApi.CURRENCY_SIGN +
                  order.shopRevenue.toString() +
                  " " +
                  Translator.translate("from_this_order"),
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                  color: themeData.colorScheme.onBackground, fontWeight: 600),
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
