
import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/controllers/ProductController.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/models/Product.dart';
import 'package:ManagerApp/services/AppLocalizations.dart';
import 'package:ManagerApp/utils/ColorUtils.dart';
import 'package:ManagerApp/utils/Generator.dart';
import 'package:ManagerApp/utils/SizeConfig.dart';
import 'package:ManagerApp/views/product/CreateProductScreen.dart';
import 'package:ManagerApp/views/product/EditProductScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';
import '../LoadingScreens.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
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
  List<Product> products;

  @override
  void initState() {
    super.initState();
    _initProductsData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _initProductsData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<Product>> myResponse = await ProductController.getAllProduct();
    if (myResponse.success) {
      products = myResponse.data;
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
    _initProductsData();
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
                backgroundColor: customAppTheme.bgLayer2,
                floatingActionButton: FloatingActionButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => CreateProductScreen(),
                      ),
                    );
                  },
                   backgroundColor: themeData.colorScheme.primary,
                  child: Icon(MdiIcons.plus,size: MySize.size22,color: themeData.colorScheme.onPrimary,),
                ),
                body: RefreshIndicator(
                    onRefresh: _refresh,
                    backgroundColor: customAppTheme.bgLayer1,
                    color: themeData.colorScheme.primary,
                    key: _refreshIndicatorKey,
                    child: ListView(
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
                        buildBody()
                      ],
                    ))));
      },
    );
  }

  Widget buildBody() {
    if(products==null){
      if(isInProgress) {
        return Container(
            margin: Spacing.top(16),
            child: LoadingScreens.getSearchLoadingScreen(
                context, themeData, customAppTheme,
                itemCount: 5));
      }else{
        return Container(child: Text("Something wrong"),);
      }
    }else if(products.length==0){
      return Center(
          child: Container(
              margin: Spacing.top(16),
              child: Text(
                Translator.translate("you_have_not_any_product"),
              )));
    }

    return _showProducts(products);
  }



  _showProducts(List<Product> products) {
    List<Widget> listWidgets = [];

    for (int i = 0; i < products.length; i++) {
      listWidgets.add(InkWell(
        onTap: () async {
        },
        child: Container(
          margin: Spacing.bottom(16),
          child: _singleProduct(products[i]),
        ),
      ));
    }

    return Container(
      margin: Spacing.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: listWidgets,
      ),
    );
  }

  _singleProduct(Product product) {
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => EditProductScreen(id: product.id,),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: customAppTheme.bgLayer1,
          borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
          border: Border.all(color: customAppTheme.bgLayer4),
          boxShadow: [
            BoxShadow(
              color: customAppTheme.shadowColor,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: Spacing.all(16),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
              child: product.productImages.length != 0
                  ? Image.network(
                product.productImages[0].url,
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
                height: MySize.size90,
                width: MySize.size90,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                Product.getPlaceholderImage(),
                height: MySize.size90,
                fit: BoxFit.fill,
              ),
            ),
            Expanded(
              child: Container(
                height: MySize.size90,
                margin: Spacing.left(MySize.size16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.name,
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.subtitle2,
                          fontWeight: 600,
                          letterSpacing: 0),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: <Widget>[
                        Generator.buildRatingStar(
                            rating: product.rating,
                            activeColor: ColorUtils.getColorFromRating(product.rating.ceil(), customAppTheme, themeData),
                            size: MySize.size16,
                            inactiveColor: themeData.colorScheme.onBackground),
                        Container(
                          margin: Spacing.left(MySize.size4),
                          child: Text("(" + product.totalRating.toString() + ")",
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText1,
                                  fontWeight: 600)),
                        ),
                      ],
                    ),
                    Text(
                      product.productItems.length.toString() + " " + Translator.translate("options_available"),
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.bodyText2,
                          fontWeight: 500),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void showMessage({String message = "Something wrong", Duration duration}) {
    if (duration == null) {
      duration = Duration(seconds: 3);
    }
    if(_scaffoldKey.currentState==null)
      return;
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
