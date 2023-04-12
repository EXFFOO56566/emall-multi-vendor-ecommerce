
import 'package:DeliveryBoyApp/services/AppLocalizations.dart';
import 'package:DeliveryBoyApp/utils/SizeConfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../AppTheme.dart';
import '../AppThemeNotifier.dart';

class OrderOTPDialog extends StatefulWidget {
  @override
  _OrderOTPDialogState createState() => _OrderOTPDialogState();
}

class _OrderOTPDialogState extends State<OrderOTPDialog> {

  //ThemeData
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Text Field Editing Controller
  TextEditingController otpTFController;


  @override
  void initState() {
    super.initState();
    otpTFController = TextEditingController();
  }

  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return Dialog(
          child: Container(
            padding: Spacing.only(top: 16, bottom:16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: Spacing.fromLTRB(16, 0, 16, 0),
                  child: TextFormField(
                    style: AppTheme.getTextStyle(
                        themeData.textTheme.bodyText1,
                        letterSpacing: 0.1,
                        color: themeData.colorScheme.onBackground,
                        fontWeight: 500),
                    decoration: InputDecoration(
                        hintText: Translator.translate("OTP"),
                        hintStyle: AppTheme.getTextStyle(
                            themeData.textTheme.subtitle2,
                            color: themeData.colorScheme.onBackground,
                            fontWeight: 500),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                            borderSide: BorderSide(color: customAppTheme.bgLayer4, width: 1.5)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                            borderSide: BorderSide(color: customAppTheme.bgLayer4, width: 1.5)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                            borderSide: BorderSide(color: customAppTheme.bgLayer4, width: 1.5)),
                        prefixIcon: Icon(
                          MdiIcons.numeric,
                          size: MySize.size22,
                        ),
                        isDense: true,
                        contentPadding: Spacing.zero
                    ),
                    keyboardType: TextInputType.number,
                    controller: otpTFController,
                  ),
                ),
                Container(
                  margin: Spacing.top(8),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius:  BorderRadius.circular(4),
                        ))
                    ),
                    onPressed: () {
                      Navigator.pop(context,otpTFController.text);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          MdiIcons.clipboardArrowUpOutline,
                          color: themeData.colorScheme.onPrimary,
                          size: MySize.size18,
                        ),
                        Container(
                          margin: Spacing.left(8),
                          child: Text(
                            Translator.translate("delivered"),
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText2,
                                color: themeData.colorScheme.onPrimary),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
