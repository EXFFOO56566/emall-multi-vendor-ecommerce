import 'dart:async';
import 'dart:collection';
import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/api/currency_api.dart';
import 'package:ManagerApp/controllers/OrderController.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/models/Order.dart';
import 'package:ManagerApp/services/AppLocalizations.dart';
import 'package:ManagerApp/utils/ColorUtils.dart';
import 'package:ManagerApp/utils/GoogleMapUtils.dart';
import 'package:ManagerApp/utils/SizeConfig.dart';
import 'package:ManagerApp/utils/UrlUtils.dart';
import 'package:ManagerApp/views/SelectDeliveryBoyOrderScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';

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
  final LatLng _center = const LatLng(45.521563, -122.677433);
  LatLng currentPosition;
  String mapDarkStyle;

  //Locations
  LatLng deliveryLocation;
  LatLng deliveryBoyLocation;
  LatLng shopLocation;

  //Other variables
  bool isInProgress = false;
  Order order;

  Timer _timer;

  @override
  void initState() {
    super.initState();
    currentPosition = _center;
    _getOrderData();
    _setCustomPin();
    _setTimer();
  }

  _getOrderData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    } else {
      return;
    }

    MyResponse<Order> myResponse =
        await OrderController.getSingleOrder(widget.orderId);
    if (myResponse.success) {
      order = myResponse.data;
      shopLocation = LatLng(order.shop.latitude, order.shop.longitude);
      if (!Order.isPickUpOrder(order.orderType)) {
        deliveryLocation =
            LatLng(order.address.latitude, order.address.longitude);
      }

      if (order.deliveryBoy != null) {
        if (order.deliveryBoy.latitude != null &&
            order.deliveryBoy.longitude != null) {
          deliveryBoyLocation =
              LatLng(order.deliveryBoy.latitude, order.deliveryBoy.longitude);
          _changeDeliveryPin();
        }
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

    String mapStyle =
        await rootBundle.loadString('assets/map/map-dark-style.txt');

    if (mounted) {
      setState(() {
        mapDarkStyle = mapStyle;
      });
    }
  }

  _changeDeliveryPin() {
    Marker deliveryBoyMarker;
    if (deliveryBoyLocation != null) {
      deliveryBoyMarker = Marker(
          markerId: MarkerId('delivery_boy_location'),
          position: deliveryBoyLocation,
          icon: deliveryBoyPinIcon);
    }

    if (mounted) {
      setState(() {
        _markers.add(deliveryBoyMarker);
      });
    }
  }

  _onMarkerTapped(LatLng latLng) async {
    double zoom = await (mapController.getZoomLevel());
    zoom = zoom > 17 ? zoom : 17;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: zoom)));
  }

  _setMapStyle(int themeMode) {
    if (themeMode == 2 && mapDarkStyle != null && mapController != null) {
      mapController.setMapStyle(mapDarkStyle);
    } else if (mapController != null) {
      mapController.setMapStyle("[]");
    }
  }

  _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    mapController.setMapStyle(mapDarkStyle);
    Marker shopMarker = Marker(
        markerId: MarkerId('shop_location'),
        position: shopLocation,
        icon: shopPinIcon,
        onTap: () {
          _onMarkerTapped(shopLocation);
        });

    Marker locationMarker;
    if (deliveryLocation != null) {
      locationMarker = Marker(
          markerId: MarkerId('delivery_location'),
          position: deliveryLocation,
          icon: deliveryPinIcon,
          onTap: () {
            _onMarkerTapped(deliveryLocation);
          });
    }

    Marker deliveryBoyMarker;
    if (deliveryBoyLocation != null) {
      deliveryBoyMarker = Marker(
          markerId: MarkerId('delivery_boy_location'),
          position: deliveryBoyLocation,
          icon: deliveryBoyPinIcon,
          onTap: () {
            _onMarkerTapped(deliveryBoyLocation);
          });
    }

    if (mounted) {
      setState(() {
        _markers.add(shopMarker);
        if (deliveryBoyLocation != null) {
          _markers.add(locationMarker);
        }
        if (deliveryBoyLocation != null) {
          _markers.add(deliveryBoyMarker);
        }
      });
    }
  }

  _changeStatus(int status) async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse = await OrderController.updateOrder(order.id, status);
    if (myResponse.success) {
      if (Order.isCancelled(status)) {
        Navigator.pop(context);
        return;
      }

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

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
    if (_timer != null) _timer.cancel();
  }

  Future<void> _refresh() async {
    _getOrderData();
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
                          child: order != null
                              ? GoogleMap(
                                  onMapCreated: _onMapCreated,
                                  markers: _markers,
                                  initialCameraPosition: CameraPosition(
                                    target: _center,
                                    zoom: 11.0,
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

  _buildBody() {
    if (order != null) {
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
                          color: themeData.colorScheme.onBackground,
                        )),
                  ),
                ),
                Container(
                  width: MySize.size16,
                  height: MySize.size16,
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size8)),
                      border: Border.all(
                          color:
                              ColorUtils.getColorFromOrderStatus(order.status)
                                  .withAlpha(40),
                          width: MySize.size4)),
                  child: Container(
                      width: MySize.size8,
                      height: MySize.size8,
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.all(Radius.circular(MySize.size4)),
                          color: ColorUtils.getColorFromOrderStatus(
                              order.status))),
                ),
                Container(
                  margin: Spacing.left(8),
                  child: Text(Order.getTextFromOrderStatus(
                      order.status, order.orderType)),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                        onTap: () {
                          _refresh();
                        },
                        child: Icon(
                          MdiIcons.refresh,
                          size: MySize.size20,
                          color: themeData.colorScheme.onBackground,
                        )),
                  ),
                )
              ],
            ),
          ),
          _billWidget(),
          _buttonForStatus()
        ],
      );
    } else {
      return Center(
        child: Text(
          "Wait...",
          style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
              color: themeData.colorScheme.onBackground),
        ),
      );
    }
  }

  _buttonForStatus() {
    if (Order.isPickUpOrder(order.orderType)) {
      if (order.status == 1) {
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius:  BorderRadius.circular(4),
                      ))
                  ),
                  onPressed: () {
                _changeStatus(Order.ORDER_CANCELLED_BY_SHOP);
                  },
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    MdiIcons.close,
                    color: customAppTheme.onError,
                    size: MySize.size18,
                  ),
                  Container(
                    margin: Spacing.left(8),
                    child: Text(
                      Translator.translate("cancel_order"),
                      style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                          color: customAppTheme.onError),
                    ),
                  )
                ],
                  ),
                ),
              ),
              SizedBox(width: MySize.size16,),
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius:  BorderRadius.circular(4),
                      ))
                  ),
                  onPressed: () {
                _changeStatus(Order.ORDER_ACCEPTED);
                  },
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    MdiIcons.check,
                    color: themeData.colorScheme.onPrimary,
                    size: MySize.size18,
                  ),
                  Container(
                    margin: Spacing.left(8),
                    child: Text(
                      Translator.translate("accept"),
                      style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                          color: themeData.colorScheme.onPrimary),
                    ),
                  )
                ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
      else if (order.status == 2) {
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius:  BorderRadius.circular(4),
                    ))
                ),
                onPressed: () {
                  _changeStatus(Order.ORDER_READY_FOR_DELIVERY);
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
                        Translator.translate("order_ready"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onPrimary),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }
      return SizedBox(
        height: MySize.size8,
      );

    }
    else {
      if (order.status == 1) {
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius:  BorderRadius.circular(4),
                      ))
                  ),
                  onPressed: () {
                    _changeStatus(Order.ORDER_CANCELLED_BY_SHOP);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        MdiIcons.close,
                        color: customAppTheme.onError,
                        size: MySize.size18,
                      ),
                      Container(
                        margin: Spacing.left(8),
                        child: Text(
                          Translator.translate("cancel_order"),
                          style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                              color: customAppTheme.onError),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(width: MySize.size16,),
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius:  BorderRadius.circular(4),
                      ))
                  ),
                  onPressed: () {
                    _changeStatus(Order.ORDER_ACCEPTED);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        MdiIcons.check,
                        color: themeData.colorScheme.onPrimary,
                        size: MySize.size18,
                      ),
                      Container(
                        margin: Spacing.left(8),
                        child: Text(
                          Translator.translate("accept"),
                          style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                              color: themeData.colorScheme.onPrimary),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (order.status == 2) {
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius:  BorderRadius.circular(4),
                    ))
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => SelectDeliveryBoyOrderScreen(id: widget.orderId,),
                    ),
                  );
                  _refresh();
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
                        Translator.translate("order_ready"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onPrimary),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }
      return SizedBox(
        height: MySize.size8,
      );
    }
  }

  _billWidget() {
    return Container(
      margin: Spacing.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
          color: customAppTheme.bgLayer1,
          borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
          border: Border.all(color: customAppTheme.bgLayer4, width: 1)),
      padding: Spacing.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Translator.translate("billing_information"),
                style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                    color: themeData.colorScheme.onBackground,
                    fontWeight: 600,
                    muted: true),
              ),
              InkWell(
                onTap: () {
                  UrlUtils.goToOrderReceipt(order.id);
                },
                child: Text(
                  Translator.translate("view_order"),
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyText2,
                    color: themeData.colorScheme.primary,
                    fontWeight: 600,
                  ),
                ),
              )
            ],
          ),
          Container(
            margin: Spacing.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translator.translate("order"),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground),
                ),
                Text(
                  CurrencyApi.getSign(afterSpace: true) +
                      order.order.toString(),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 600),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 4, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translator.translate("tax"),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground),
                ),
                Text(
                  CurrencyApi.getSign(afterSpace: true) + order.tax.toString(),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 600),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 4, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translator.translate("delivery_fee"),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground),
                ),
                Text(
                  CurrencyApi.getSign(afterSpace: true) +
                      CurrencyApi.doubleToString(order.deliveryFee),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 600),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 4, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            margin: Spacing.fromLTRB(16, 4, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translator.translate("total"),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 600),
                ),
                Text(
                  CurrencyApi.getSign(afterSpace: true) +
                      CurrencyApi.doubleToString(order.total),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 600),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 4, 16, 0),
            child: Center(
              child: Text(
                Translator.translate("payment_mode")+" : "+ Order.getOrderPaymentTypeText(order.orderPayment.paymentType),
                style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                    color: themeData.colorScheme.onBackground,
                    fontWeight: 600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _setTimer() {
    //Every 20 sec delivery boy and order location updated
    _timer = new Timer.periodic(
        Duration(seconds: 20), (Timer timer) => _getOrderData());
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
