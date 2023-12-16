import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/chat_data.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:http/http.dart' as http;
import 'package:ykjam_cargo/pages/show_image_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // INIT STATE ----------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _getChatDatas();
  }

  // VARIABLES -------------------------------------------------------------------
  bool _internetConnection = true;
  String token = "";
  bool _showErr = false;
  bool _loading = true;
  int userID = 0;
  int adminID = 0;

  List<ChatData> chats = [];
  StaticData staticData = StaticData();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  File? _image;

  // FUNCTIONS -----------------------------------------------------------------
  Future<void> _getChatDatas() async {
    final internetConnection = await checkNetwork();
    _internetConnection = internetConnection;

    if (_internetConnection) {
      if (context.mounted) {
        final localStoragde =
            Provider.of<LocalStoradge>(context, listen: false);

        await localStoragde.getUserTokenFromSharedPref();
        await localStoragde.getUserIDFromSharedPref();

        setState(() {
          token = localStoragde.getUserToken();
          userID = localStoragde.getUserID();
        });
      }

      var response = await http.get(Uri.parse(
          "${staticData.getUrl()}/messages?key=$token&user_id=$userID"));

      var jsonData = jsonDecode(response.body);

      if (jsonData is List) {
        for (var data in jsonData) {
          ChatData chat = ChatData(
              data['id'],
              data['user_id'],
              data['admin_id'],
              data['message'],
              data['src'] ?? "",
              data['time'],
              data['type'],
              data['readed'],
              Icons.done);

          setState(() {
            chats.add(chat);
            adminID = int.parse(chat.adminID);
          });
        }
        setState(() {
          _loading = false;
        });

        _jumpToBottom();

        return;
      }

      if (jsonData.containsKey('status') &&
          (jsonData['status'].toString() == "false")) {
        setState(() {
          _showErr = true;
          _loading = false;
        });
      }
    } else {
      setState(() {
        _internetConnection = false;
      });
    }
  }

  _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent * 2);
    });
  }

  _animateToBottom(int height) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent * height,
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear);
    });
  }

  Future<void> _getImage(int userID, int type) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }

    _uploadImage(_image, userID, type);
  }

  Future<void> _uploadImage(File? image, int userID, int type) async {
    if (_image == null) {
      showToastMethod("Surat saýlanmady");
      return;
    }

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            "${staticData.getUrl()}/upload.php?key=$token&user_id=$userID&type=$type"));
    request.files.add(await http.MultipartFile.fromPath('img', _image!.path));

    try {
      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 201) {
        var response = await http.Response.fromStream(streamedResponse);
        final result = jsonDecode(response.body) as Map<String, dynamic>;

        DateTime currentTime = DateTime.now();
        String timeStr =
            "${currentTime.day}.${currentTime.month}.${currentTime.year} ${currentTime.hour}:${currentTime.minute}";

        ChatData chat = ChatData("", "", "", "", result['image_name'], timeStr,
            "4", "1", Icons.done);

        setState(() {
          chats.add(chat);
        });

        // Handle success
        showToastMethod("Surat üstünlikli ugradyldy");
      } else {
        showToastMethod("Surat ugradylmady");
        return;
      }
    } catch (error) {
      showToastMethod("Surat ugradylmady");
    }
  }

  // DISPOSE -------------------------------------------------------------------
  @override
  void dispose() {
    _scrollController.dispose();
    _textEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    if (keyboardHeight != 0) {
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + keyboardHeight,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear);
    }

    final localStoradge = Provider.of<LocalStoradge>(context);
    localStoradge.getUserTokenFromSharedPref();

    String userToken = localStoradge.getUserToken();

    return ChangeNotifierProvider<LocalStoradge>(
      create: (context) => LocalStoradge(),
      child: Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
              child: _loading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            textAlign: TextAlign.center,
                            "Siz bu ýerde administrasiýa bilen göni aragatnaşykda hat ýazyp bilersiňiz",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                              strokeAlign: 0.1),
                        ],
                      ),
                    )
                  : _showErr
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: const Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              "Maglumat çekilmedi !",
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: chats.length,
                                itemBuilder: (context, index) {
                                  String adminType = chats[index].type;
                                  bool isUser =
                                      adminType == "2" || adminType == "4";

                                  return Row(
                                    mainAxisAlignment: isUser
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: !isUser ? 0 : screenWidth * 0.1,
                                      ),
                                      if (chats[index].src == "")
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              isUser
                                                  ? Icon(chats[index].icon,
                                                      size: 20,
                                                      color: Colors.black54)
                                                  : const SizedBox(),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: isUser
                                                      ? const Color(0XFFa3b7ff)
                                                      : Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: isUser
                                                        ? const Radius.circular(
                                                            20)
                                                        : Radius.zero,
                                                    topRight: !isUser
                                                        ? const Radius.circular(
                                                            20)
                                                        : Radius.zero,
                                                    bottomLeft:
                                                        const Radius.circular(
                                                            20),
                                                    bottomRight:
                                                        const Radius.circular(
                                                            20),
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    LimitedBox(
                                                      maxWidth:
                                                          screenWidth * 0.6,
                                                      child: Text(
                                                        chats[index].message,
                                                        overflow:
                                                            TextOverflow.clip,
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      textAlign: TextAlign.end,
                                                      chats[index].time,
                                                      style: const TextStyle(
                                                          fontSize: 10),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: SizedBox(
                                            width: screenWidth * 0.6,
                                            child: Column(
                                              crossAxisAlignment: isUser
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                              context) =>
                                                          Dialog.fullscreen(
                                                        child: ShowImage(
                                                          image:
                                                              "${staticData.getUrl()}/${chats[index].src}",
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Image(
                                                    height: screenHeight * 0.3,
                                                    width: screenWidth * 0.5,
                                                    image: NetworkImage(
                                                      "${staticData.getUrl()}/${chats[index].src}",
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    if (isUser)
                                                      Expanded(
                                                        flex: 1,
                                                        child: Icon(
                                                            chats[index].icon,
                                                            size: 20,
                                                            color:
                                                                Colors.black54),
                                                      )
                                                    else
                                                      const SizedBox(),
                                                    Expanded(
                                                      flex: isUser ? 4 : 0,
                                                      child: Text(
                                                        textAlign:
                                                            TextAlign.end,
                                                        chats[index].time,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      Container(
                                        width: isUser ? 0 : screenWidth * 0.1,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            TextField(
                              controller: _textEditingController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: "Siziň hatyňyz...",
                                prefixIcon: IconButton(
                                  icon: const Icon(Icons.image),
                                  onPressed: () {
                                    _getImage(int.parse(chats[0].userID), 4);
                                  },
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.send),
                                  color: Theme.of(context).primaryColor,
                                  onPressed: () async {
                                    if (_textEditingController.text == "") {
                                      showToastMethod("Hatyňyzy ýazyň");
                                      return;
                                    }

                                    DateTime currentTime = DateTime.now();
                                    String timeStr =
                                        "${currentTime.day}.${currentTime.month}.${currentTime.year} ${currentTime.hour}:${currentTime.minute}";

                                    ChatData chat = ChatData(
                                        "",
                                        "",
                                        "",
                                        _textEditingController.text,
                                        "",
                                        timeStr,
                                        "2",
                                        "1",
                                        Icons.schedule);

                                    setState(() {
                                      chats.add(chat);
                                    });

                                    _animateToBottom(1);

                                    StaticData staticData = StaticData();
                                    final connectionResult =
                                        await checkNetwork();

                                    if (connectionResult) {
                                      final body = {
                                        'message': _textEditingController.text,
                                        'user_id': int.parse(chats[0].userID),
                                        'admin_id': adminID,
                                        'type': 2
                                      };

                                      setState(() {
                                        _textEditingController.text = "";
                                      });

                                      final response = await http.post(
                                        Uri.parse(
                                            "${staticData.getUrl()}/new_message?key=$userToken"),
                                        body: json.encode(body),
                                      );

                                      var jsonData = jsonDecode(response.body);

                                      if (jsonData.containsKey('status')) {
                                        setState(() {
                                          chats[chats.length - 1].icon =
                                              Icons.done;
                                        });

                                        return;
                                      }

                                      showToastMethod("Hatyňyz ugradylmady");
                                    } else {
                                      setState(() {
                                        _internetConnection = false;
                                      });
                                    }

                                    if (_textEditingController.text != "") {}
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
            Positioned(
              bottom: 10,
              left: 15,
              child: !(_internetConnection)
                  ? errorHandleMethod(context, _getChatDatas)
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
