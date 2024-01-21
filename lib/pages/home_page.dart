import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/contact_data.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:ykjam_cargo/methods/home_page_methods.dart';
import 'package:ykjam_cargo/pages/chat_page.dart';
import 'package:ykjam_cargo/pages/setting_page.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // INIT STATE ----------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _getContact();
  }

  // VARIABLES -----------------------------------------------------------------
  double _positionY = 20;
  bool isDragging = false;
  bool _internetConnection = true;

  StaticData staticData = StaticData();
  List<Contact> contacts = [];
  String guestToken = "";

  // FUNCTIONS -----------------------------------------------------------------
  _getContact() async {
    final internetConnection = await checkNetwork();
    _internetConnection = internetConnection;

    if (_internetConnection) {
      if (context.mounted) {
        final localStoragde =
            Provider.of<LocalStoradge>(context, listen: false);

        await localStoragde.getGuestTokenFromSharedPref();

        setState(() {
          guestToken = localStoragde.getGuestToken();
        });
      }

      var response = await http
          .get(Uri.parse("${staticData.getUrl()}/contacts?key=$guestToken"));
      var jsonData = jsonDecode(response.body);

      if (jsonData is List) {
        for (var data in jsonData) {
          Contact contact = Contact(
            data['id'],
            data['code'],
            data['name'],
            data['value'],
          );
          setState(() {
            contacts.add(contact);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localStoradge = Provider.of<LocalStoradge>(context);
    localStoradge.getUserTokenFromSharedPref();
    String userToken = localStoradge.getUserToken();

    return ChangeNotifierProvider<LocalStoradge>(
      create: (context) => LocalStoradge(),
      child: PopScope(
        canPop: true,
        onPopInvoked: (bool didPop) {
          exit(0);
        },
        child: Scaffold(
          body: SafeArea(
            child: Container(
              color: Colors.white,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: Row(
                            children: [
                              const Expanded(
                                child: SizedBox(
                                  width: 5,
                                ),
                              ),
                              Expanded(
                                flex: 10,
                                child: Image.asset(
                                    "${staticData.getStaticFilePath()}/logo.webp"),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: const Alignment(10, -0.8),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SettingPage(),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.settings,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            listTileMethod(
                                "${staticData.getStaticFilePath()}/products.webp",
                                "Harytlarym",
                                "Bu bölüm üçin hasaba durmak zerurdyr !",
                                false,
                                0,
                                context,
                                userToken, []),
                            listTileMethod(
                                "${staticData.getStaticFilePath()}/users.webp",
                                "Eýesiz harytlar",
                                "",
                                false,
                                1,
                                context,
                                userToken, []),
                            listTileMethod(
                                "${staticData.getStaticFilePath()}/order.webp",
                                "Bildirişler",
                                "",
                                false,
                                2,
                                context,
                                userToken, []),
                            listTileMethod(
                                "${staticData.getStaticFilePath()}/prices.webp",
                                "Hyzmat bahalary",
                                "",
                                false,
                                3,
                                context,
                                userToken, []),
                            listTileMethod(
                                "${staticData.getStaticFilePath()}/contacts.webp",
                                "Habarlaşmak",
                                "",
                                false,
                                4,
                                context,
                                userToken,
                                contacts),
                            listTileMethod(
                                "${staticData.getStaticFilePath()}/privacy.webp",
                                "Düzgünnama",
                                "",
                                false,
                                5,
                                context,
                                userToken, []),
                            // listTileMethod(
                            //     "${staticData.getStaticFilePath()}/news.webp",
                            //     "Täzelikler (Cooming soon)",
                            //     "",
                            //     true,
                            //     6,
                            //     context,
                            //     userToken, []),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: _positionY,
                    right: 0,
                    child: GestureDetector(
                      onVerticalDragStart: (details) {
                        isDragging = true;
                      },
                      onVerticalDragUpdate: (details) {
                        if (isDragging) {
                          setState(() {
                            _positionY -= details.delta.dy;
                            if (_positionY < 20) {
                              _positionY = 20;
                            } else if (_positionY >
                                MediaQuery.of(context).size.height - 150) {
                              _positionY =
                                  MediaQuery.of(context).size.height - 150;
                            }
                          });
                        }
                      },
                      onVerticalDragEnd: (details) {
                        isDragging = false;
                      },
                      child: Container(
                        width: 65,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(169, 158, 158, 158),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.message, size: 28),
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            if (userToken != "") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatPage(),
                                ),
                              );
                              return;
                            }

                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: const Text(
                                    "Ulgama giriň !",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: const Text(
                                      "Ulgama girmegňigizi haýyş edýäris.."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "OK",
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
