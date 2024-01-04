import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:ykjam_cargo/methods/home_page_methods.dart';
import 'package:ykjam_cargo/pages/home_page.dart';
import 'package:ykjam_cargo/pages/start_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Future.delayed(const Duration(seconds: 1));
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
  }

// VARIABLES -------------------------------------------------------------------
  bool _isLoadingStartPage = true;
  bool _internetConnection = true;

  String guestToken = "";

  handleNetworkConnection() async {
    final connectionResult = await checkNetwork();

    setState(() {
      _internetConnection = connectionResult;
      if (_internetConnection) {
        _isLoadingStartPage = false;
      }
    });
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
