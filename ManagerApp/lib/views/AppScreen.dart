
import 'package:ManagerApp/utils/SizeConfig.dart';
import 'package:ManagerApp/views/DashboardScreen.dart';
import 'package:ManagerApp/views/order/OrdersScreen.dart';
import 'package:ManagerApp/views/auth/SettingScreen.dart';
import 'package:ManagerApp/views/product/ProductsScreen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../AppTheme.dart';
import '../AppThemeNotifier.dart';

class AppScreen extends StatefulWidget {
  final int selectedPage;

  const AppScreen({Key key, this.selectedPage = 0}) : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;

  TabController _tabController;

  _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);
    _tabController.addListener(_handleTabSelection);

    super.initState();
  }


  dispose() {
    super.dispose();
    _tabController.dispose();
  }

  ThemeData themeData;
  CustomAppTheme customAppTheme;


  Widget build(BuildContext context) {

    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        int themeMode = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeMode);
        customAppTheme = AppTheme.getCustomAppTheme(themeMode);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
          home: Scaffold(
            backgroundColor: customAppTheme.bgLayer2,
            bottomNavigationBar: BottomAppBar(
                elevation: 0,
                shape: CircularNotchedRectangle(),
                child: Container(
                  decoration: BoxDecoration(
                    color: customAppTheme.bgLayer2,
                    boxShadow: [
                      BoxShadow(
                        color: themeData.cardTheme.shadowColor.withAlpha(40),
                        blurRadius: 3,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  padding: Spacing.only(top: 12, bottom: 12),
                  child: TabBar(
                    physics: ClampingScrollPhysics(),
                    controller: _tabController,
                    indicator: BoxDecoration(),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: themeData.colorScheme.primary,
                    tabs: <Widget>[
                      Container(
                        child: (_currentIndex == 0)
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    MdiIcons.viewDashboard,
                                    color: themeData.colorScheme.primary,
                                  ),
                                  Container(
                                    margin: Spacing.top(4),
                                    decoration: BoxDecoration(
                                        color: themeData.primaryColor,
                                        borderRadius: new BorderRadius.all(
                                            Radius.circular(2.5))),
                                    height: 5,
                                    width: 5,
                                  )
                                ],
                              )
                            : Icon(
                                MdiIcons.viewDashboardOutline,
                                color: themeData.colorScheme.onBackground,
                              ),
                      ),
                      Container(

                          child: (_currentIndex == 1)
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      MdiIcons.shopping,
                                      color: themeData.colorScheme.primary,
                                    ),
                                    Container(
                                      margin: Spacing.top(4),
                                      decoration: BoxDecoration(
                                          color: themeData.primaryColor,
                                          borderRadius: new BorderRadius.all(
                                              Radius.circular(2.5))),
                                      height: 5,
                                      width: 5,
                                    )
                                  ],
                                )
                              : Icon(
                                  MdiIcons.shoppingOutline,
                                  color: themeData.colorScheme.onBackground,
                                )),
                      Container(

                          child: (_currentIndex == 2)
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      MdiIcons.hexagonMultiple,
                                      color: themeData.colorScheme.primary,
                                    ),
                                    Container(
                                      margin: Spacing.top(4),
                                      decoration: BoxDecoration(
                                          color: themeData.primaryColor,
                                          borderRadius: new BorderRadius.all(
                                              Radius.circular(2.5))),
                                      height: 5,
                                      width: 5,
                                    )
                                  ],
                                )
                              : Icon(
                                  MdiIcons.hexagonMultipleOutline,
                                  color: themeData.colorScheme.onBackground,
                                )),
                      Container(
                          child: (_currentIndex == 3)
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      MdiIcons.account,
                                      color: themeData.colorScheme.primary,
                                    ),
                                    Container(
                                      margin: Spacing.top(4),
                                      decoration: BoxDecoration(
                                          color: themeData.primaryColor,
                                          borderRadius: new BorderRadius.all(
                                              Radius.circular(2.5))),
                                      height: 5,
                                      width: 5,
                                    )
                                  ],
                                )
                              : Icon(
                                  MdiIcons.accountOutline,
                                  color: themeData.colorScheme.onBackground,
                                )),
                    ],
                  ),
                )),

            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            body: TabBarView(
              controller: _tabController,
              children: <Widget>[
                DashboardScreen(),
                OrdersScreen(),
                ProductsScreen(),
                SettingScreen()
              ],
            ),
          ),
        );
      },
    );
  }

}
