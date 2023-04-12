import 'dart:io';

import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/controllers/ShopController.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/models/Product.dart';
import 'package:ManagerApp/models/Shop.dart';
import 'package:ManagerApp/services/AppLocalizations.dart';
import 'package:ManagerApp/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';
import '../LoadingScreens.dart';

class EditShopScreen extends StatefulWidget {
  @override
  _EditShopScreenState createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShopScreen> {
  //ThemeData
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = new GlobalKey<ScaffoldMessengerState>();


  //Other Variables
  bool isInProgress = false;
  OutlineInputBorder tfBorder;
  Shop shop;

  //File
  File imageFile;
  final picker = ImagePicker();

  //TEC
  TextEditingController teName,
      teEmail,
      teMobile,
      teDescription,
      teAddress,
      teLatitude,
      teLongitude,
      teTax,
      teAdminCommission,
      teMinimumDeliveryCharge,teDeliveryChargeMultiplier,
      teDeliveryRange;

  //Checkbox
  bool cbOpen, cbAvailableForDelivery;

  _pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchShop();
  }

  @override
  void dispose() {
    super.dispose();
    if (teName != null) teName.dispose();
    if (teEmail != null) teEmail.dispose();
    if (teMobile != null) teMobile.dispose();
    if (teDescription != null) teDescription.dispose();
    if (teAddress != null) teAddress.dispose();
    if (teLongitude != null) teLongitude.dispose();
    if (teLatitude != null) teLatitude.dispose();
    if (teTax != null) teTax.dispose();
    if (teAdminCommission != null) teAdminCommission.dispose();
    if (teMinimumDeliveryCharge != null) teMinimumDeliveryCharge.dispose();
    if (teDeliveryChargeMultiplier != null) teDeliveryChargeMultiplier.dispose();
    if (teDeliveryRange != null) teDeliveryRange.dispose();
  }

  _fetchShop() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Shop> myResponse = await ShopController.getShop();

    if (myResponse.success) {
      shop = myResponse.data;
      teName = TextEditingController(text: shop.name);
      teEmail = TextEditingController(text: shop.email);
      teMobile = TextEditingController(text: shop.mobile);
      teDescription = TextEditingController(text: shop.description);
      teAddress = TextEditingController(text: shop.address);
      teLongitude = TextEditingController(text: shop.longitude.toString());
      teLatitude = TextEditingController(text: shop.latitude.toString());
      teTax = TextEditingController(text: shop.tax.toString());
      teAdminCommission =
          TextEditingController(text: shop.adminCommission.toString());
      teMinimumDeliveryCharge = TextEditingController(text: shop.minimumDeliveryCharge.toString());
      teDeliveryChargeMultiplier = TextEditingController(text: shop.deliveryCostMultiplier.toString());
      teDeliveryRange =
          TextEditingController(text: shop.deliveryRange.toString());
      cbAvailableForDelivery = shop.availableForDelivery;
      cbOpen = shop.isOpen;
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

  _saveShop() async {
    if (teName.text.isEmpty) {
      showMessage(message: "Please fill a name");
      return;
    }
    if (teEmail.text.isEmpty) {
      showMessage(message: "Please fill a email");
      return;
    }
    if (teMobile.text.isEmpty) {
      showMessage(message: "Please fill a mobile");
      return;
    }

    if (teDescription.text.isEmpty) {
      showMessage(message: "Please fill a description");
      return;
    }

    if (teAddress.text.isEmpty) {
      showMessage(message: "Please fill a address");
      return;
    }

    if (teLongitude.text.isEmpty) {
      showMessage(message: "Please fill a longitude");
      return;
    }

    if (teLatitude.text.isEmpty) {
      showMessage(message: "Please fill a latitude");
      return;
    }

    if (teTax.text.isEmpty) {
      showMessage(message: "Please fill a tax");
      return;
    }
    if (teAdminCommission.text.isEmpty) {
      showMessage(message: "Please fill a admin commission");
      return;
    }

    if (teMinimumDeliveryCharge.text.isEmpty) {
      showMessage(message: "Please fill a minimum delivery charge");
      return;
    }

    if (teDeliveryChargeMultiplier.text.isEmpty) {
      showMessage(message: "Please fill a delivery charge multiplier");
      return;
    }
    if (teDeliveryRange.text.isEmpty) {
      showMessage(message: "Please fill a delivery range");
      return;
    }

    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse = await ShopController.updateShop(
        id: shop.id,
        name: teName.text,
        email: teEmail.text,
        mobile: teMobile.text,
        description: teDescription.text,
        address: teAddress.text,
        latitude: teLatitude.text,
        longitude: teLongitude.text,
        deliveryChargeMultiplier: teDeliveryChargeMultiplier.text,
        minimumDeliveryCharge: teMinimumDeliveryCharge.text,
        adminCommission: teAdminCommission.text,
        tax: teTax.text,
        deliveryRange: teDeliveryRange.text,
        open: cbOpen,
        availableForDelivery: cbAvailableForDelivery,
        imageFile: imageFile);

    if (myResponse.success) {
      showMessage(message: "Shop updated");
    } else {
      showMessage(message: "Shop is not updated");
    }

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  _initUI() {
    tfBorder = OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(MySize.size8),
        ),
        borderSide: BorderSide(color: customAppTheme.bgLayer4, width: 1.5));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        _initUI();

        return MaterialApp(
          scaffoldMessengerKey: _scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(themeType),
            home: Scaffold(
              key: _scaffoldKey,
              backgroundColor: customAppTheme.bgLayer2,
              appBar: AppBar(
                leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    MdiIcons.chevronLeft,
                    size: MySize.size20,
                    color: themeData.colorScheme.onBackground,
                  ),
                ),
                elevation: 0,
                backgroundColor: customAppTheme.bgLayer2,
                title: Text(
                  shop != null ? shop.name : "Loading",
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.headline6,
                    color: themeData.colorScheme.onBackground,
                    fontWeight: 600,
                  ),
                ),
                centerTitle: true,
                actions: [
                  InkWell(
                    onTap: () {
                      _saveShop();
                    },
                    child: Container(
                        margin: Spacing.right(16),
                        child: Icon(
                          MdiIcons.check,
                          color: themeData.colorScheme.onBackground,
                          size: MySize.size20,
                        )),
                  )
                ],
              ),
              body: Column(
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
                      children: [_buildBody()],
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  _buildBody() {
    if (isInProgress) {
      return LoadingScreens.getOrderLoadingScreen(
          context, themeData, customAppTheme);
    } else if(shop!=null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              _pickImage();
            },
            child: Container(
              margin: Spacing.horizontal(24),
              padding: Spacing.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MySize.size8),
                border: Border.all(color: customAppTheme.bgLayer4, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.all(Radius.circular(MySize.size8)),
                    child: imageFile != null
                        ? Image.file(
                            imageFile,
                            height: MySize.getScaledSizeWidth(120),
                            fit: BoxFit.cover,
                          )
                        : shop.imageUrl != null
                            ? Image.network(
                                shop.imageUrl,
                                loadingBuilder: (BuildContext ctx, Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return LoadingScreens.getSimpleImageScreen(
                                        context, themeData, customAppTheme,
                                        width: MySize.size90,
                                        height: MySize.size90);
                                  }
                                },
                                height: MySize.size120,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                Product.getPlaceholderImage(),
                                height: MySize.size120,
                                fit: BoxFit.cover,
                              ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(MdiIcons.cloudUploadOutline,
                          size: MySize.size26,
                          color: themeData.colorScheme.onBackground),
                      SizedBox(
                        height: MySize.size4,
                      ),
                      Text(
                        Translator.translate("choose_image"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onBackground),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 16, 24, 0),
            padding: Spacing.fromLTRB(16, 6, 16, 6),
            decoration: BoxDecoration(
                color: customAppTheme.bgLayer3,
                borderRadius: BorderRadius.circular(MySize.size4)),
            child: Text(
              Translator.translate("general"),
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 600,
                  muted: true),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 16, 24, 0),
            child: TextFormField(
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                  letterSpacing: 0.1,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 500),
              decoration: InputDecoration(
                  hintText: Translator.translate("name"),
                  hintStyle: AppTheme.getTextStyle(
                      themeData.textTheme.subtitle2,
                      letterSpacing: 0.1,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 500),
                  border: tfBorder,
                  enabledBorder: tfBorder,
                  focusedBorder: tfBorder,
                  prefixIcon: Icon(
                    MdiIcons.text,
                    size: MySize.size22,
                  ),
                  isDense: true,
                  contentPadding: Spacing.zero),
              keyboardType: TextInputType.text,
              controller: teName,
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 16, 24, 0),
            child: TextFormField(
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                  letterSpacing: 0.1,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 500),
              decoration: InputDecoration(
                  hintText: Translator.translate("email"),
                  hintStyle: AppTheme.getTextStyle(
                      themeData.textTheme.subtitle2,
                      letterSpacing: 0.1,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 500),
                  border: tfBorder,
                  enabledBorder: tfBorder,
                  focusedBorder: tfBorder,
                  prefixIcon: Icon(
                    MdiIcons.emailOutline,
                    size: MySize.size22,
                  ),
                  isDense: true,
                  contentPadding: Spacing.zero),
              keyboardType: TextInputType.emailAddress,
              controller: teEmail,
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 16, 24, 0),
            child: TextFormField(
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                  letterSpacing: 0.1,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 500),
              decoration: InputDecoration(
                  hintText: Translator.translate("phone"),
                  hintStyle: AppTheme.getTextStyle(
                      themeData.textTheme.subtitle2,
                      letterSpacing: 0.1,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 500),
                  border: tfBorder,
                  enabledBorder: tfBorder,
                  focusedBorder: tfBorder,
                  prefixIcon: Icon(
                    MdiIcons.phoneOutline,
                    size: MySize.size22,
                  ),
                  isDense: true,
                  contentPadding: Spacing.zero),
              keyboardType: TextInputType.number,
              controller: teMobile,
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 16, 24, 0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: Translator.translate("description"),
                isDense: true,
                border: tfBorder,
                enabledBorder: tfBorder,
                focusedBorder: tfBorder,
              ),
              textCapitalization: TextCapitalization.sentences,
              minLines: 5,
              maxLines: 10,
              controller: teDescription,
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 24, 24, 0),
            padding: Spacing.fromLTRB(16, 6, 16, 6),
            decoration: BoxDecoration(
                color: customAppTheme.bgLayer3,
                borderRadius: BorderRadius.circular(MySize.size4)),
            child: Text(
              Translator.translate("location"),
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 600,
                  muted: true),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 16, 24, 0),
            child: TextFormField(
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                  letterSpacing: 0.1,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 500),
              decoration: InputDecoration(
                  hintText: Translator.translate("address"),
                  hintStyle: AppTheme.getTextStyle(
                      themeData.textTheme.subtitle2,
                      letterSpacing: 0.1,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 500),
                  border: tfBorder,
                  enabledBorder: tfBorder,
                  focusedBorder: tfBorder,
                  prefixIcon: Icon(
                    MdiIcons.mapMarkerOutline,
                    size: MySize.size22,
                  ),
                  isDense: true,
                  contentPadding: Spacing.zero),
              keyboardType: TextInputType.streetAddress,
              controller: teAddress,
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 16, 24, 0),
            child: TextFormField(
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                  letterSpacing: 0.1,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 500),
              decoration: InputDecoration(
                  hintText: Translator.translate("latitude"),
                  hintStyle: AppTheme.getTextStyle(
                      themeData.textTheme.subtitle2,
                      letterSpacing: 0.1,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 500),
                  border: tfBorder,
                  enabledBorder: tfBorder,
                  focusedBorder: tfBorder,
                  prefixIcon: Icon(
                    MdiIcons.latitude,
                    size: MySize.size22,
                  ),
                  isDense: true,
                  contentPadding: Spacing.zero),
              keyboardType: TextInputType.number,
              controller: teLatitude,
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 16, 24, 0),
            child: TextFormField(
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                  letterSpacing: 0.1,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 500),
              decoration: InputDecoration(
                  hintText: Translator.translate("longitude"),
                  hintStyle: AppTheme.getTextStyle(
                      themeData.textTheme.subtitle2,
                      letterSpacing: 0.1,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 500),
                  border: tfBorder,
                  enabledBorder: tfBorder,
                  focusedBorder: tfBorder,
                  prefixIcon: Icon(
                    MdiIcons.longitude,
                    size: MySize.size22,
                  ),
                  isDense: true,
                  contentPadding: Spacing.zero),
              keyboardType: TextInputType.number,
              controller: teLongitude,
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 24, 24, 0),
            padding: Spacing.fromLTRB(16, 6, 16, 6),
            decoration: BoxDecoration(
                color: customAppTheme.bgLayer3,
                borderRadius: BorderRadius.circular(MySize.size4)),
            child: Text(
              Translator.translate("delivery_boy"),
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 600,
                  muted: true),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 0, 24, 0),
            child: Row(
              children: [
                Container(
                  child: Checkbox(
                    visualDensity: VisualDensity.compact,
                    onChanged: (value) {
                      setState(() {
                        cbAvailableForDelivery = value;
                      });
                    },
                    value: cbAvailableForDelivery,
                  ),
                ),
                Text(
                  Translator.translate("available_for_delivery"),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground),
                )
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 16, 24, 0),
            child: TextFormField(
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                  letterSpacing: 0.1,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 500),
              decoration: InputDecoration(
                  hintText: Translator.translate("delivery_range"),
                  hintStyle: AppTheme.getTextStyle(
                      themeData.textTheme.subtitle2,
                      letterSpacing: 0.1,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 500),
                  border: tfBorder,
                  enabledBorder: tfBorder,
                  focusedBorder: tfBorder,
                  prefixIcon: Icon(
                    MdiIcons.mapMarkerDistance,
                    size: MySize.size22,
                  ),
                  isDense: true,
                  contentPadding: Spacing.left(16)),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              controller: teDeliveryRange,
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 16, 24, 0),
            child: TextFormField(
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                  letterSpacing: 0.1,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 500),
              decoration: InputDecoration(
                  hintText: Translator.translate("minimum_delivery_charge"),
                  hintStyle: AppTheme.getTextStyle(
                      themeData.textTheme.subtitle2,
                      letterSpacing: 0.1,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 500),
                  border: tfBorder,
                  enabledBorder: tfBorder,
                  focusedBorder: tfBorder,
                  prefixIcon: Icon(
                    MdiIcons.mopedOutline,
                    size: MySize.size22,
                  ),
                  isDense: true,
                  contentPadding: Spacing.left(16)),
              keyboardType: TextInputType.number,
              controller: teMinimumDeliveryCharge,
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 16, 24, 0),
            child: TextFormField(
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                  letterSpacing: 0.1,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 500),
              decoration: InputDecoration(
                  hintText: Translator.translate("delivery_charge_multiplier"),
                  hintStyle: AppTheme.getTextStyle(
                      themeData.textTheme.subtitle2,
                      letterSpacing: 0.1,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 500),
                  border: tfBorder,
                  enabledBorder: tfBorder,
                  focusedBorder: tfBorder,
                  prefixIcon: Icon(
                    MdiIcons.mopedElectricOutline,
                    size: MySize.size22,
                  ),
                  isDense: true,
                  contentPadding: Spacing.left(16)),
              keyboardType: TextInputType.number,
              controller: teDeliveryChargeMultiplier,
            ),
          ),

          Container(
            margin: Spacing.fromLTRB(24, 24, 24, 0),
            padding: Spacing.fromLTRB(16, 6, 16, 6),
            decoration: BoxDecoration(
                color: customAppTheme.bgLayer3,
                borderRadius: BorderRadius.circular(MySize.size4)),
            child: Text(
              Translator.translate("other"),
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 600,
                  muted: true),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 0, 24, 0),
            child: Row(
              children: [
                Container(
                  child: Checkbox(
                    visualDensity: VisualDensity.compact,
                    onChanged: (value) {
                      setState(() {
                        cbOpen = value;
                      });
                    },
                    value: cbOpen,
                  ),
                ),
                Text(
                  Translator.translate("open"),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground),
                )
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 16, 24, 0),
            child: TextFormField(
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                  letterSpacing: 0.1,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 500),
              decoration: InputDecoration(
                  hintText: Translator.translate("tax"),
                  hintStyle: AppTheme.getTextStyle(
                      themeData.textTheme.subtitle2,
                      letterSpacing: 0.1,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 500),
                  border: tfBorder,
                  enabledBorder: tfBorder,
                  focusedBorder: tfBorder,
                  suffixIcon: Icon(
                    MdiIcons.percentOutline,
                    size: MySize.size22,
                  ),
                  isDense: true,
                  contentPadding: Spacing.left(16)),
              keyboardType: TextInputType.number,
              controller: teTax,
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 16, 24, 24),
            child: TextFormField(
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                  letterSpacing: 0.1,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 500),
              decoration: InputDecoration(
                  hintText: Translator.translate("admin_commission"),
                  hintStyle: AppTheme.getTextStyle(
                      themeData.textTheme.subtitle2,
                      letterSpacing: 0.1,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 500),
                  border: tfBorder,
                  enabledBorder: tfBorder,
                  focusedBorder: tfBorder,
                  suffixIcon: Icon(
                    MdiIcons.percentOutline,
                    size: MySize.size22,
                  ),
                  isDense: true,
                  contentPadding: Spacing.left(16)),
              keyboardType: TextInputType.number,
              controller: teAdminCommission,
            ),
          ),

        ],
      );
    }else{
      return Center(child: Text("something wrong"),);
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
