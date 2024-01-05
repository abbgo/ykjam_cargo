import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:ykjam_cargo/helpers/font_size.dart';
import 'package:ykjam_cargo/methods/register_page_methods.dart';
import 'package:ykjam_cargo/methods/setting_page_methods.dart';
import 'package:http/http.dart' as http;
import 'package:ykjam_cargo/pages/home_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // VARIABLES -------------------------------------------------------------------
  bool _isSwitched = true;
  bool _showUpdatePassword = false;
  bool _passwordVisible1 = true;
  bool _passwordVisible2 = true;

  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _verifyPassCtrl = TextEditingController();

  bool _internetConnection = true;

  // FUNCTIONS -----------------------------------------------------------------
  _toggleFunction1() {
    setState(() {
      _passwordVisible1 = !_passwordVisible1;
    });
  }

  _toggleFunction2() {
    setState(() {
      _passwordVisible2 = !_passwordVisible2;
    });
  }

  _togglebutton1() {
    setState(() {
      _showUpdatePassword = !_showUpdatePassword;
    });
  }

  checkConnection() async {
    final connectResult = await checkNetwork();

    setState(() {
      _internetConnection = connectResult;
    });
  }

  changeNotify() async {
    StaticData staticData = StaticData();

    if (!_internetConnection) {
      String fcmtoken = "";
      int enableNotify = 0;

      if (context.mounted) {
        final localStoragde =
            Provider.of<LocalStoradge>(context, listen: false);
        await localStoragde.getFcmTokenFromSharedPref();
        fcmtoken = localStoragde.getFcmToken();
      }

      if (_isSwitched) {
        enableNotify = 0;
      }

      http.put(
        Uri.parse(
            "${staticData.getUrl()}/enable_notify?fcm=$fcmtoken&set=$enableNotify"),
      );
    }
  }

  // DISPOSE -------------------------------------------------------------------
  @override
  void dispose() {
    _passCtrl.dispose();
    _verifyPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localStoradge = Provider.of<LocalStoradge>(context);
    localStoradge.getUserNameFromSharedPref();
    localStoradge.getUserCodeFromSharedPref();
    localStoradge.getUserIDFromSharedPref();
    localStoradge.getUserTokenFromSharedPref();

    localStoradge.getUserToken();

    String userName = localStoradge.getUserName();
    String userCode = localStoradge.getUserCode();
    int userID = localStoradge.getUserID();
    String userToken = localStoradge.getUserToken();

    return ChangeNotifierProvider(
      create: (context) => LocalStoradge(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(),
        body: Stack(
          children: [
            Container(
              alignment: Alignment.topCenter,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade500,
                        offset: const Offset(0.1, 0.1),
                        blurRadius: 1.0,
                        spreadRadius: 1.0,
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-4.0, -4.0),
                        blurRadius: 15.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.black45,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      userCode == ""
                          ? const Text(
                              "Näbelli ulanyjy",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            )
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Hoş geldiňiz, ",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showUserCodeBottomSheet(
                                      context,
                                      userCode,
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Marka belgi: ",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        "$userCode ",
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.info,
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 10),
                                  child: !_showUpdatePassword
                                      ? GestureDetector(
                                          onTap: _togglebutton1,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.key,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              const SizedBox(width: 10),
                                              const Text("Paroly üýtgetmek"),
                                            ],
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            inputMethod(
                                                "* Täze parol...",
                                                "[a-z A-Z 0-9]",
                                                "",
                                                true,
                                                _passwordVisible1,
                                                _toggleFunction1,
                                                context,
                                                _passCtrl,
                                                0,
                                                true),
                                            inputMethod(
                                                "* Paroly tassykla...",
                                                "[a-z A-Z 0-9]",
                                                "",
                                                true,
                                                _passwordVisible2,
                                                _toggleFunction2,
                                                context,
                                                _verifyPassCtrl,
                                                0,
                                                true),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                settingFormInputButtonMethod(
                                                  "Goýbolsun",
                                                  Colors.black,
                                                  Colors.grey.shade200,
                                                  _togglebutton1,
                                                ),
                                                settingFormInputButtonMethod(
                                                  "Ýatda sakla",
                                                  Colors.white,
                                                  Theme.of(context)
                                                      .primaryColor,
                                                  () async {
                                                    if (_passCtrl.text.length <
                                                        6) {
                                                      showToastMethod(
                                                          "Täze parol iň az 6 harp bolmalydyr !");
                                                      return;
                                                    }
                                                    if (_verifyPassCtrl.text !=
                                                        _passCtrl.text) {
                                                      showToastMethod(
                                                          "Parol we paroly tassyklama deň däl !");
                                                      return;
                                                    }

                                                    StaticData staticData =
                                                        StaticData();
                                                    final connectionResult =
                                                        await checkNetwork();

                                                    if (connectionResult) {
                                                      final body = {
                                                        'uid': userID,
                                                        'newpass':
                                                            _passCtrl.text,
                                                      };

                                                      var response =
                                                          await http.put(
                                                        Uri.parse(
                                                            "${staticData.getUrl()}/update_password?key=$userToken"),
                                                        body: json.encode(body),
                                                      );

                                                      var jsonData = jsonDecode(
                                                          response.body);

                                                      if (response.statusCode ==
                                                          202) {
                                                        showToastMethod(
                                                          jsonData['message'],
                                                        );

                                                        setState(() {
                                                          _showUpdatePassword =
                                                              false;

                                                          _passCtrl.text = "";
                                                          _verifyPassCtrl.text =
                                                              "";
                                                          _passwordVisible1 =
                                                              true;
                                                          _passwordVisible2 =
                                                              true;
                                                        });
                                                      }
                                                    } else {
                                                      setState(() {
                                                        _internetConnection =
                                                            false;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                      Divider(color: Theme.of(context).primaryColor),
                      Padding(
                        padding: const EdgeInsets.only(left: 0, bottom: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Duýduryşlary açmak/ýapmak",
                              style: TextStyle(
                                fontSize: calculateFontSize(context, 16),
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch.adaptive(
                                value: _isSwitched,
                                onChanged: (bool value) {
                                  setState(() {
                                    _isSwitched = value;
                                  });

                                  changeNotify();

                                  if (!_isSwitched) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: const Text(
                                            "Üns beriň !",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: const Text(
                                              "Bu siziň harytlaryňyzdaky hereketiň duýduryşyna degişli däldir! Harytlaryňyzyň duýduryşlary açykdyr!"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "OK",
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                activeColor: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (userCode != "")
                        Padding(
                          padding: const EdgeInsets.only(left: 5, top: 10),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Text(
                                      "Ulgamdan çykyljakdyr !",
                                      style: TextStyle(
                                        fontSize:
                                            calculateFontSize(context, 20),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      "Ulgamdan çykmakçymy ?",
                                      style: TextStyle(
                                        fontSize:
                                            calculateFontSize(context, 16),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "GOÝBOLSUN",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: calculateFontSize(
                                                  context, 16)),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          StaticData staticData = StaticData();
                                          String guestToken = "";

                                          getGuestToken(
                                            context,
                                            staticData,
                                          ).then((result) {
                                            setState(() {
                                              guestToken = result.token;
                                            });
                                          });

                                          localStoradge
                                              .changeGuestToken(guestToken);
                                          localStoradge.changeUserToken("");
                                          localStoradge.changeUserName("");
                                          localStoradge.changeUserCode("");
                                          localStoradge.changeUserID(0);

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const HomePage(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "OK",
                                          style: TextStyle(
                                            fontSize:
                                                calculateFontSize(context, 16),
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.exit_to_app,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 10),
                                const Text("Ulgamdan çykmak"),
                              ],
                            ),
                          ),
                        )
                      else
                        const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 15,
              child: !(_internetConnection)
                  ? errorHandleMethod(context, checkConnection)
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
