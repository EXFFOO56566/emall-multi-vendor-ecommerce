import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/controllers/DeliveryBoyController.dart';
import 'package:ManagerApp/models/DeliveryBoy.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/models/Product.dart';
import 'package:ManagerApp/services/AppLocalizations.dart';
import 'package:ManagerApp/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../AppTheme.dart';
import '../AppThemeNotifier.dart';
import 'LoadingScreens.dart';

class EditDeliveryBoysScreen extends StatefulWidget {
  final int id;

  const EditDeliveryBoysScreen({Key key, this.id}) : super(key: key);

  @override
  _EditDeliveryBoysScreenState createState() =>
      _EditDeliveryBoysScreenState();
}

class _EditDeliveryBoysScreenState
    extends State<EditDeliveryBoysScreen> {
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
  Map<String, List<DeliveryBoy>> deliveryBoys;

  @override
  void initState() {
    super.initState();
    _getAllDeliveryBoy();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getAllDeliveryBoy() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Map<String, List<DeliveryBoy>>> myResponse =
        await DeliveryBoyController.getDeliveryBoys();
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

  _manageDeliveryBoy(int deliveryBoyId) async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse =
        await DeliveryBoyController.manageDeliveryBoy(deliveryBoyId);
    if (myResponse.success) {
      deliveryBoys = myResponse.data;
      _refresh();
      showMessage(message: "Allocation successful");
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
    _getAllDeliveryBoy();
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
                    Translator.translate("manage_delivery_boy"),
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
    if (deliveryBoys != null) {
      return _getDeliveryBoyView(deliveryBoys);
    } else if (isInProgress) {
      return LoadingScreens.getOrderLoadingScreen(
          context, themeData, customAppTheme);
    } else {
      return Center(
        child: Text(Translator.translate("loading")),
      );
    }
  }

  _getDeliveryBoyView(Map<String, List<DeliveryBoy>> deliveryBoys) {
    List<Widget> views = [];

    views.add(Text(
      Translator.translate("my_delivery_boys"),
      style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
          color: themeData.colorScheme.onBackground,
          fontWeight: 700,
          muted: true),
    ));

    views.add(SizedBox(height: MySize.size8,));


    for (DeliveryBoy deliveryBoy
        in deliveryBoys[DeliveryBoy.SHOP_DELIVERY_BOYS_KEY]) {
      views.add(
          _singleDeliveryBoy(deliveryBoy, DeliveryBoy.SHOP_DELIVERY_BOYS_KEY));
    }

    if(deliveryBoys[DeliveryBoy.SHOP_DELIVERY_BOYS_KEY].length==0){
      views.add(Center(
        child: Text(
          Translator.translate("you_have_not_any_delivery_boy"),
          style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
              color: themeData.colorScheme.onBackground,
              fontWeight: 600,
              muted: true),
        ),
      ));
    }

    views.add(SizedBox(height: MySize.size16,));



    views.add(Text(
      Translator.translate("unallocated_delivery_boys"),
      style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
          color: themeData.colorScheme.onBackground,
          fontWeight: 700,
          muted: true),
    ));

    views.add(SizedBox(height: MySize.size8,));


    for (DeliveryBoy deliveryBoy
    in deliveryBoys[DeliveryBoy.UNALLOCATED_DELIVERY_BOYS_KEY]) {
      views.add(
          _singleDeliveryBoy(deliveryBoy, DeliveryBoy.UNALLOCATED_DELIVERY_BOYS_KEY));
    }


    if(deliveryBoys[DeliveryBoy.UNALLOCATED_DELIVERY_BOYS_KEY].length==0){
      views.add(Center(
        child: Text(
          Translator.translate("there_is_no_any_delivery_boy"),
          style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
              color: themeData.colorScheme.onBackground,
              fontWeight: 600,
              muted: true),
        ),
      ));
    }

    views.add(SizedBox(height: MySize.size16,));



    views.add(Text(
      Translator.translate("allocated_delivery_boys"),
      style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
          color: themeData.colorScheme.onBackground,
          fontWeight: 700,
          muted: true),
    ));

    views.add(SizedBox(height: MySize.size8,));


    for (DeliveryBoy deliveryBoy
    in deliveryBoys[DeliveryBoy.ALLOCATED_DELIVERY_BOYS_KEY]) {
      views.add(
          _singleDeliveryBoy(deliveryBoy, DeliveryBoy.ALLOCATED_DELIVERY_BOYS_KEY));
    }

    if(deliveryBoys[DeliveryBoy.ALLOCATED_DELIVERY_BOYS_KEY].length==0){
      views.add(Center(
        child: Text(
          Translator.translate("there_is_no_any_delivery_boy"),
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

  _singleDeliveryBoy(DeliveryBoy deliveryBoy, String type) {
    Widget actionWidget;
    if (type == DeliveryBoy.SHOP_DELIVERY_BOYS_KEY) {
      actionWidget = ElevatedButton(
          style: ButtonStyle(
              padding: MaterialStateProperty.all(Spacing.xy(24,12)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius:  BorderRadius.circular(8),
              ))
          ),
          onPressed: () {
            _manageDeliveryBoy(deliveryBoy.id);
          },
          child: Text(
            Translator.translate("remove"),
            style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                color: customAppTheme.onError),
          ));
    } else if (type == DeliveryBoy.UNALLOCATED_DELIVERY_BOYS_KEY) {
      actionWidget = ElevatedButton(
          style: ButtonStyle(
              padding: MaterialStateProperty.all(Spacing.xy(24,12)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius:  BorderRadius.circular(4),
              ))
          ),
          onPressed: () {
            _manageDeliveryBoy(deliveryBoy.id);
          },
          child: Text(
            Translator.translate("add"),
            style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                color: themeData.colorScheme.onPrimary),
          ));
    } else {
      actionWidget = Text(
        Translator.translate("already_allocated_by_other_shop"),
        style: AppTheme.getTextStyle(themeData.textTheme.caption,letterSpacing: 0,
            color: themeData.colorScheme.onBackground, fontWeight: 500),
      );
    }

    return Container(
      margin: Spacing.vertical(8),
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
              child: Text(
            deliveryBoy.name,
            style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                fontWeight: 600, color: themeData.colorScheme.onBackground),
          )),
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
