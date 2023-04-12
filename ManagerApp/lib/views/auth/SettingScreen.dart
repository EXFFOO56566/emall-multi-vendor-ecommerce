import 'package:ManagerApp/controllers/AuthController.dart';
import 'package:ManagerApp/models/Account.dart';
import 'package:ManagerApp/services/AppLocalizations.dart';
import 'package:ManagerApp/utils/SizeConfig.dart';
import 'package:ManagerApp/views/EditCouponsScreen.dart';
import 'package:ManagerApp/views/ProductReviewsScreen.dart';
import 'package:ManagerApp/views/TransactionScreen.dart';
import 'package:ManagerApp/views/shop/EditShopScreen.dart';
import 'package:ManagerApp/views/shop/ShopReviewsScreen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';
import '../EditDeliveryBoysScreen.dart';
import '../SelectLanguageDialog.dart';
import '../SelectThemeDialog.dart';
import 'EditProfileScreen.dart';
import 'LoginScreen.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //User
  Account account;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    Account cacheAccount = await AuthController.getAccount();
    setState(() {
      account = cacheAccount;
    });
  }

  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeData,
            home: Scaffold(
                backgroundColor: customAppTheme.bgLayer2,
                appBar: AppBar(
                  backgroundColor: customAppTheme.bgLayer2,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(Translator.translate("setting"),
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.headline6,
                          fontWeight: 600)),
                ),
                body: buildBody()));
      },
    );
  }

  buildBody() {
    if (account != null) {
      return ListView(
        children: <Widget>[
          Container(
            margin: Spacing.fromLTRB(24, 0, 24, 0),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => EditProfileScreen(),
                  ),
                );
                _initData();
              },
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.all(
                        Radius.circular(MySize.getScaledSizeWidth(24))),
                    child: Image.network(
                      account.getAvatarUrl(),
                      height: MySize.getScaledSizeWidth(48),
                      width: MySize.getScaledSizeWidth(48),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    margin: Spacing.left(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(account.name,
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.subtitle1,
                                fontWeight: 700,
                                letterSpacing: 0)),
                        Text(account.email,
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.caption,
                                fontWeight: 600,
                                letterSpacing: 0.3)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        child: Icon(
                          MdiIcons.chevronRight,
                          color: themeData.colorScheme.onBackground,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 40, 24, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: Spacing.all(16),
                    decoration: BoxDecoration(
                      color: themeData.cardTheme.color,
                      border: Border.all(
                          width: 1.2, color: customAppTheme.bgLayer4),
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size8)),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ProductReviewsScreen()));
                      },
                      child: Column(
                        children: <Widget>[
                          Icon(
                            MdiIcons.starOutline,
                            color: themeData.colorScheme.onBackground,
                          ),
                          Container(
                              margin: Spacing.top(8),
                              child: Text(
                                Translator.translate("reviews"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText2,
                                    fontWeight: 600),
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MySize.size16,
                ),
                Expanded(
                  child: Container(
                    padding: Spacing.all(16),
                    decoration: BoxDecoration(
                      color: themeData.cardTheme.color,
                      border: Border.all(
                          width: 1.2, color: customAppTheme.bgLayer4),
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size8)),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    EditShopScreen()));
                      },
                      child: Column(
                        children: <Widget>[
                          Icon(
                            MdiIcons.storeOutline,
                            color: themeData.colorScheme.onBackground,
                          ),
                          Container(
                              margin: Spacing.top(8),
                              child: Text(
                                Translator.translate("my_shop"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText2,
                                    fontWeight: 600),
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MySize.size16,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              SelectThemeDialog());
                    },
                    child: Container(
                      padding: Spacing.all(16),
                      decoration: BoxDecoration(
                        color: themeData.cardTheme.color,
                        border: Border.all(
                            width: 1.2, color: customAppTheme.bgLayer4),
                        borderRadius:
                            BorderRadius.all(Radius.circular(MySize.size8)),
                      ),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            MdiIcons.eyeOutline,
                            color: themeData.colorScheme.onBackground,
                          ),
                          Container(
                              margin: Spacing.top(8),
                              child: Text(
                                Translator.translate("theme"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText2,
                                    fontWeight: 700),
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 8, 16, 0),
            child: ListTile(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            TransactionScreen()));
              },
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: Icon(
                MdiIcons.bankTransfer,
                size: MySize.size24,
                color: themeData.colorScheme.onBackground,
              ),
              title: Text(
                Translator.translate("transactions"),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyText2,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 600,
                ),
              ),
              trailing: Icon(
                MdiIcons.chevronRight,
                size: MySize.size20,
                color: themeData.colorScheme.onBackground,
              ),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 0, 16, 0),
            child: ListTile(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ShopReviewsScreen()));
              },
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: Icon(
                MdiIcons.starOutline,
                size: MySize.size20,
                color: themeData.colorScheme.onBackground,
              ),
              title: Text(
                Translator.translate("shop_reviews"),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyText2,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 600,
                ),
              ),
              trailing: Icon(
                MdiIcons.chevronRight,
                size: MySize.size20,
                color: themeData.colorScheme.onBackground,
              ),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 0, 16, 0),
            child: ListTile(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            EditCouponsScreen()));
              },
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: Icon(
                MdiIcons.tagOutline,
                size: MySize.size20,
                color: themeData.colorScheme.onBackground,
              ),
              title: Text(
                Translator.translate("coupons"),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyText2,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 600,
                ),
              ),
              trailing: Icon(
                MdiIcons.chevronRight,
                size: MySize.size20,
                color: themeData.colorScheme.onBackground,
              ),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 0, 16, 0),
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            EditDeliveryBoysScreen()));

              },
              leading: Icon(
                MdiIcons.mopedOutline,
                size: MySize.size20,
                color: themeData.colorScheme.onBackground,
              ),
              title: Text(
                Translator.translate("delivery_boy"),
                style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                    fontWeight: 600),
              ),
              trailing: Icon(Icons.chevron_right,
                  size: MySize.size20,
                  color: themeData.colorScheme.onBackground),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 0, 16, 0),
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => SelectLanguageDialog());
              },
              leading: Icon(
                MdiIcons.translate,
                size: MySize.size20,
                color: themeData.colorScheme.onBackground,
              ),
              title: Text(
                Translator.translate("select_language"),
                style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                    fontWeight: 600),
              ),
              trailing: Icon(Icons.chevron_right,
                  size: MySize.size20,
                  color: themeData.colorScheme.onBackground),
            ),
          ),
          Container(
            margin: Spacing.top(16),
            child: Center(
              child: ElevatedButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius:  BorderRadius.circular(4),
                    ))
                ),
                onPressed: () async {
                  await AuthController.logoutUser();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => LoginScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(MdiIcons.logoutVariant,
                        size: MySize.size20,
                        color: themeData.colorScheme.onPrimary),
                    Container(
                      margin: Spacing.left(16),
                      child: Text(Translator.translate("logout").toUpperCase(),
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.caption,
                              fontWeight: 600,
                              color: themeData.colorScheme.onPrimary,
                              letterSpacing: 0.3)),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return Container();
    }
  }
}
