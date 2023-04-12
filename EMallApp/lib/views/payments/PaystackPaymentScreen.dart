import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/api/currency_api.dart';
import 'package:EMallApp/api/payment_api.dart';
import 'package:EMallApp/controllers/OrderController.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Order.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/views/LoadingScreens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';
import '../OrderScreen.dart';

class PaystackPaymentScreen extends StatefulWidget {
  final int orderId;

  const PaystackPaymentScreen({Key key, @required this.orderId})
      : super(key: key);

  @override
  _PaystackPaymentScreenState createState() => _PaystackPaymentScreenState();
}

class _PaystackPaymentScreenState extends State<PaystackPaymentScreen> {
  //ThemeData
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  //Other Variables
  bool isInProgress = false;

  //Order
  Order order;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    await PaystackPlugin.initialize(publicKey: PaymentApi.PAYSTACK_PUBLIC_KEY);

    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Order> myResponse =
        await OrderController.getSingleOrder(widget.orderId);
    if (myResponse.success) {
      order = myResponse.data;

      if (order.orderPayment.paymentId == "null") {
        Navigator.pop(context);
      }
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

  _updatePayment(String paystackId) async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse =
        await OrderController.updatePayment(widget.orderId, true, paystackId);
    if (myResponse.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => OrderScreen(),
        ),
      );
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

  _payment() async {
    if (order == null) return;

    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    try {
      Charge charge = Charge()
        ..amount = (order.total * 100).toInt()
        ..accessCode = order.orderPayment.paymentId
        ..email = 'customer@email.com';

      CheckoutResponse response = await PaystackPlugin.checkout(
        context,
        method: CheckoutMethod.selectable,
        charge: charge,
        fullscreen: true,
      );

      if (response.verify) {
        _updatePayment(response.reference);
      } else {
        showMessage(message: "Payment Failed");
      }
    } catch (e) {
      showMessage(message: "Something wrong");
    }

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  _cancelOrder() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse = await OrderController.updateOrder(
        order.id, Order.ORDER_CANCELLED_BY_USER);
    if (myResponse.success) {
      Navigator.pop(context);
      return;
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
  void dispose() {
    super.dispose();
  }

  _billWidget() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(Translator.translate("order"),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      muted: true,
                      letterSpacing: 0,
                      fontWeight: 600)),
              Text(
                  CurrencyApi.getSign(afterSpace: true) +
                      CurrencyApi.doubleToString(order.order),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      muted: true,
                      letterSpacing: 0,
                      fontWeight: 600)),
            ],
          ),
          Container(
            margin: Spacing.top(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Translator.translate("coupon_discount"),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.onBackground,
                        muted: true,
                        letterSpacing: 0,
                        fontWeight: 600)),
                Text(
                    "-" +
                        CurrencyApi.getSign(afterSpace: true) +
                        CurrencyApi.doubleToString(order.couponDiscount),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.onBackground,
                        letterSpacing: 0,
                        muted: true,
                        fontWeight: 600)),
              ],
            ),
          ),
          Container(
            margin: Spacing.top(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Translator.translate("tax"),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.onBackground,
                        muted: true,
                        letterSpacing: 0,
                        fontWeight: 600)),
                Text(
                    CurrencyApi.getSign(afterSpace: true) +
                        CurrencyApi.doubleToString(order.tax),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.onBackground,
                        letterSpacing: 0,
                        muted: true,
                        fontWeight: 600)),
              ],
            ),
          ),
          Container(
            margin: Spacing.top(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Translator.translate("delivery_fee"),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.onBackground,
                        muted: true,
                        letterSpacing: 0,
                        fontWeight: 600)),
                Text(
                    CurrencyApi.getSign(afterSpace: true) +
                        CurrencyApi.doubleToString(order.deliveryFee),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.onBackground,
                        letterSpacing: 0,
                        muted: true,
                        fontWeight: 600)),
              ],
            ),
          ),
          Container(
            margin: Spacing.top(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(child: Container()),
                Expanded(child: Divider()),
              ],
            ),
          ),
          Container(
            margin: Spacing.top(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Translator.translate("total"),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                        color: themeData.colorScheme.onBackground,
                        letterSpacing: 0,
                        fontWeight: 700)),
                Text(
                    CurrencyApi.getSign(afterSpace: true) +
                        CurrencyApi.doubleToString(order.total),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                        color: themeData.colorScheme.onBackground,
                        letterSpacing: 0,
                        fontWeight: 700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return MaterialApp(
            scaffoldMessengerKey: _scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  backgroundColor: customAppTheme.bgLayer1,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(MdiIcons.chevronLeft),
                  ),
                  title: Text(Translator.translate("confirm_payment"),
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.headline6,
                          fontWeight: 600)),
                ),
                backgroundColor: customAppTheme.bgLayer1,
                body: Container(
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
                      Expanded(child: _buildBody()),
                    ],
                  ),
                )));
      },
    );
  }

  _buildBody() {
    if (order != null) {
      return ListView(
        children: <Widget>[
          Container(
            margin: Spacing.fromLTRB(16, 0, 16, 0),
            padding: Spacing.all(16),
            decoration: BoxDecoration(
                color: customAppTheme.bgLayer1,
                borderRadius: BorderRadius.all(Radius.circular(4)),
                border: Border.all(color: customAppTheme.bgLayer4, width: 1)),
            child: _billWidget(),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 24, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(isInProgress
                            ? customAppTheme.disabledColor
                            : customAppTheme.colorError),
                        padding: MaterialStateProperty.all(Spacing.xy(24, 12)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ))),
                    onPressed: isInProgress
                        ? () {}
                        : () {
                            _cancelOrder();
                          },
                    child: Text(
                      Translator.translate("cancel_order").toUpperCase(),
                      style: AppTheme.getTextStyle(themeData.textTheme.caption,
                          letterSpacing: 0.6,
                          fontWeight: 600,
                          color: isInProgress
                              ? customAppTheme.onDisabled
                              : customAppTheme.onError),
                    ),
                  ),
                ),
                SizedBox(
                  width: MySize.size16,
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(Spacing.xy(24, 12)),
                        backgroundColor: MaterialStateProperty.all(isInProgress
                            ? customAppTheme.disabledColor
                            : themeData.colorScheme.primary),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ))),
                    onPressed: isInProgress
                        ? () {}
                        : () {
                            _payment();
                          },
                    child: Text(
                      Translator.translate("proceed_to_pay").toUpperCase(),
                      style: AppTheme.getTextStyle(themeData.textTheme.caption,
                          letterSpacing: 0.6,
                          fontWeight: 600,
                          color: isInProgress
                              ? customAppTheme.onDisabled
                              : themeData.colorScheme.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      );
    } else {
      return LoadingScreens.getConfirmPaymentLoadingScreen(
          context, themeData, customAppTheme);
    }
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
