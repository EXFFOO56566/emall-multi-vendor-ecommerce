import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsManager {

  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {

      // For iOS request permission.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure();

      //Configure here if you need custom notifications
      _firebaseMessaging.configure(
        onMessage: (Map<String,dynamic> message) async {

        },
        onLaunch: (Map<String,dynamic> message) async {

        },
        onResume: (Map<String,dynamic> message) async {

        },
      );

      _initialized = true;
    }
  }

  //Remove FCM Token when user logout
  Future<bool> removeFCM(){
    return _firebaseMessaging.deleteInstanceID();
  }

  Future<String> getToken() async{
    if(_initialized){
      return await _firebaseMessaging.getToken();
    }
    PushNotificationsManager pushNotificationsManager = PushNotificationsManager();
    await pushNotificationsManager.init();
    return await pushNotificationsManager.getToken();
  }
}