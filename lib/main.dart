import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:ykjam_cargo/helpers/notification_service.dart';
import 'package:ykjam_cargo/methods/home_page_methods.dart';
import 'package:ykjam_cargo/pages/home_page.dart';
import 'package:ykjam_cargo/pages/start_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await LocalStoradge().createSharedPrefObject();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider<LocalStoradge>(
        create: (context) => LocalStoradge(),
      ),
      ChangeNotifierProvider<StaticData>(
        create: (context) => StaticData(),
      ),
    ], child: const MyApp()),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    getGuestToken(
      context,
      staticData,
    ).then((result) {
      setState(() {
        _internetConnection = result.intConn;
        _isLoadingStartPage = result.isload;
        guestToken = result.token;
      });
    });

    requestNotificationPermission();
    notificationServices.foregroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isRefresh();
    notificationServices.getDeviceToken().then((fcmToken) {
      addFcmToken(fcmToken, "0", staticData, guestToken, context);
    });
  }

// VARIABLES -------------------------------------------------------------------
  bool _isLoadingStartPage = true;
  bool _internetConnection = true;

  String guestToken = "";

  NotificationServices notificationServices = NotificationServices();

  handleNetworkConnection() async {
    final connectionResult = await checkNetwork();

    setState(() {
      _internetConnection = connectionResult;
      if (_internetConnection) {
        _isLoadingStartPage = false;
      }
    });
  }

  void requestNotificationPermission() async {
    // Check the current permission status.
    var status = await Permission.notification.status;

    if (status == PermissionStatus.denied) {
      // Request the permission.
      status = await Permission.notification.request();

      if (status == PermissionStatus.denied) {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Duýduryşa rugsat berilmedi'),
            content: const Text(
                'Programma sazlamalarynda duýduryş rugsatlaryny açmagyňyzy haýyş edýäris.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Bolýar'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ykjam Cargo',
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(0, 71, 138, 1),
        useMaterial3: true,
      ),
      home: Stack(
        children: [
          _isLoadingStartPage ? StartPage() : const HomePage(),
          Positioned(
            bottom: 10,
            left: 15,
            child: !(_internetConnection)
                ? errorHandleMethod(context, handleNetworkConnection)
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
