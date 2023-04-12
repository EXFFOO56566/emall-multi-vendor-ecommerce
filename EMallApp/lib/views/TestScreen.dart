import 'dart:developer';

import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/payment_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:provider/provider.dart';

class TestScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<TestScreen> {
  //Theme Data
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();



    test();
  }


  test() async {
   await PaystackPlugin.initialize(
        publicKey: PaymentApi.PAYSTACK_PUBLIC_KEY);


  }

  click() async {
    log("1");
    try {
      Charge charge = Charge()
        ..amount = 100
        ..reference = '1'
        ..email = 'customer@email.com';

      log(charge.toString());
      CheckoutResponse response = await PaystackPlugin.checkout(context,
        method: CheckoutMethod.selectable,
        charge: charge,

      );
      log(response.toString());
    }catch(e){
      log(e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: SafeArea(
              child: Scaffold(
                  backgroundColor: customAppTheme.bgLayer1,
                  resizeToAvoidBottomInset: false,
                  body: Column(
                    children: [
                        TextButton(onPressed: (){
                          click();
                        }, child: Text("Click"))
                    ],
                  )),
            ));
      },
    );
  }
}