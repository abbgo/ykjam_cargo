import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:ykjam_cargo/helpers/font_size.dart';
import 'package:ykjam_cargo/pages/posts_page.dart';
import 'package:ykjam_cargo/pages/statute_page.dart';
import 'package:http/http.dart' as http;

class AddPostPage extends StatefulWidget {
  const AddPostPage(
      {super.key,
      required this.isAddPostPage,
      required this.isShowPage,
      required this.title,
      required this.desciption,
      required this.phone,
      required this.postID});

  final bool isAddPostPage, isShowPage;
  final String title, desciption, phone;
  final int postID;

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  // INIT STATE ----------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _isShowPage = widget.isShowPage;

    if (!widget.isAddPostPage) {
      _titleCtrl.text = widget.title;
      _descCtrl.text = widget.desciption;
    }
  }

  // VARIABLES -----------------------------------------------------------------
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  bool _isChecked1 = false;
  Color _checkBoxColor1 = Colors.white;
  Color _borderColor1 = Colors.black;
  bool _internetConnection = true;

  bool _isShowPage = false;

  // FUNCTIONS -----------------------------------------------------------------
  checkConnection() async {
    final connectResult = await checkNetwork();

    setState(() {
      _internetConnection = connectResult;
    });
  }

  _addOrUpdatePost() async {
    final localStoradge = Provider.of<LocalStoradge>(context, listen: false);
    localStoradge.getUserTokenFromSharedPref();
    String userToken = localStoradge.getUserToken();

    localStoradge.getUserIDFromSharedPref();
    int userID = localStoradge.getUserID();

    if (_titleCtrl.text == "" || _descCtrl.text == "") {
      showToastMethod("Bildirişiň maglumatlary örän gysga !");
      return;
    }

    if (widget.isAddPostPage) {
      if (!RegExp("^(\\+9936)[1-5][0-9]{6}\$")
          .hasMatch("+993${_phoneCtrl.text}")) {
        showToastMethod("Telefon belgiňizi dogry giriziň !");
        return;
      }

      if (!_isChecked1) {
        showToastMethod(
            "Ulanyjy düzgünleri bilen tanyşyp tassylamagyňyzky haýyş edýäris !");
        return;
      }
    }

    StaticData staticData = StaticData();
    final connectionResult = await checkNetwork();

    if (connectionResult) {
      Map<String, String> body;
      Response response;

      if (widget.isAddPostPage) {
        body = {
          'title': _titleCtrl.text,
          'description': _descCtrl.text,
          'phone': "+993${_phoneCtrl.text}",
        };

        response = await http.post(
          Uri.parse("${staticData.getUrl()}/newpost?key=$userToken"),
          body: json.encode(body),
        );
      } else {
        body = {
          'new_title': _titleCtrl.text,
          'new_description': _descCtrl.text,
        };

        response = await http.put(
          Uri.parse(
              "${staticData.getUrl()}/update_post?key=$userToken&user_id=$userID&post_id=${widget.postID}&status=false"),
          body: json.encode(body),
        );
      }

      var jsonData = jsonDecode(response.body);

      if ((response.statusCode == 201 && widget.isAddPostPage) ||
          response.statusCode == 200) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  widget.isAddPostPage
                      ? "Bildiriş ugradyldy"
                      : "Bildiriş üýtgedildi",
                ),
                content: Text(
                  "Bildirişiňiz moderasiýa ugradyldy. Moderasiýa kabul edenden soň bildirişiňiz 30 günlik goýular. Wagty dolan bildirişler awtomat ýagdaýda ýatyrylýar",
                  style: TextStyle(fontSize: calculateFontSize(context, 16)),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PostsPage()));
                      },
                      child: const Text("OK"))
                ],
              );
            },
          );
        }
      } else {
        showToastMethod(jsonData['message']);
      }
    } else {
      setState(() {
        _internetConnection = false;
      });
    }
  }

  // DISPOSE -------------------------------------------------------------------
  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocalStoradge>(
      create: (context) => LocalStoradge(),
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    leading: GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Icon(Icons.adaptive.arrow_back),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    expandedHeight: 150,
                    surfaceTintColor: Colors.white,
                    pinned: true,
                    floating: true,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      titlePadding: const EdgeInsets.only(bottom: 20, left: 10),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.isAddPostPage
                                ? "Täze bildiriş"
                                : widget.title.length <= 15
                                    ? widget.title
                                    : "${widget.title.substring(0, 15)}...",
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          if (_isShowPage)
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isShowPage = !_isShowPage;
                                });
                              },
                            )
                          else
                            const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        textfieldMethod(
                            "Bildiriş mowzugy...",
                            _titleCtrl,
                            TextInputType.text,
                            1,
                            null,
                            _isShowPage ? false : true),
                        textfieldMethod(
                            "Bildiriş düşündirişi...",
                            _descCtrl,
                            TextInputType.multiline,
                            8,
                            null,
                            _isShowPage ? false : true),
                        if (widget.isAddPostPage)
                          textfieldMethod(
                            "Telefon belgi...",
                            _phoneCtrl,
                            TextInputType.phone,
                            1,
                            Center(
                              widthFactor: 1,
                              child: Text(
                                " +993",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: calculateFontSize(context, 16),
                                ),
                              ),
                            ),
                            true,
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            child: Text(
                              widget.phone,
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 18),
                            ),
                          ),
                        widget.isAddPostPage
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
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
                                        duration:
                                            const Duration(milliseconds: 300),
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
                              )
                            : const SizedBox(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor),
                          onPressed: _addOrUpdatePost,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              "Ýatda sakla",
                              style: TextStyle(color: Colors.white),
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
    );
  }

  Padding textfieldMethod(
      String hintText,
      TextEditingController controller,
      TextInputType keyboardType,
      int? maxLines,
      Widget? prefixIcon,
      bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        style: TextStyle(fontSize: calculateFontSize(context, 16)),
        textAlignVertical: TextAlignVertical.center,
        enabled: enabled,
        maxLines: maxLines,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
