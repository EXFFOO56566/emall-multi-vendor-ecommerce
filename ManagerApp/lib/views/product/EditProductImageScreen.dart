import 'dart:io';

import 'package:ManagerApp/api/api_util.dart';
import 'package:ManagerApp/controllers/ProductController.dart';
import 'package:ManagerApp/models/MyResponse.dart';
import 'package:ManagerApp/models/Product.dart';
import 'package:ManagerApp/models/ProductImage.dart';
import 'package:ManagerApp/services/AppLocalizations.dart';
import 'package:ManagerApp/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';
import '../LoadingScreens.dart';

class EditProductImageScreen extends StatefulWidget {
  final int id;

  const EditProductImageScreen({Key key, this.id}) : super(key: key);

  @override
  _EditProductImageScreenState createState() => _EditProductImageScreenState();
}

class _EditProductImageScreenState extends State<EditProductImageScreen> {
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
  Product product;

  //File
  File imageFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        _uploadImage();
      }
    });
  }

  _uploadImage() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse =
        await ProductController.uploadImage(widget.id, imageFile);
    if (myResponse.success) {
      product = myResponse.data;
      showMessage(message: "Image uploaded");

      _fetchImages();
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

  _deleteImage(int productImageId) async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse = await ProductController.deleteImage(productImageId);
    if (myResponse.success) {
      product = myResponse.data;
      showMessage(message: "Image deleted");

      _fetchImages();
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

  _fetchImages() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Product> myResponse =
        await ProductController.getProductImages(widget.id);
    if (myResponse.success) {
      product = myResponse.data;
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
    _fetchImages();
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
                appBar: AppBar(

                  backgroundColor: customAppTheme.bgLayer2,
                  elevation: 0,
                  leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(MdiIcons.chevronLeft,color: themeData.colorScheme.onBackground,size: MySize.size20,),
                  ),
                  centerTitle: true,
                  title: Text(
                    product != null ? product.name : "Loading",
                    style: AppTheme.getTextStyle(themeData.textTheme.headline6,
                        fontWeight: 600),
                  ),
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
                        _buildBody()
                      ],
                    ))));
      },
    );
  }

  _buildBody() {
    if (product != null) {
      return _getProductImageView(product.productImages);
    } else if (isInProgress) {
      return LoadingScreens.getOrderLoadingScreen(
          context, themeData, customAppTheme);
    } else {
      return Container();
    }
  }

  _getProductImageView(List<ProductImage> productImages) {
    List<Widget> images = [];
    for (ProductImage productImage in productImages) {
      images.add(Container(
        margin: Spacing.bottom(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
              child: product.productImages.length != 0
                  ? Image.network(
                      productImage.url,
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
            SizedBox(
              width: MySize.size24,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius:  BorderRadius.circular(4),
                  ))
              ),
              onPressed: () {
                setState(() {
                  _deleteImage(productImage.id);
                });
              },
              child: Text(
                Translator.translate("delete"),
                style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                    color: customAppTheme.onError),
              ),
            )
          ],
        ),
      ));
    }

    return Container(
      margin: Spacing.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              _pickImage();
            },
            child: Container(
              padding: Spacing.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MySize.size8),
                border: Border.all(color: customAppTheme.bgLayer4, width: 1),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      MdiIcons.cloudUploadOutline,
                      size: MySize.size26,
                      color: themeData.colorScheme.onBackground.withAlpha(160),
                    ),
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
              ),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(8, 16, 24, 0),
            child: Text(
              Translator.translate("product_images"),
              style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 600,
                  muted: true),
            ),
          ),
          Container(
              margin: Spacing.fromLTRB(8, 16, 24, 0),
              child: productImages.length == 0
                  ? Center(
                      child: Text(
                        Translator.translate("there_is_no_image_yet"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onBackground,
                            fontWeight: 500),
                      ),
                    )
                  : Column(
                      children: images,
                    )),
        ],
      ),
    );
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
