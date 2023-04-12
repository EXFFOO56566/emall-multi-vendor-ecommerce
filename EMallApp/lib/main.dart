
import 'package:EMallApp/controllers/AppDataController.dart';
import 'package:EMallApp/controllers/AuthController.dart';
import 'package:EMallApp/models/AppData.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/services/PushNotificationsManager.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/views/AppScreen.dart';
import 'package:EMallApp/views/MaintenanceScreen.dart';
import 'package:EMallApp/views/auth/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'AppTheme.dart';
import 'AppThemeNotifier.dart';

Future<void> main() async {

  //You will need to initialize AppThemeNotifier class for theme changes.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
      String langCode = await AllLanguage.getLanguage();
      await Translator.load(langCode);

      runApp(ChangeNotifierProvider<AppThemeNotifier>(
      create: (context) => AppThemeNotifier(),
      child: MyApp(),
    ));
  });
}

class MyApp extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: MyHomePage());
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ThemeData themeData;


  @override
  void initState() {
    super.initState();
    initFCM();

    getAppData();
  }

  getAppData() async {
    MyResponse<AppData> myResponse = await AppDataController.getAppData();

   if(myResponse.data!=null) {
     if (!myResponse.data.isAppUpdated()) {
       Navigator.pushAndRemoveUntil(
         context,
         MaterialPageRoute(
           builder: (BuildContext context) =>
               MaintenanceScreen(isNeedUpdate: true,),
         ),
             (route) => false,
       );
       return;
     } else {
       if (myResponse.data.user != null) {
         AuthController.saveUserFromUser(myResponse.data.user);
       }
     }
   }

  }

  initFCM() async {
    PushNotificationsManager pushNotificationsManager = PushNotificationsManager();
    await pushNotificationsManager.init(context: context);
  }

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    themeData = Theme.of(context);
    return FutureBuilder<bool>(
        future: AuthController.isLoginUser(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            if(snapshot.data){
              return AppScreen();
            }else{
              return LoginScreen();
            }
          } else {
            return CircularProgressIndicator();
          }
        }
    );
  }
}
