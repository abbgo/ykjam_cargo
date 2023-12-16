// import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
// import 'package:http/http.dart' as http;
import 'package:ykjam_cargo/functions/functions.dart';
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
  print(message.notification!.title.toString());
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

  // FUNCTIONS -----------------------------------------------------------------
  // _getGuestToken() async {
  //   final internetConnection = await checkNetwork();
  //   _internetConnection = internetConnection;

  //   if (_internetConnection) {
  //     if (context.mounted) {
  //       final localStoragde =
  //           Provider.of<LocalStoradge>(context, listen: false);

  //       await localStoragde.getGuestTokenFromSharedPref();

  //       setState(() {
  //         guestToken = localStoragde.getGuestToken();
  //       });
  //     }

  //     if (guestToken == "") {
  //       final deviceName = await getDeviceName();

  //       var response = await http.get(
  //         Uri.parse(
  //             "${staticData.getUrl()}/get_token?guest=true&device=$deviceName"),
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Access-Control-Allow-Origin': '*',
  //           'Access-Control-Allow-Credentials': 'true',
  //           'Access-Control-Allow-Headers': 'Content-Type',
  //           'Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE'
  //         },
  //       );

  //       var jsonData = jsonDecode(response.body);

  //       if (jsonData.containsKey('token') && response.statusCode == 200) {
  //         guestToken = jsonData['token'];

  //         if (context.mounted) {
  //           Provider.of<LocalStoradge>(context, listen: false)
  //               .changeGuestToken(guestToken);
  //         }

  //         _isLoadingStartPage = false;

  //         setState(() {});
  //       } else {
  //         showToastMethod("Maglumat çekilmedi");
  //       }
  //     } else {
  //       _isLoadingStartPage = false;
  //       setState(() {});
  //     }
  //   } else {
  //     setState(() {
  //       _internetConnection = false;
  //     });
  //   }
  // }

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
