import 'package:DeliveryBoyApp/AppTheme.dart';
import 'package:DeliveryBoyApp/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';

class LoadingScreens {
  static Widget getOrderLoadingScreen(
      BuildContext context, ThemeData themeData, CustomAppTheme customAppTheme) {
    Widget activeOrder = Shimmer.fromColors(
      baseColor: customAppTheme.shimmerBaseColor,
      highlightColor: customAppTheme.shimmerHighlightColor,
      child: Container(
        padding: Spacing.all(16),
        margin: Spacing.bottom(16),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 12,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: Spacing.only(top: 8.0),
                        child: Container(
                          height: 8,
                          color: Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: Spacing.only(top: 16.0),
                        child: Container(
                          height: 8,
                          color: Colors.grey,
                        ),
                      ),
                      Padding(
                          padding: Spacing.only(top: 8),
                          child: Container(
                            height: 80,
                            width: 80,
                            color: Colors.grey,
                          )),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(),
                ),
                Flexible(
                  flex: 3,
                  child: Container(
                    height: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: Container(),
                ),
                Flexible(
                  flex: 3,
                  child: Container(
                    height: 8,
                    color: Colors.grey,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );

    return Container(
      margin: Spacing.fromLTRB(16, 16, 16, 8),
      child: ListView(
        children: [
          Container(
            child: Text(
              "Active".toUpperCase(),
              style: AppTheme.getTextStyle(
                  themeData.textTheme.caption,
                  color:
                  themeData.colorScheme.onBackground,
                  fontWeight: 700,
                  muted: true),
            ),
          ),
          activeOrder,
          Container(
            margin: Spacing.fromLTRB(0, 8, 0, 8),
            child: Text(
              "Past".toUpperCase(),
              style: AppTheme.getTextStyle(
                  themeData.textTheme.caption,
                  color:
                  themeData.colorScheme.onBackground,
                  fontWeight: 700,
                  muted: true),
            ),
          ),
          activeOrder,
          activeOrder
        ],
      ),
    );
  }

  static Widget getRevenueLoadingScreen(
      BuildContext context, ThemeData themeData, CustomAppTheme customAppTheme) {

    return Shimmer.fromColors(
      baseColor: customAppTheme.shimmerBaseColor,
      highlightColor: customAppTheme.shimmerHighlightColor,
      child: Container(
        padding: Spacing.all(16),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 112,
                    padding: Spacing.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey,
                          ),
                          child: Icon(
                            MdiIcons.wallet,
                            color: themeData.colorScheme.onBackground,
                            size: MySize.size24,
                          ),
                        ),
                        Container(height: 8, width: 32, color: Colors.grey),
                        Container(height: 8, width: 72, color: Colors.grey)
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 24,
                ),
                Expanded(
                  child: Container(
                    height: 112,
                    padding: Spacing.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey,
                          ),
                          child: Icon(
                            MdiIcons.moped,
                            color: themeData.colorScheme.onBackground,
                            size: MySize.size24,
                          ),
                        ),
                        Container(height: 8, width: 32, color: Colors.grey),
                        Container(height: 8, width: 72, color: Colors.grey)
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: Spacing.top(32.0),
              child: Container(height: 8, width: 96, color: Colors.grey),
            ),
            Row(
              children: <Widget>[
                Expanded(
                    child: Padding(
                      padding: Spacing.top(8.0),
                      child: Container(height: 232, color: Colors.grey),
                    )),
              ],
            ),
            Padding(
              padding: Spacing.top(32.0),
              child: Container(height: 8, width: 96, color: Colors.grey),
            ),
            Row(
              children: <Widget>[
                Expanded(
                    child: Padding(
                      padding: Spacing.top(8.0),
                      child: Container(height: 232, color: Colors.grey),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget getSimpleImageScreen(
      BuildContext context, ThemeData themeData, CustomAppTheme customAppTheme,{double width=60,double height=60}) {
    Widget singleLoading = Shimmer.fromColors(
        baseColor: customAppTheme.shimmerBaseColor,
        highlightColor: customAppTheme.shimmerHighlightColor,
        child: Container(
          height: height,
          width: width,
          color: Colors.grey,
        ));
    return singleLoading;
  }


  static Widget getReviewLoadingScreen(
      BuildContext context, ThemeData themeData, CustomAppTheme customAppTheme) {

    return Shimmer.fromColors(
      baseColor: customAppTheme.shimmerBaseColor,
      highlightColor: customAppTheme.shimmerHighlightColor,
      child: Container(
        padding: Spacing.all(16),
        child: Column(
          children: <Widget>[
            Container(
              padding: Spacing.all(16),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 56,
                    width: 56,
                    color: Colors.grey,
                  ),
                  Container(
                    padding: Spacing.only(left: 16),
                    height: 56,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 8,
                          width: 140,
                          color: Colors.grey,
                        ),
                        Container(
                          height: 8,
                          width: 80,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: Spacing.only(top: 32.0,bottom: 16),
              child: Container(
                height: 16,
                width: 120,
                color: Colors.grey,
              ),
            ),
            Container(
              height: 120,
              color: Colors.grey,
            ),

          ],
        ),
      ),
    );

  }

}
