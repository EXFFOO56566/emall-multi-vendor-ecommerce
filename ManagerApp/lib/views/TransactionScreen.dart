import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/api/currency_api.dart';
import 'package:ManagerApp/controllers/TransactionController.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/models/Transaction.dart';
import 'package:ManagerApp/services/AppLocalizations.dart';
import 'package:ManagerApp/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../AppTheme.dart';
import '../AppThemeNotifier.dart';
import 'LoadingScreens.dart';
import 'order/SingleOrderScreen.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  //Theme Data
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = new GlobalKey<ScaffoldMessengerState>();


  //Other Variables
  bool isInProgress = false;

  //Variables
  List<Transaction> transactions;
  double payToAdmin, takeFromAdmin;

  _getData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<Transaction>> myResponse =
        await TransactionController.getAllTransaction();

    if (myResponse.success) {
      transactions = myResponse.data;
      payToAdmin = TransactionController.getPayToAdminTotal(transactions);
      takeFromAdmin = TransactionController.getTakeFromAdminTotal(transactions);
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
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    super.dispose();
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
              backgroundColor: customAppTheme.bgLayer2,
              appBar: AppBar(
                backgroundColor: customAppTheme.bgLayer2,
                leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    MdiIcons.chevronLeft,
                    color: themeData.colorScheme.onBackground,
                    size: MySize.size20,
                  ),
                ),
                title: Text(
                  Translator.translate("transactions"),
                  style: AppTheme.getTextStyle(themeData.textTheme.headline6,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 600),
                ),
                centerTitle: true,
                elevation: 0,
              ),
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
                    Expanded(
                        child: ListView(
                      padding: Spacing.fromLTRB(24, 0, 24, 0),
                      children: [buildBody()],
                    )),
                  ],
                ),
              )));
    });
  }

  buildBody() {
    if (transactions != null) {
      List<TableRow> tableRows = [];

      if (transactions.length != 0) {
        tableRows.add(TableRow(children: [
          Padding(
            padding: Spacing.vertical(8),
            child: Text(
              Translator.translate("ID"),
              style: AppTheme.getTextStyle(
                themeData.textTheme.caption,
                color: themeData.colorScheme.onBackground,
                fontWeight: 700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: Spacing.vertical(8),
            child: Text(
              Translator.translate("pay_to_admin"),
              style: AppTheme.getTextStyle(themeData.textTheme.caption,
                  color: themeData.colorScheme.onBackground, fontWeight: 700),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: Spacing.vertical(8),
            child: Text(
              Translator.translate("take_from_admin"),
              style: AppTheme.getTextStyle(themeData.textTheme.caption,
                  color: themeData.colorScheme.onBackground, fontWeight: 700),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: Spacing.vertical(8),
            child: Text(
              Translator.translate("total"),
              style: AppTheme.getTextStyle(themeData.textTheme.caption,
                  color: themeData.colorScheme.onBackground, fontWeight: 700),
              textAlign: TextAlign.center,
            ),
          ),
        ]));
      }

      for (Transaction transaction in transactions) {
        tableRows.add(TableRow(children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SingleOrderScreen(
                    orderId: transaction.orderId,
                  ),
                ),
              );
            },
            child: Padding(
              padding: Spacing.vertical(6),
              child: Text(
                "#" + transaction.orderId.toString(),
                style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                    color: themeData.colorScheme.primary, fontWeight: 600),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: Spacing.vertical(6),
            child: Text(
              CurrencyApi.CURRENCY_SIGN + transaction.shopToAdmin.toString(),
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                  color: themeData.colorScheme.onBackground, fontWeight: 500),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: Spacing.vertical(6),
            child: Text(
              CurrencyApi.CURRENCY_SIGN + CurrencyApi.doubleToString(transaction.adminToShop),
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                  color: themeData.colorScheme.onBackground, fontWeight: 500),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: Spacing.vertical(6),
            child: Text(
              CurrencyApi.CURRENCY_SIGN + CurrencyApi.doubleToString(transaction.total),
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                  color: themeData.colorScheme.onBackground, fontWeight: 500),
              textAlign: TextAlign.center,
            ),
          ),
        ]));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: Spacing.all(16),
                    decoration: BoxDecoration(
                      color: customAppTheme.bgLayer1,
                      border:
                          Border.all(color: customAppTheme.bgLayer4, width: 1),
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size8)),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: Spacing.all(16),
                          decoration: BoxDecoration(
                            color: themeData.colorScheme.primary.withAlpha(40),
                            borderRadius:
                                BorderRadius.all(Radius.circular(MySize.size4)),
                          ),
                          child: Icon(
                            MdiIcons.accountArrowLeftOutline,
                            color: themeData.colorScheme.primary,
                          ),
                        ),
                        Container(
                            margin: Spacing.top(8),
                            child: Text(
                              CurrencyApi.getSign() + takeFromAdmin.toString(),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  fontWeight: 700),
                              textAlign: TextAlign.center,
                            )),
                        Container(
                            margin: Spacing.top(2),
                            child: Text(
                              Translator.translate("take_from_admin"),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  fontWeight: 500),
                              textAlign: TextAlign.center,
                            )),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MySize.size24,
                ),
                Expanded(
                  child: Container(
                    padding: Spacing.all(16),
                    decoration: BoxDecoration(
                      color: customAppTheme.bgLayer1,
                      border:
                          Border.all(color: customAppTheme.bgLayer4, width: 1),
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size8)),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: Spacing.all(16),
                          decoration: BoxDecoration(
                            color: customAppTheme.colorError.withAlpha(40),
                            borderRadius:
                                BorderRadius.all(Radius.circular(MySize.size4)),
                          ),
                          child: Icon(
                            MdiIcons.accountArrowRightOutline,
                            color: customAppTheme.colorError,
                          ),
                        ),
                        Container(
                            margin: Spacing.top(8),
                            child: Text(
                              CurrencyApi.getSign() + CurrencyApi.doubleToString(payToAdmin),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  fontWeight: 700),
                              textAlign: TextAlign.center,
                            )),
                        Container(
                            margin: Spacing.top(2),
                            child: Text(
                              Translator.translate("pay_to_admin"),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  fontWeight: 500),
                              textAlign: TextAlign.center,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MySize.size16,
          ),
          Container(
            padding: Spacing.fromLTRB(16, 6, 16, 6),
            decoration: BoxDecoration(
                color: customAppTheme.bgLayer3,
                borderRadius: BorderRadius.circular(MySize.size4)),
            child: Text(
              Translator.translate("payments").toUpperCase(),
              style: AppTheme.getTextStyle(themeData.textTheme.caption,
                  fontSize: 12,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 700,
                  muted: true),
            ),
          ),
          SizedBox(
            height: MySize.size16,
          ),
          transactions.length != 0
              ? Table(
                  columnWidths: {
                    0: FractionColumnWidth(0.15),
                    1: FractionColumnWidth(0.3),
                    2: FractionColumnWidth(0.3),
                    3: FractionColumnWidth(0.25),
                  },
                  border:
                      TableBorder.all(width: 1, color: customAppTheme.bgLayer4),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: tableRows,
                )
              : Container(
                  child: Text(
                    "there_is_no_any_payment_yet",
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.onBackground,
                        fontWeight: 500),
                  ),
                )
        ],
      );
    } else if (isInProgress) {
      return LoadingScreens.getProductLoadingScreen(
          context, themeData, customAppTheme);
    } else {
      return Center(
        child: Text("Something wrong"),
      );
    }
  }

  void showMessage({String message = "Something wrong", Duration duration}) {
    if (duration == null) {
      duration = Duration(seconds: 1);
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
