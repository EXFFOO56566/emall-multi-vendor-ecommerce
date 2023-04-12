import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/controllers/OrderController.dart';
import 'package:ManagerApp/models/DeliveryBoy.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/models/Product.dart';
import 'package:ManagerApp/services/AppLocalizations.dart';
import 'package:ManagerApp/utils/DistanceUtils.dart';
import 'package:ManagerApp/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../AppTheme.dart';
import '../AppThemeNotifier.dart';
import 'LoadingScreens.dart';

class SelectDeliveryBoyOrderScreen extends StatefulWidget {
  final int id;

  const SelectDeliveryBoyOrderScreen({Key key, this.id}) : super(key: key);

  @override
  _SelectDeliveryBoyOrderScreenState createState() =>
      _SelectDeliveryBoyOrderScreenState();
}

class _SelectDeliveryBoyOrderScreenState
    extends State<SelectDeliveryBoyOrderScreen> {
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
  List<DeliveryBoy> deliveryBoys = [];

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

    MyResponse<List<DeliveryBoy>> myResponse =
        await OrderController.getDeliveryBoyForOrder(widget.id);
    if (myResponse.success) {
      deliveryBoys = myResponse.data;
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


  Future<void> _assignDeliveryBoy(int id) async {
    if(mounted){
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse = await OrderController.assignDeliveryBoyForOrder(widget.id, id);
    if(myResponse.success){
      Navigator.pop(context);
    }else{
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

    if(mounted){
      setState(() {
        isInProgress = false;
      });
    }

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
                  elevation: 0,
                  title: Text(
                    Translator.translate("select_delivery_boy"),
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
    if (deliveryBoys.length != 0) {
      return _getDeliveryBoyView(deliveryBoys);
    } else if (isInProgress) {
      return LoadingScreens.getOrderLoadingScreen(
          context, themeData, customAppTheme);
    } else {
      return Center(
        child: Text(Translator.translate("there_is_no_any_free_delivery_boy")),
      );
    }
  }

  _getDeliveryBoyView(List<DeliveryBoy> deliveryBoys) {
    List<Widget> views = [];



    for (DeliveryBoy deliveryBoy in deliveryBoys) {
      views.add(_singleDeliveryBoy(deliveryBoy));
    }

    return Container(
      child: ListView(
        padding: Spacing.all(16),
        children: views,
      ),
    );
  }

  _singleDeliveryBoy(DeliveryBoy deliveryBoy) {
    return Container(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(MySize.size20),
            child: deliveryBoy.avatarUrl != null
                ? Image.network(
                    deliveryBoy.avatarUrl,
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
                    height: MySize.size40,
                    width: MySize.size40,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    Product.getPlaceholderImage(),
                    height: MySize.size40,
                    fit: BoxFit.fill,
                  ),
          ),
          SizedBox(
            width: MySize.size16,
          ),
          Expanded(
              child: Column(
            children: [
              Text(
                deliveryBoy.name,
                style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                    fontWeight: 600, color: themeData.colorScheme.onBackground),
              ),Text(
              DistanceUtils.formatDistance(deliveryBoy.farFromShop),
                style: AppTheme.getTextStyle(themeData.textTheme.caption,
                    fontWeight: 600, color: themeData.colorScheme.onBackground,muted: true),
              ),
            ],
          )),
          ElevatedButton(
            style: ButtonStyle(
                padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius:  BorderRadius.circular(4),
                ))
            ),
            onPressed: () {
              _assignDeliveryBoy(deliveryBoy.id);
            },
            child: Text(
              Translator.translate("assign"),
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                  color: themeData.colorScheme.onPrimary),
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
