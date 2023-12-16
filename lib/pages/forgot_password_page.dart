import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:ykjam_cargo/methods/home_page_methods.dart';
import 'package:ykjam_cargo/methods/register_page_methods.dart';
import 'package:http/http.dart' as http;
import 'package:ykjam_cargo/pages/home_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // VARIABLES -----------------------------------------------------------------
  final TextEditingController _loginCtrl = TextEditingController();
  final TextEditingController _codeCtr = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _verifyPassCtrl = TextEditingController();

  String _message = "";
  int _clickStep = 0;
  bool _internetConnection = true;
  int _secret = 0;
  int _userID = 0;

  bool _passwordVisible1 = true;
  bool _passwordVisible2 = true;

  // FUNCTIONS -----------------------------------------------------------------
  Future<bool> checkNetwork() async {
    final internetConnection = await Connectivity().checkConnectivity();
    if (internetConnection != ConnectivityResult.none) {
      return true;
    }
    return false;
  }

  checkConnection() async {
    final connectResult = await checkNetwork();

    setState(() {
      _internetConnection = connectResult;
    });
  }

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

  // DISPOSE -------------------------------------------------------------------
  @override
  void dispose() {
    _loginCtrl.dispose();
    _codeCtr.dispose();
    _passCtrl.dispose();
    _verifyPassCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localStoradge = Provider.of<LocalStoradge>(context);
    localStoradge.getGuestTokenFromSharedPref();
    String guestToken = localStoradge.getGuestToken();

    return ChangeNotifierProvider(
      create: (context) => LocalStoradge(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.white,
                        child: Image.asset("assets/images/logo.webp"),
                      ),
                      inputMethod(
                          "* Login, telefon ýa-da email salgy...",
                          "[a-z A-Z 0-9 - + @ .]",
                          "",
                          false,
                          false,
                          () {},
                          context,
                          _loginCtrl,
                          0,
                          (_clickStep == 2 || _clickStep == 3) ? false : true),
                      SizedBox(
                        height: (_clickStep < 2)
                            ? 45
                            : (_clickStep == 3)
                                ? 250
                                : 180,
                        child: (_clickStep < 2)
                            ? Text(
                                _message,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            : Column(
                                children: [
                                  (_clickStep == 3)
                                      ? const SizedBox()
                                      : Html(
                                          data: _message,
                                          style: {
                                            'body': Style(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.green,
                                              fontSize: FontSize(12),
                                            ),
                                          },
                                        ),
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    height: 50,
                                    width: 150,
                                    child: TextField(
                                      enabled: (_clickStep == 3) ? false : true,
                                      keyboardType: TextInputType.number,
                                      controller: _codeCtr,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        label: Center(
                                          child: Text("Gizlin kod"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  (_clickStep == 3)
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Column(
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
                                            ],
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                      ),
                      elevationButtonMethod(
                        context,
                        "Indiki",
                        Theme.of(context).primaryColor,
                        Colors.white,
                        () async {
                          if (_clickStep == 2) {
                            if (_codeCtr.text == "") {
                              showToastMethod("Gizlin kody giriziň !");
                              return;
                            }

                            if (int.parse(_codeCtr.text) != _secret) {
                              showToastMethod("Gizlin kod ýalňyş !");
                              return;
                            }

                            setState(() {
                              _clickStep = 3;
                            });
                          } else if (_clickStep == 3) {
                            if (_passCtrl.text.length < 6) {
                              showToastMethod(
                                  "Täze parol iň az 6 harp bolmalydyr !");
                              return;
                            }
                            if (_verifyPassCtrl.text != _passCtrl.text) {
                              showToastMethod(
                                  "Parol we paroly tassyklama deň däl !");
                              return;
                            }

                            StaticData staticData = StaticData();
                            final connectionResult = await checkNetwork();

                            if (connectionResult) {
                              final body = {
                                'uid': _userID,
                                'newpass': _passCtrl.text,
                              };

                              var response = await http.put(
                                Uri.parse(
                                    "${staticData.getUrl()}/update_password?key=$guestToken"),
                                body: json.encode(body),
                              );

                              var jsonData = jsonDecode(response.body);

                              if (response.statusCode == 202) {
                                showToastMethod(
                                  jsonData['message'],
                                );

                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomePage(),
                                    ),
                                  );
                                }
                              }
                            } else {
                              setState(() {
                                _internetConnection = false;
                              });
                            }
                          } else {
                            StaticData staticData = StaticData();
                            final connectionResult = await checkNetwork();

                            if (connectionResult) {
                              var response = await http.get(
                                Uri.parse(
                                  "${staticData.getUrl()}/forgot_secret?key=$guestToken&in=${_loginCtrl.text}",
                                ),
                              );

                              var jsonData = jsonDecode(response.body);

                              if (jsonData['status'].toString().toLowerCase() ==
                                  'false') {
                                setState(() {
                                  _message = jsonData['message'];
                                  _clickStep = 1;
                                });

                                return;
                              }

                              setState(() {
                                _clickStep = 2;
                                _message = jsonData['message'];
                                _secret =
                                    int.parse(jsonData['secret'].toString());
                                _userID = int.parse(jsonData['id'].toString());
                              });
                            } else {
                              checkConnection();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  elevationButtonMethod(
                    context,
                    "Goýbolsun",
                    Colors.grey.shade300,
                    Colors.black,
                    () {
                      Navigator.pop(context);
                    },
                  ),
                ],
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
