import 'package:DeliveryBoyApp/AppTheme.dart';
import 'package:DeliveryBoyApp/api/api_util.dart';
import 'package:DeliveryBoyApp/controllers/DeliveryBoyReviewController.dart';
import 'package:DeliveryBoyApp/models/DeliveryBoyReview.dart';
import 'package:DeliveryBoyApp/models/MyResponse.dart';
import 'package:DeliveryBoyApp/services/AppLocalizations.dart';
import 'package:DeliveryBoyApp/utils/ColorUtils.dart';
import 'package:DeliveryBoyApp/utils/Generator.dart';
import 'package:DeliveryBoyApp/utils/SizeConfig.dart';
import 'package:DeliveryBoyApp/utils/TextUtils.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../AppThemeNotifier.dart';
import 'LoadingScreens.dart';

class ReviewsScreen extends StatefulWidget {


  const ReviewsScreen({Key key})
      : super(key: key);

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  //Theme Data
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = new GlobalKey<ScaffoldMessengerState>();


  //Other Variables
  bool isInProgress = false;
  List<DeliveryBoyReview> deliveryBoyReviews;
  List<int> ratingList;
  double rating=0;

  int maxRating;

  @override
  void initState() {
    super.initState();
    _getReviewData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getReviewData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<DeliveryBoyReview>> myResponse =
        await DeliveryBoyReviewController.getAllReviews();

    if (myResponse.success) {
      deliveryBoyReviews = myResponse.data;
      _makingRatingList();
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

  _makingRatingList() {
    if (ratingList == null) {
      ratingList = [0, 0, 0, 0, 0, 0];
      for (int i = 0; i < deliveryBoyReviews.length; i++) {
        ratingList[deliveryBoyReviews[i].rating]++;
        rating+=deliveryBoyReviews[i].rating;
      }

      if(deliveryBoyReviews.length!=0)
        rating = rating/deliveryBoyReviews.length;


      int max = 0;
      for (int i = 1; i < 6; i++) {
        if (ratingList[i] > max) max = ratingList[i];
      }

      setState(() {
        maxRating = max;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
        builder: (BuildContext context, AppThemeNotifier value, Widget child) {
      themeData = AppTheme.getThemeFromThemeMode(value.themeMode());
      customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
      return MaterialApp(
        scaffoldMessengerKey: _scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
          home: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                backgroundColor: customAppTheme.bgLayer2,
                elevation: 0,
                leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(MdiIcons.chevronLeft),
                ),
                centerTitle: true,
                title: Text(Translator.translate("ratings_and_reviews"),
                    style: AppTheme.getTextStyle(
                        themeData.appBarTheme.textTheme.headline6,
                        fontWeight: 600)),
              ),
              backgroundColor: customAppTheme.bgLayer2,
              body: Container(
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
                    Expanded(child: buildBody()),
                  ],
                ),
              )));
    });
  }

  buildBody() {
    if (deliveryBoyReviews != null) {
      return ListView(
        padding: Spacing.zero,
        children: [
          Container(
            margin: Spacing.horizontal(16),
            padding: Spacing.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
                color: customAppTheme.bgLayer1,
                borderRadius: BorderRadius.all(Radius.circular(MySize.size4)),
                border: Border.all(color: customAppTheme.bgLayer4, width: 1)),
            child: _buildRatingWidget(),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 16, 0, 0),
            child: Text(
              Translator.translate("reviews"),
              style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                  color: themeData.colorScheme.onBackground,
                  muted: true,
                  fontWeight: 700),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 16, 0, 0),
            child: _buildReviewWidget(deliveryBoyReviews),
          )
        ],
      );
    } else if (isInProgress) {
      return LoadingScreens.getReviewLoadingScreen(
          context, themeData, customAppTheme);
    } else {
      return Center(
        child: Text("Something wrong"),
      );
    }
  }

  _buildRatingWidget() {
    List<Widget> list = [];
    maxRating = maxRating == 0 ? 1 : maxRating;
    for (int i = 5; i > 0; i--) {
      int progress = ((ratingList[i] / maxRating) * 100).ceil();
      list.add(Row(
        children: [
          Container(
            child: Text(
              i.toString(),
              style: AppTheme.getTextStyle(themeData.textTheme.caption,
                  fontSize: 12,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 600),
            ),
          ),
          Container(
            margin: Spacing.left(2),
            child: Icon(
              MdiIcons.star,
              color: themeData.colorScheme.onBackground,
              size: MySize.size12,
            ),
          ),
          Expanded(
            child: Container(
              margin: Spacing.left(8),
              height: 4,
              decoration: BoxDecoration(
                  color: themeData.colorScheme.onBackground.withAlpha(60),
                  borderRadius:
                      BorderRadius.all(Radius.circular(MySize.size4))),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: progress,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                          color: Generator.getColorByRating(customAppTheme)[i],
                          borderRadius:
                              BorderRadius.all(Radius.circular(MySize.size4))),
                    ),
                  ),
                  Expanded(
                    flex: 100 - progress,
                    child: Container(),
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: Spacing.left(8),
            child: Text(
              ratingList[i].toString(),
              style: AppTheme.getTextStyle(themeData.textTheme.caption,
                  color: themeData.colorScheme.onBackground, muted: true),
            ),
          )
        ],
      ));
    }

    return Container(
        margin: Spacing.top(8),
        child: Row(
          children: [
            Container(
              margin: Spacing.fromLTRB(8, 0, 16, 0),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: Spacing.fromLTRB(0, 4, 2, 0),
                          child: Text(
                            TextUtils.doubleToString(rating),
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText2,
                                color: themeData.colorScheme.onBackground,
                                fontWeight: 600,
                                letterSpacing: 0.25),
                          ),
                        ),
                        Icon(
                          MdiIcons.star,
                          color: themeData.colorScheme.onBackground,
                          size: MySize.size20,
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: Spacing.top(4),
                    child: Text(
                          deliveryBoyReviews.length.toString()+
                          " " +
                          Translator.translate("ratings"),
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.bodyText2,
                          color: themeData.colorScheme.onBackground,
                          muted: true),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: list,
              ),
            ),
          ],
        ));
  }

  _buildReviewWidget(List<DeliveryBoyReview> reviews) {
    if (reviews.length == 0)
      return Center(
        child: Container(
          child: Text(
            Translator.translate("there_is_no_review_yet"),
            style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                color: themeData.colorScheme.onBackground, fontWeight: 500),
          ),
        ),
      );

    List<Widget> list = [];
    for (DeliveryBoyReview review in reviews) list.add(_singleReview(review));

    return Container(
      child: Column(
        children: list,
      ),
    );
  }

  _singleReview(DeliveryBoyReview review) {
    return Container(
      margin: Spacing.bottom(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(
                      Radius.circular(MySize.getScaledSizeWidth(17))),
                  child: Image.network(
                    review.user.getAvatarUrl(),
                    height: MySize.getScaledSizeWidth(34),
                    width: MySize.getScaledSizeWidth(34),
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  margin: Spacing.left(12),
                  child: Text(
                    review.user.name,
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.onBackground,
                        fontWeight: 600),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.top(8),
            child: Row(
              children: [
                Generator.buildRatingStar(
                    activeColor: ColorUtils.getColorFromRating(
                        review.rating, customAppTheme, themeData),
                    inactiveColor:
                        themeData.colorScheme.onBackground.withAlpha(60),
                    rating: review.rating.toDouble(),
                    spacing: 0,
                    inactiveStarFilled: true),
                Container(
                  margin: Spacing.left(8),
                  child: Text(
                    Generator.convertDateTimeToText(review.createdAt,
                        showDate: true, showTime: false),
                    style: AppTheme.getTextStyle(themeData.textTheme.caption,fontSize: 12,
                        fontWeight: 600, xMuted: true),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: Spacing.top(4),
            child: Text(
              review.review,
              style: AppTheme.getTextStyle(themeData.textTheme.caption,
                  color: themeData.colorScheme.onBackground,
                  muted: true,
                  fontWeight: 500),
            ),
          ),
        ],
      ),
    );
  }

  void showMessage({String message = "Something wrong", Duration duration}) {
    if (duration == null) {
      duration = Duration(seconds: 1);
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
