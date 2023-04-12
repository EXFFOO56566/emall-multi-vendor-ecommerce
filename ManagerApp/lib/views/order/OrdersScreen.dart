
import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/controllers/OrderController.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/models/Order.dart';
import 'package:ManagerApp/services/AppLocalizations.dart';
import 'package:ManagerApp/utils/SizeConfig.dart';
import 'package:ManagerApp/views/order/ActiveOrdersScreen.dart';
import 'package:ManagerApp/views/order/PastOrdersScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';
import '../LoadingScreens.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  //ThemeData
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = new GlobalKey<ScaffoldMessengerState>();


  //Other Variables
  bool isInProgress = false;
  List<Order> orders;

  @override
  void initState() {
    super.initState();
    _initOrderData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _initOrderData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<Order>> myResponse = await OrderController.getAllOrder();
    if (myResponse.success) {
      orders = myResponse.data;
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
    _initOrderData();
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
                body: _buildBody()));
      },
    );
  }

  _buildBody() {
    if (orders != null) {
      List<Order> activeOrders = [];
      List<Order> pastOrders = [];

      for(Order order in orders){
        if(Order.isSuccessfulDelivered(order.status) || Order.isCancelled(order.status))
          pastOrders.add(order);
        else
          activeOrders.add(order);
      }

    return DefaultTabController(
          length: 2,
          initialIndex: 0,

          child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: customAppTheme.bgLayer2,

                flexibleSpace: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /*-------------- Build Tabs here ------------------*/
                    Row(
                      children: [
                        Expanded(
                          child: TabBar(
                            tabs: [
                              Tab(
                                  child: Text(Translator.translate("active").toUpperCase(),
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.bodyText2,
                                          fontWeight: 700))),
                              Tab(
                                  child: Text(Translator.translate("past").toUpperCase(),
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.bodyText2,
                                          fontWeight: 700))),

                            ],

                          ),
                        ),
                        isInProgress ? Container(margin: Spacing.right(24),
                          child: SizedBox(
                            width: MySize.size16,
                            height: MySize.size16,
                            child: CircularProgressIndicator(
                                strokeWidth: MySize.size2,
                            ),
                          ),
                        ) : InkWell(
                          onTap: (){
                            _refresh();
                          },
                          child: Container(margin: Spacing.right(16),
                            child: Icon(MdiIcons.refresh,color: themeData.colorScheme.onBackground,)),)
                      ],
                    )
                  ],
                ),
              ),

              /*--------------- Build Tab body here -------------------*/
              body: TabBarView(
                physics: NeverScrollableScrollPhysics(),

                children: <Widget>[
                  ActiveOrdersScreen(orders: activeOrders,rootContext: context),
                  PastOrdersScreen(orders: pastOrders,rootContext: context,),

                ],
              )));
    } else if (isInProgress) {
      return LoadingScreens.getOrderLoadingScreen(
          context, themeData, customAppTheme);
    } else {
      return Center(
        child: Text(Translator.translate("there_is_no_order")),
      );
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
