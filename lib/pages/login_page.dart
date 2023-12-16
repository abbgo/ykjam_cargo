import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:ykjam_cargo/methods/home_page_methods.dart';
import 'package:ykjam_cargo/methods/register_page_methods.dart';
import 'package:ykjam_cargo/pages/forgot_password_page.dart';
import 'package:ykjam_cargo/pages/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:ykjam_cargo/pages/stages_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // INIT STATE ----------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  // VARIABLES -----------------------------------------------------------------
  final TextEditingController _loginCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _passwordVisible1 = true;

  Color _checkBoxColor = const Color.fromRGBO(0, 71, 138, 1);
  Color _borderColor = const Color.fromRGBO(0, 71, 138, 1);
  bool _isChecked = true;

  bool _internetConnection = true;

  // FUNCTIONS -----------------------------------------------------------------
  _toggleFunction1() {
    setState(() {
      _passwordVisible1 = !_passwordVisible1;
    });
  }

  void netWorkConnectionChange() {
    setState(() {
      _internetConnection = false;
    });
  }

  checkConnection() async {
    final connectResult = await checkNetwork();

    setState(() {
      _internetConnection = connectResult;
    });
  }

  // DISPOSE -------------------------------------------------------------------
  @override
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localStoradge = Provider.of<LocalStoradge>(context, listen: false);

    return ChangeNotifierProvider(
      create: (context) => LocalStoradge(),
      child: PopScope(
        canPop: true,
        onPopInvoked: (bool didPop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          });
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 130,
                          backgroundColor: Colors.white,
                          child: Image.asset("assets/images/logo.webp"),
                        ),
                        inputMethod(
                          "* Login...",
                          "[a-z A-Z 0-9 -]",
                          "",
                          false,
                          false,
                          () {},
                          context,
                          _loginCtrl,
                          0,
                          true,
                        ),
                        inputMethod(
                          "* Parol...",
                          "[a-z A-Z 0-9]",
                          "",
                          true,
                          _passwordVisible1,
                          _toggleFunction1,
                          context,
                          _passCtrl,
                          0,
                          true,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Paroly ubutdym !?",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isChecked = !_isChecked;

                              if (!_isChecked) {
                                _checkBoxColor = Colors.white;
                                _borderColor = Colors.black54;
                              } else {
                                _checkBoxColor = Theme.of(context).primaryColor;
                                _borderColor = Theme.of(context).primaryColor;
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  alignment: Alignment.center,
                                  duration: const Duration(milliseconds: 300),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _checkBoxColor,
                                    border: Border.all(
                                      color: _borderColor,
                                      width: 2,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(3)),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                const Text(
                                  "Paroly ýatda sakla",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        elevationButtonMethod(
                          context,
                          "Içeri girmek",
                          Theme.of(context).primaryColor,
                          Colors.white,
                          () async {
                            if (_loginCtrl.text.length < 3) {
                              showToastMethod("Login iň az 3 harp bolmaly !");
                              return;
                            }

                            if (_passCtrl.text.length < 6) {
                              showToastMethod(
                                  "Şahsy otag üçin parol iň az 6 harp bolmalydyr !");
                              return;
                            }

                            StaticData staticData = StaticData();
                            final connectionResult = await checkNetwork();

                            if (connectionResult) {
                              final deviceName = await getDeviceName();

                              var responseLogin = await http.get(
                                Uri.parse(
                                  "${staticData.getUrl()}/get_token?device=$deviceName&login=${_loginCtrl.text}&password=${_passCtrl.text}",
                                ),
                              );

                              var loginJsonData =
                                  jsonDecode(responseLogin.body);

                              if (loginJsonData['status']
                                      .toString()
                                      .toLowerCase() ==
                                  'false') {
                                showToastMethod(loginJsonData['message']);
                              } else {
                                if (context.mounted) {
                                  if (_isChecked) {
                                    localStoradge.changeUserToken(
                                        loginJsonData['token']);

                                    localStoradge.changeGuestToken(
                                        loginJsonData['token']);
                                  }

                                  localStoradge
                                      .changeUserCode(loginJsonData['code']);

                                  localStoradge
                                      .changeUserName(loginJsonData['name']);

                                  localStoradge.changeUserID(
                                      int.parse(loginJsonData['id']));

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const StagesPage(),
                                    ),
                                  );

                                  showToastMethod(
                                      "Hoş geldiňiz ${loginJsonData['name']}");
                                }
                              }
                            } else {
                              checkConnection();
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
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
      ),
    );
  }
}
