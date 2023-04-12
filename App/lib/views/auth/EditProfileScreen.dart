import 'dart:io';

import 'package:DeliveryBoyApp/api/api_util.dart';
import 'package:DeliveryBoyApp/controllers/AuthController.dart';
import 'package:DeliveryBoyApp/models/DeliveryBoy.dart';
import 'package:DeliveryBoyApp/models/MyResponse.dart';
import 'package:DeliveryBoyApp/services/AppLocalizations.dart';
import 'package:DeliveryBoyApp/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  //ThemeData
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Text Field Editing Controller
  TextEditingController mobileTFController;
  TextEditingController passwordTFController;

  //Global Key
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = new GlobalKey<ScaffoldMessengerState>();


  //Other Variable
  OutlineInputBorder allTFBorder;
  bool showPassword = false;

  //Other Variables
  DeliveryBoy deliveryBoy;
  bool isInProgress = false;
  File imageFile;
  final picker = ImagePicker();


  _initUserData() async {
    DeliveryBoy user = await AuthController.getUser();
    setState(() {
      deliveryBoy = user;
    });
  }

  @override
  void initState() {
    super.initState();
    _initUserData();
    mobileTFController = TextEditingController();
    passwordTFController = TextEditingController();
  }

  @override
  void dispose() {
    mobileTFController.dispose();
    passwordTFController.dispose();
    super.dispose();
  }

  _initUI() {
    allTFBorder = OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
        borderSide: BorderSide(color: customAppTheme.bgLayer4, width: 1.5));
  }

  _handleUpdate() async {
    String mobile = mobileTFController.text;
    String password = passwordTFController.text;

    if(mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse = await AuthController.updateUser(mobile, password,imageFile);
    if(mounted) {
      setState(() {
        isInProgress = false;
      });
    }

    if (myResponse.success) {
      showMessage(message: Translator.translate("updated_successfully"));
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }
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
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
              key: _scaffoldKey,
                appBar: AppBar(
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      MdiIcons.chevronLeft,
                      color: themeData.colorScheme.onBackground,
                    ),
                  ),
                  centerTitle: true,
                  title: Text(
                    Translator.translate("profile"),
                    style: AppTheme.getTextStyle(themeData.textTheme.headline6,
                        color: themeData.colorScheme.onBackground,fontWeight: 600),
                  ),
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
                    Expanded(child: _buildBody())
                  ],
                )));
      },
    );
  }

  _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
      }
    });
  }

  _buildBody() {
    if (deliveryBoy == null) {
      return Container();
    } else {
      return ListView(
        children: <Widget>[
          Container(
            margin: Spacing.top(48),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap:(){
                    _getImage();
                  },
                  child: Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                          Radius.circular(MySize.getScaledSizeWidth(60))),
                      child: imageFile==null ?  Image.network(
                        deliveryBoy.getAvatarUrl(),
                        height: MySize.getScaledSizeWidth(120),
                        width: MySize.getScaledSizeWidth(120),
                        fit: BoxFit.cover,
                      ) :  Image.file(
                        imageFile,
                        height: MySize.getScaledSizeWidth(120),
                        width: MySize.getScaledSizeWidth(120),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: Spacing.top(16),
                  child: Text(deliveryBoy.name,
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.headline6,
                          fontWeight: 600,
                          letterSpacing: 0)),
                ),
                Text(deliveryBoy.email,
                    style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                        fontWeight: 500)),
              ],
            ),
          ),
          Container(
            padding: Spacing.all(36),
            child: Column(
              children: <Widget>[
                Container(
                  margin: Spacing.top(16),
                  child: TextFormField(
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                        letterSpacing: 0.1,
                        color: themeData.colorScheme.onBackground,
                        fontWeight: 500),
                    decoration: InputDecoration(
                        hintText: Translator.translate("mobile"),
                        hintStyle: AppTheme.getTextStyle(
                            themeData.textTheme.subtitle2,
                            letterSpacing: 0.1,
                            color: themeData.colorScheme.onBackground,
                            fontWeight: 500),
                        border: allTFBorder,
                        enabledBorder: allTFBorder,
                        focusedBorder: allTFBorder,
                        prefixIcon: Icon(
                          MdiIcons.phoneOutline,
                          size: MySize.size22,
                        ),
                        isDense: true,
                        contentPadding: Spacing.zero),
                    keyboardType: TextInputType.emailAddress,
                    controller: mobileTFController,
                  ),
                ),
                Container(
                  margin: Spacing.top(24),
                  child: TextFormField(
                    obscureText: showPassword,
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                        letterSpacing: 0.1,
                        color: themeData.colorScheme.onBackground,
                        fontWeight: 500),
                    decoration: InputDecoration(
                      hintStyle: AppTheme.getTextStyle(
                          themeData.textTheme.subtitle2,
                          letterSpacing: 0.1,
                          color: themeData.colorScheme.onBackground,
                          fontWeight: 500),
                      hintText: Translator.translate("change_password"),
                      border: allTFBorder,
                      enabledBorder: allTFBorder,
                      focusedBorder: allTFBorder,
                      prefixIcon: Icon(
                        MdiIcons.lockOutline,
                        size: 22,
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        child: Icon(
                          showPassword
                              ? MdiIcons.eyeOutline
                              : MdiIcons.eyeOffOutline,
                          size: MySize.size22,
                        ),
                      ),
                      isDense: true,
                      contentPadding: Spacing.zero,
                    ),
                    controller: passwordTFController,
                    keyboardType: TextInputType.visiblePassword,
                  ),
                ),
                Container(
                  margin: Spacing.top(24),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(Radius.circular(MySize.size8)),
                    boxShadow: [
                      BoxShadow(
                        color: themeData.colorScheme.primary.withAlpha(20),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius:  BorderRadius.circular(4),
                          ))
                      ),
                      onPressed: () {
                        _handleUpdate();
                      },
                      child: Text(Translator.translate("update").toUpperCase(),
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.caption,
                              fontWeight: 600,
                              color: themeData.colorScheme.onPrimary,
                              letterSpacing: 0.4))),
                ),
              ],
            ),
          ),
        ],
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
