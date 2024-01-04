import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/register_page_data.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:ykjam_cargo/methods/register_page_methods.dart';
import 'package:ykjam_cargo/pages/home_page.dart';
import 'package:ykjam_cargo/pages/statute_page.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // VARIABLES -------------------------------------------------------------------
  List<String> _countries = [];
  String _selectedCity = "";
  List<String> _cities = [];
  String _selectedCountry = "";
  bool _isChecked = true;
  bool _isChecked1 = false;
  bool _passwordVisible1 = true;
  bool _passwordVisible2 = true;
  Color _checkBoxColor = const Color.fromRGBO(0, 71, 138, 1);
  Color _borderColor = const Color.fromRGBO(0, 71, 138, 1);
  Color _checkBoxColor1 = Colors.white;
  Color _borderColor1 = Colors.black;
  int _counterNameLenght = 0;
  int _counterLoginLenght = 0;
  int _counterDistictLenght = 0;
  int _counterStreetLenght = 0;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _loginCtrl = TextEditingController();
  final TextEditingController _distictCtrl = TextEditingController();
  final TextEditingController _streetCtrl = TextEditingController();
  final TextEditingController _phone1Ctrl = TextEditingController();
  final TextEditingController _phone2Ctrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _whetchatCtrl = TextEditingController();
  final TextEditingController _whatsappCtrl = TextEditingController();
  final TextEditingController _imoCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _verifyPassCtrl = TextEditingController();

  bool _internetConnection = true;

  // INIT STATE -----------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    checkConnection();

    _countries = getCountries();
    if (_countries.isNotEmpty) {
      _selectedCountry = _countries[0];
    }

    _cities = getCities();
    if (_cities.isNotEmpty) {
      _selectedCity = _cities[0];
    }

    _nameCtrl.addListener(() {
      setState(() {
        _counterNameLenght = _nameCtrl.text.length;
      });
    });

    _loginCtrl.addListener(() {
      setState(() {
        _counterLoginLenght = _loginCtrl.text.length;
      });
    });

    _distictCtrl.addListener(() {
      setState(() {
        _counterDistictLenght = _distictCtrl.text.length;
      });
    });
    _streetCtrl.addListener(() {
      setState(() {
        _counterStreetLenght = _streetCtrl.text.length;
      });
    });
  }

// FUNCTIONS -------------------------------------------------------------------
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

  checkConnection() async {
    final connectResult = await checkNetwork();

    setState(() {
      _internetConnection = connectResult;
    });
  }

  // DISPOSE -----------------------------------------------------------------
  @override
  void dispose() {
    _nameCtrl.dispose();
    _loginCtrl.dispose();
    _distictCtrl.dispose();
    _streetCtrl.dispose();
    _phone1Ctrl.dispose();
    _phone2Ctrl.dispose();
    _emailCtrl.dispose();
    _whetchatCtrl.dispose();
    _whatsappCtrl.dispose();
    _imoCtrl.dispose();
    _passCtrl.dispose();
    _verifyPassCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localStoradge = Provider.of<LocalStoradge>(context);
    localStoradge.getGuestTokenFromSharedPref();

    return ChangeNotifierProvider<LocalStoradge>(
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
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      leading: GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Icon(Icons.adaptive.arrow_back),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        },
                      ),
                      expandedHeight: 150,
                      surfaceTintColor: Colors.white,
                      pinned: true,
                      floating: true,
                      flexibleSpace: const FlexibleSpaceBar(
                        centerTitle: true,
                        titlePadding: EdgeInsets.only(bottom: 20, left: 10),
                        title: Text(
                          "Hasaba durmak",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              "* - bilen belgilenen öýjükler hökmanydyr. Boş bolup bilmeýär !",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          inputMethod(
                            "* Adyňyz...",
                            "[a-z A-Z]",
                            "$_counterNameLenght/35",
                            false,
                            false,
                            () {},
                            context,
                            _nameCtrl,
                            35,
                            true,
                          ),
                          inputMethod(
                            "* Şahsy otag üçin login...",
                            "[a-z A-Z 0-9 -]",
                            "$_counterLoginLenght/15",
                            false,
                            false,
                            () {},
                            context,
                            _loginCtrl,
                            15,
                            true,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(),
                          ),
                          DropdownButtonFormField<String>(
                            value: _selectedCountry,
                            items: _countries.map(
                              (String e) {
                                return DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                );
                              },
                            ).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedCountry = newValue!;
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: DropdownButtonFormField<String>(
                              value: _selectedCity,
                              items: _cities.map(
                                (String e) {
                                  return DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(e),
                                  );
                                },
                              ).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedCity = newValue!;
                                });
                              },
                            ),
                          ),
                          inputMethod(
                              "Etrap...",
                              "[a-z A-Z]",
                              "$_counterDistictLenght/25",
                              false,
                              false,
                              () {},
                              context,
                              _distictCtrl,
                              25,
                              true),
                          inputMethod(
                              "Köçe...",
                              "[a-z A-Z 0-9 -]",
                              "$_counterStreetLenght/40",
                              false,
                              false,
                              () {},
                              context,
                              _streetCtrl,
                              40,
                              true),
                          inputMethod("* Telefon 1...", "[0-9]", "", false,
                              false, () {}, context, _phone1Ctrl, 8, true),
                          inputMethod("Telefon 2...", "[0-9]", "", false, false,
                              () {}, context, _phone2Ctrl, 8, true),
                          inputMethod(
                            "Email...",
                            "[a-z A-Z 0-9 @ .]",
                            "",
                            false,
                            false,
                            () {},
                            context,
                            _emailCtrl,
                            0,
                            true,
                          ),
                          inputMethod(
                            "Wechat ID...",
                            "[a-z A-Z 0-9]",
                            "",
                            false,
                            false,
                            () {},
                            context,
                            _whetchatCtrl,
                            0,
                            true,
                          ),
                          inputMethod("WhatsApp...", "[a-z A-Z 0-9]", "", false,
                              false, () {}, context, _whatsappCtrl, 0, true),
                          inputMethod("IMO ID...", "[a-z A-Z 0-9]", "", false,
                              false, () {}, context, _imoCtrl, 0, true),
                          inputMethod(
                              "* Şahsy otag üçin parol...",
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
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isChecked = !_isChecked;

                                if (!_isChecked) {
                                  _checkBoxColor = Colors.white;
                                  _borderColor = Colors.black54;
                                } else {
                                  _checkBoxColor =
                                      Theme.of(context).primaryColor;
                                  _borderColor = Theme.of(context).primaryColor;
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isChecked1 = !_isChecked1;

                                      if (!_isChecked1) {
                                        _checkBoxColor1 = Colors.white;
                                        _borderColor1 = Colors.black54;
                                      } else {
                                        _checkBoxColor1 =
                                            Theme.of(context).primaryColor;
                                        _borderColor1 =
                                            Theme.of(context).primaryColor;
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    alignment: Alignment.center,
                                    duration: const Duration(milliseconds: 300),
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _checkBoxColor1,
                                      border: Border.all(
                                        color: _borderColor1,
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
                                ),
                                const SizedBox(width: 15),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const StatutePage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Ulanyjy düzgünlerini",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  " kabul edýärin",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10)),
                              onPressed: () async {
                                if (_nameCtrl.text == "") {
                                  showToastMethod("Adyňyzy doly ýazyň !");
                                  return;
                                }
                                if (_loginCtrl.text.length < 3) {
                                  showToastMethod(
                                      "Login iň az 3 harp bolmaly !");
                                  return;
                                }
                                if (_phone1Ctrl.text.length < 8) {
                                  showToastMethod(
                                      "Telefon belgiňizi doly görkeziň !");
                                  return;
                                }
                                if (!RegExp("^(\\+9936)[1-5][0-9]{6}\$")
                                    .hasMatch("+993${_phone1Ctrl.text}")) {
                                  showToastMethod(
                                      "Telefon belgiňizi dogry giriziň !");
                                  return;
                                }
                                if (_phone2Ctrl.text != "" &&
                                    !RegExp("^(\\+9936)[1-5][0-9]{6}\$")
                                        .hasMatch("+993${_phone2Ctrl.text}")) {
                                  showToastMethod(
                                      "2-nji telefon belgiňizi dogry giriziň !");
                                  return;
                                }
                                if (_emailCtrl.text != "" &&
                                    !RegExp("^[a-z0-9._%+-]+@[a-z0-9.\\-]+\\.[a-z]{2,4}\$")
                                        .hasMatch(_emailCtrl.text)) {
                                  showToastMethod(
                                      "Email adresiňizi dogry giriziň !");
                                  return;
                                }
                                if (_passCtrl.text.length < 6) {
                                  showToastMethod(
                                      "Şahsy otag üçin parol iň az 6 harp bolmalydyr !");
                                  return;
                                }
                                if (_verifyPassCtrl.text != _passCtrl.text) {
                                  showToastMethod(
                                      "Parol we paroly tassyklama deň däl !");
                                  return;
                                }
                                if (!_isChecked1) {
                                  showToastMethod(
                                      "Ulanyjy düzgünleri bilen tanyşyp tassylamagyňyzky haýyş edýäris !");
                                  return;
                                }

                                StaticData staticData = StaticData();
                                final connectionResult = await checkNetwork();

                                if (connectionResult) {
                                  final body = {
                                    'login': _loginCtrl.text,
                                    'name': _nameCtrl.text,
                                    'address':
                                        '${_distictCtrl.text} ${_streetCtrl.text}',
                                    'email': _emailCtrl.text,
                                    'phone': '+993${_phone1Ctrl.text}',
                                    'phone_two': '+993${_phone2Ctrl.text}',
                                    'password': _passCtrl.text,
                                    'city': _selectedCountry,
                                    'region': '$_selectedCity sahercersi'
                                  };

                                  var response = await http.post(
                                    Uri.parse(
                                        "${staticData.getUrl()}/register?key=${localStoradge.getGuestToken()}"),
                                    body: json.encode(body),
                                  );

                                  var jsonData = jsonDecode(response.body);

                                  if (response.statusCode == 201) {
                                    Codec<String, String> stringToBase64 =
                                        utf8.fuse(base64);

                                    String decoded =
                                        stringToBase64.decode(jsonData['hash']);

                                    String userLogin =
                                        jsonDecode(decoded)['login'];
                                    String userPassword =
                                        jsonDecode(decoded)['password'];

                                    final deviceName = await getDeviceName();

                                    var responseLogin = await http.get(
                                      Uri.parse(
                                        "${staticData.getUrl()}/get_token?device=$deviceName&login=$userLogin&password=$userPassword",
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
                                      if (mounted) {
                                        final localLocalStoradge =
                                            Provider.of<LocalStoradge>(context,
                                                listen: false);
                                        if (_isChecked) {
                                          localLocalStoradge.changeUserToken(
                                              loginJsonData['token']);

                                          localLocalStoradge.changeGuestToken(
                                              loginJsonData['token']);
                                        }

                                        localLocalStoradge.changeUserCode(
                                            loginJsonData['code']);

                                        localLocalStoradge.changeUserName(
                                            loginJsonData['name']);

                                        localLocalStoradge.changeUserID(
                                            int.parse(loginJsonData['id']));

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HomePage(),
                                          ),
                                        );
                                      }

                                      showToastMethod("${jsonData['message']}");
                                      showToastMethod(
                                          "Hoş geldiňiz ${_nameCtrl.text}");
                                    }
                                  } else {
                                    showToastMethod(jsonData['message']);
                                  }
                                } else {
                                  setState(() {
                                    _internetConnection = false;
                                  });
                                }
                              },
                              child: const Text(
                                "Hasaba durmak",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                      ),
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
