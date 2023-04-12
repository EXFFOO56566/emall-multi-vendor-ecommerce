
import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/controllers/ProductReviewController.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/models/Product.dart';
import 'package:ManagerApp/models/ProductReview.dart';
import 'package:ManagerApp/services/AppLocalizations.dart';
import 'package:ManagerApp/utils/ColorUtils.dart';
import 'package:ManagerApp/utils/Generator.dart';
import 'package:ManagerApp/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../AppTheme.dart';
import '../AppThemeNotifier.dart';
import 'LoadingScreens.dart';

class ProductReviewsScreen extends StatefulWidget {


  @override
  _ProductReviewsScreenState createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  //Theme Data
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = new GlobalKey<ScaffoldMessengerState>();


  //Other Variables
  bool isInProgress = false;
  List<ProductReview> reviews;

  _fetchReviews() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<ProductReview>> myResponse =
    await ProductReviewController.getAllReviews();

    if (myResponse.success) {
        reviews = myResponse.data;
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
  void initState() {
    super.initState();
    _fetchReviews();
  }

  @override
  void dispose() {
    super.dispose();
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
    if (reviews != null) {
      return ListView(
        padding: Spacing.zero,
        children: [
          _buildReviewWidget(reviews)
        ],
      );
    } else if (isInProgress) {
      return LoadingScreens.getProductLoadingScreen(
          context, themeData, customAppTheme);
    } else {
      return Center(
        child: Text("Something wrong"),
      );
    }
  }


  _buildReviewWidget(List<ProductReview> reviews) {
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
    for (ProductReview review in reviews) list.add(_singleReview(review));

    return Container(
      margin: Spacing.fromLTRB(24, 0, 24, 0),
      child: Column(
        children: list,
      ),
    );
  }

  _singleReview(ProductReview review) {
    return Container(
      margin: Spacing.bottom(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
                  child: review.product.productImages.length != 0
                      ? Image.network(
                    review.product.productImages[0].url,
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
                    height: MySize.size44,
                    width: MySize.size44,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    Product.getPlaceholderImage(),
                    height: MySize.size90,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(width: MySize.size16,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.user.name,
                        style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onBackground,
                            fontWeight: 600),
                      ),
                      Row(
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
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(60,4,0,0),
            child: Text(
              review.review,
              style: AppTheme.getTextStyle(themeData.textTheme.caption,
                  color: themeData.colorScheme.onBackground,
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


