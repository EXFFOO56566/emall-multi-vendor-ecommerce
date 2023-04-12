import 'dart:async';
import 'dart:collection';
import 'package:DeliveryBoyApp/api/api_util.dart';
import 'package:DeliveryBoyApp/api/currency_api.dart';
import 'package:DeliveryBoyApp/controllers/OrderController.dart';
import 'package:DeliveryBoyApp/models/MyResponse.dart';
import 'package:DeliveryBoyApp/models/Order.dart';
import 'package:DeliveryBoyApp/services/AppLocalizations.dart';
import 'package:DeliveryBoyApp/utils/GoogleMapUtils.dart';
import 'package:DeliveryBoyApp/utils/SizeConfig.dart';
import 'package:DeliveryBoyApp/utils/UrlUtils.dart';
import 'package:DeliveryBoyApp/views/OrderOTPDialog.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../AppTheme.dart';
import '../AppThemeNotifier.dart';

class SingleOrderScreen extends StatefulWidget {
  final int orderId;

  const SingleOrderScreen({Key key, this.orderId}) : super(key: key);

  @override
  _SingleOrderScreenState createState() => _SingleOrderScreenState();
}

class _SingleOrderScreenState extends State<SingleOrderScreen> {

  //ThemeData
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = new GlobalKey<ScaffoldMessengerState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Google Maps
  BitmapDescriptor shopPinIcon, deliveryPinIcon, deliveryBoyPinIcon;
  GoogleMapController mapController;
  bool loaded = false;
  final Set<Marker> _markers = HashSet();
  LatLng _center;
  LatLng currentPosition;

  //styles
  String mapDarkStyle;
  String mapLightStyle="[]";

  //Locations
  LatLng deliveryLocation;
  LatLng deliveryBoyLocation;
  LatLng shopLocation;

  //Order details
  bool isInProgress = false;
  Order order;

  //Timers
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {

    //Custom pin setup
    _setCustomPin();

    //Getting Location permission
    LocationPermission locationPermission = await _setupLocationPermission();

    if(locationPermission!=LocationPermission.always && locationPermission!=LocationPermission.whileInUse){
      Navigator.pop(context, locationPermission);
      return;
    }


    _locationTimerTask();

    //Every 20 sec delivery boy location updated
    _timer = new Timer.periodic(
        Duration(seconds: 20),
        (Timer timer) => setState(() {

              _locationTimerTask();
            }));

    _initOrderData();
  }


  _onMarkerTapped(LatLng latLng) async{
    double zoom = await (mapController.getZoomLevel());
    zoom = zoom>17 ? zoom : 17;
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: latLng, zoom: zoom)));
  }


  _locationTimerTask() async {

    if(mounted) {
      setState(() {
        isInProgress = true;
      });
    }



    Position position;
    try {
      position =
          await  Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    } catch (error) {
      return LocationPermission.denied;
    }

    //update map markers
    Marker deliveryBoyLocationMarker = Marker(
        markerId: MarkerId('delivery_boy_location'),
        position: LatLng(position.latitude, position.longitude),
        icon: deliveryBoyPinIcon);

    if(mounted) {
      setState(() {
        _markers.add(deliveryBoyLocationMarker);
        _center = LatLng(position.latitude, position.longitude);
      });
    }

    if (order != null) {
      MyResponse myResponse = await OrderController.updateOrder(order.id,
          latitude: position.latitude, longitude: position.longitude);
      if (!myResponse.success) {
        showMessage(message: myResponse.errorText);
      }
    }

    if(mounted) {
      setState(() {
        isInProgress = false;
      });
    }

    return LocationPermission.always;
  }

  _setupLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return await Geolocator.requestPermission();
    }else if(permission == LocationPermission.deniedForever){
      Geolocator.openAppSettings();
    }
    return permission;
  }

  _initOrderData() async {
    if(mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Order> myResponse =
        await OrderController.getSingleOrder(widget.orderId);
    if (myResponse.success) {
      order = myResponse.data;
      shopLocation = LatLng(order.shop.latitude, order.shop.longitude);
      deliveryLocation =
          LatLng(order.address.latitude, order.address.longitude);
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

    if(mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  _changeStatus(int status) async {

    int otp;
    if(status==5){
       String otpString = await showDialog(
          context: context, builder: (BuildContext context) => OrderOTPDialog());

       if(otpString.isEmpty){
         showMessage(message: Translator.translate("please fill otp to confirm order delivery"));
         return;
       }
       otp = int.tryParse(otpString);
       if(otp==null){
          showMessage(message: Translator.translate("please fill otp to confirm order delivery"));
          return;
       }

    }

    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse =
    await OrderController.updateOrder(order.id, status: status,otp: otp);
    if (myResponse.success) {
      if (status == 5) {
        Navigator.pop(context);
      } else {
        _refresh();
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

  _setCustomPin() async {

    //Set custom map pins for delivery location, shop location, self location
    shopPinIcon = BitmapDescriptor.fromBytes(
        await GoogleMapUtils.getBytesFromAsset('assets/map/shop-pin.png',
            MySize.getScaledSizeHeight(128).floor()));

    deliveryPinIcon = BitmapDescriptor.fromBytes(
        await GoogleMapUtils.getBytesFromAsset('assets/map/delivery-pin.png',
            MySize.getScaledSizeHeight(100).floor()));

    deliveryBoyPinIcon = BitmapDescriptor.fromBytes(
        await GoogleMapUtils.getBytesFromAsset(
            'assets/map/delivery-boy-pin.png',
            MySize.getScaledSizeHeight(60).floor()));


    //Custom dark mode google map style
    String mapStyle =
        await rootBundle.loadString('assets/map/map-dark-style.txt');
    if(mounted) {
      setState(() {
        mapDarkStyle = mapStyle;
      });
    }
  }

  _setMapStyle(int themeMode) {
    if (themeMode == 2 && mapDarkStyle != null && mapController != null) {
      mapController.setMapStyle(mapDarkStyle);
    } else if (mapController != null) {
      mapController.setMapStyle(mapLightStyle);
    }
  }

  _onMapCreated(GoogleMapController controller) async {
    //When map created then setup shop and delivery location marker

    mapController = controller;

    mapController.setMapStyle(mapDarkStyle);
    Marker shopMarker = Marker(
        markerId: MarkerId('shop_location'),
        position: shopLocation,
        icon: shopPinIcon,
    onTap: (){
          _onMarkerTapped(shopLocation);
    });
    Marker locationMarker = Marker(
        markerId: MarkerId('delivery_location'),
        position: deliveryLocation,
        icon: deliveryPinIcon,
        onTap: (){
          _onMarkerTapped(deliveryLocation);
        });
    setState(() {
      _markers.add(shopMarker);
      _markers.add(locationMarker);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) _timer.cancel();
  }

  Future<void> _refresh() async {
    _initOrderData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        int themeType = value.themeMode();
        _setMapStyle(themeType);
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return MaterialApp(
          scaffoldMessengerKey: _scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(themeType),
            home: Scaffold(
                key: _scaffoldKey,
                backgroundColor: customAppTheme.bgLayer1,
                body: RefreshIndicator(
                    onRefresh: _refresh,
                    backgroundColor: customAppTheme.bgLayer1,
                    color: themeData.colorScheme.primary,
                    key: _refreshIndicatorKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: order != null && _center != null
                              ? GoogleMap(
                                  onMapCreated: _onMapCreated,
                                  markers: _markers,
                                  initialCameraPosition: CameraPosition(
                                    target: _center,
                                    zoom: 14,
                                  ),
                                )
                              : Container(),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: Spacing.bottom(16),
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
                        )
                      ],
                    ))));
      },
    );
  }

  _buildBody(){
    if(order!=null){
      return Column(
        children: [
          Container(
            margin: Spacing.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          MdiIcons.chevronLeft,
                          size: MySize.size20,
                          color: themeData
                              .colorScheme
                              .onBackground,
                        )),
                  ),
                ),
                Container(
                  width: MySize.size16,
                  height: MySize.size16,
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(
                          Radius.circular(
                              MySize.size8)),
                      border: Border.all(
                          color: Order
                              .getColorFromOrderStatus(
                              order.status)
                              .withAlpha(40),
                          width: MySize.size4)),
                  child: Container(
                      width: MySize.size8,
                      height: MySize.size8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius
                              .all(Radius.circular(
                              MySize.size4)),
                          color: Order
                              .getColorFromOrderStatus(
                              order.status))),
                ),
                Container(
                  margin: Spacing.left(8),
                  child: Text(
                      Order.getTextFromOrderStatus(
                          order.status)),
                ),
                Expanded(
                  child: Align(
                    alignment:
                    Alignment.centerRight,
                    child: InkWell(
                        onTap: () {
                          _refresh();
                        },
                        child: Icon(
                          MdiIcons.refresh,
                          size: MySize.size20,
                          color: themeData
                              .colorScheme
                              .onBackground,
                        )),
                  ),
                )
              ],
            ),
          ),
          _billWidget(),
          _buttonsForStatus(order.status)
        ],
      );
    }else{
      return Container();
    }
  }

  _billWidget(){
    return Container(
      margin: Spacing.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
          color: customAppTheme.bgLayer1,
          borderRadius: BorderRadius.all(
              Radius.circular(MySize.size8)),
          border: Border.all(
              color: customAppTheme.bgLayer4,
              width: 1)),
      padding: Spacing.all(16),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Translator.translate("billing_information"),
                style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyText2,
                    color: themeData
                        .colorScheme.onBackground,
                    fontWeight: 600,
                    muted: true),
              ),
              InkWell(
                onTap: (){
                  UrlUtils.goToOrderReceipt(order.id);
                },
                child: Text(
                  "View order",
                  style: AppTheme.getTextStyle(
                      themeData.textTheme.bodyText2,
                      color: themeData
                          .colorScheme.primary,
                      fontWeight: 600),
                ),
              ),
            ],
          ),
          Container(
            margin: Spacing.fromLTRB(
                16, 8, 16, 0),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [
                Text(
                  Translator.translate("order"),
                  style:
                  AppTheme.getTextStyle(
                      themeData.textTheme
                          .bodyText2,
                      color: themeData
                          .colorScheme
                          .onBackground),
                ),
                Text(
                  CurrencyApi.getSign(afterSpace: true) +
                      order.order.toString(),
                  style:
                  AppTheme.getTextStyle(
                      themeData.textTheme
                          .bodyText2,
                      color: themeData
                          .colorScheme
                          .onBackground,
                      fontWeight: 600),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(
                16, 4, 16, 0),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [
                Text(
                  Translator.translate("tax"),
                  style:
                  AppTheme.getTextStyle(
                      themeData.textTheme
                          .bodyText2,
                      color: themeData
                          .colorScheme
                          .onBackground),
                ),
                Text(
                  CurrencyApi.getSign(afterSpace: true) +
                      order.tax.toString(),
                  style:
                  AppTheme.getTextStyle(
                      themeData.textTheme
                          .bodyText2,
                      color: themeData
                          .colorScheme
                          .onBackground,
                      fontWeight: 600),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(
                16, 4, 16, 0),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [
                Text(
                  Translator.translate("delivery_fee"),
                  style:
                  AppTheme.getTextStyle(
                      themeData.textTheme
                          .bodyText2,
                      color: themeData
                          .colorScheme
                          .onBackground),
                ),
                Text(
                  CurrencyApi.getSign(afterSpace: true) +
                      CurrencyApi.doubleToString(order.deliveryFee),
                  style:
                  AppTheme.getTextStyle(
                      themeData.textTheme
                          .bodyText2,
                      color: themeData
                          .colorScheme
                          .onBackground,
                      fontWeight: 600),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(
                16, 4, 16, 0),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [
                Expanded(
                  child: Container(),
                ),
                Expanded(
                  child: Divider(),
                )
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(
                16, 4, 16, 0),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [
                Text(
                  Translator.translate("total"),
                  style:
                  AppTheme.getTextStyle(
                      themeData.textTheme
                          .bodyText2,
                      color: themeData
                          .colorScheme
                          .onBackground,
                      fontWeight: 600),
                ),
                Text(
                  CurrencyApi.getSign(afterSpace: true) +
                      CurrencyApi.doubleToString(order.total),
                  style:
                  AppTheme.getTextStyle(
                      themeData.textTheme
                          .bodyText2,
                      color: themeData
                          .colorScheme
                          .onBackground,
                      fontWeight: 600),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(
                16, 8, 16, 0),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [
                Text(
                  Translator.translate("payment_method"),
                  style:
                  AppTheme.getTextStyle(
                      themeData.textTheme
                          .bodyText2,
                      color: themeData
                          .colorScheme
                          .onBackground,
                      fontWeight: 500),
                ),
                Text(
                  Order.getPaymentTypeText(
                      order.status),
                  style:
                  AppTheme.getTextStyle(
                      themeData.textTheme
                          .bodyText2,
                      color: themeData
                          .colorScheme
                          .onBackground,
                      fontWeight: 500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buttonsForStatus(int status) {
    switch (status) {
      case 3:
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(

                onPressed: () async {
                  UrlUtils.openMap(order.shop.latitude, order.shop.longitude);
                },
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.mapMarkerOutline,
                      color: themeData.colorScheme.onBackground,
                      size: MySize.size18,
                    ),
                    Container(
                      margin: Spacing.left(8),
                      child: Text(
                        Translator.translate("direction_to_shop"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onBackground),
                      ),
                    )
                  ],
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius:  BorderRadius.circular(4),
                    ))
                ),
                onPressed: () {
                  _changeStatus(4);
                },
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.clipboardArrowUpOutline,
                      color: themeData.colorScheme.onPrimary,
                      size: MySize.size18,
                    ),
                    Container(
                      margin: Spacing.left(8),
                      child: Text(
                        Translator.translate("pick_up_order"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onPrimary),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      case 4:
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(

                onPressed: () async {
                  UrlUtils.openMap(order.address.latitude, order.address.longitude);
                },
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.mapMarkerOutline,
                      color: themeData.colorScheme.onBackground,
                      size: MySize.size18,
                    ),
                    Container(
                      margin: Spacing.left(8),
                      child: Text(
                        Translator.translate("direction_to_delivery"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onBackground),
                      ),
                    )
                  ],
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius:  BorderRadius.circular(4),
                    ))
                ),
                onPressed: () {
                  _changeStatus(5);
                },
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.clipboardArrowUpOutline,
                      color: themeData.colorScheme.onPrimary,
                      size: MySize.size18,
                    ),
                    Container(
                      margin: Spacing.left(8),
                      child: Text(
                        Translator.translate("delivered"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onPrimary),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
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




