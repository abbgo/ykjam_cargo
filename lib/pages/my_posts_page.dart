import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/post_data.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:http/http.dart' as http;
import 'package:ykjam_cargo/methods/stages_page_methods.dart';
import 'package:ykjam_cargo/pages/add_post_page.dart';
import 'package:ykjam_cargo/pages/posts_page.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  // INIT STATE ----------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _getMyPosts();
  }

  // VARIABLES -------------------------------------------------------------------
  bool _internetConnection = true;
  String token = "";
  bool _showErr = false;
  bool _loading = true;

  List<MyPost> myPosts = [];
  StaticData staticData = StaticData();

  // FUNCTIONS -----------------------------------------------------------------
  _getMyPosts() async {
    final internetConnection = await checkNetwork();
    _internetConnection = internetConnection;

    if (_internetConnection) {
      if (context.mounted) {
        final localStoragde =
            Provider.of<LocalStoradge>(context, listen: false);
        await localStoragde.getUserTokenFromSharedPref();
        setState(() {
          token = localStoragde.getUserToken();
        });
      }

      var response = await http
          .get(Uri.parse("${staticData.getUrl()}/my_posts?key=$token&page=0"));

      var jsonData = jsonDecode(response.body);

      if (jsonData is List) {
        for (var data in jsonData) {
          MyPost myPost = MyPost(
            data['id'],
            data['title'],
            data['description'],
            data['date'],
            data['view_count'],
            data['status'],
            data['status_text'],
            data['phone'],
            data['time_ago'],
          );

          setState(() {
            myPosts.add(myPost);
          });
        }
        setState(() {
          _loading = false;
        });
        return;
      }

      if (jsonData.containsKey('status') &&
          (jsonData['status'].toString() == "false")) {
        setState(() {
          _showErr = true;
          _loading = false;
        });

        return;
      }
    } else {
      setState(() {
        _internetConnection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localStoradge = Provider.of<LocalStoradge>(context);
    localStoradge.getUserTokenFromSharedPref();
    localStoradge.getUserIDFromSharedPref();

    String userToken = localStoradge.getUserToken();
    int userID = localStoradge.getUserID();

    return ChangeNotifierProvider<LocalStoradge>(
      create: (context) => LocalStoradge(),
      child: PopScope(
        canPop: true,
        onPopInvoked: (bool didPop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const PostsPage()));
          });
        },
        child: Scaffold(
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomScrollView(
                  slivers: [
                    sliverAppBarMethod(context, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PostsPage()));
                    }, "Meniň bildirişlerim", false, false, () {},
                        (String value) {}, () {}, () {}, () {}, () {}),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        _loading
                            ? shimmerListMethod(4, 150)
                            : _showErr
                                ? showErrMethod(context, "Bildiriş tapylmady!")
                                : List.generate(
                                    myPosts.length,
                                    (index) => GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddPostPage(
                                              isAddPostPage: false,
                                              isShowPage: true,
                                              title: myPosts[index].title,
                                              desciption:
                                                  myPosts[index].description,
                                              phone: myPosts[index].phone,
                                              postID: myPosts[index].id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.white,
                                          border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Expanded(
                                                  flex: 4,
                                                  child: SizedBox(),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    "Üns beriň!"),
                                                                content:
                                                                    SelectableText
                                                                        .rich(
                                                                  TextSpan(
                                                                    text: myPosts[
                                                                            index]
                                                                        .title,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          18,
                                                                    ),
                                                                    children: const <TextSpan>[
                                                                      TextSpan(
                                                                        text:
                                                                            ' - bildiriş hemişelik ýok ediljekdir !',
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                          fontSize:
                                                                              16,
                                                                          fontStyle:
                                                                              FontStyle.normal,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: const Text(
                                                                        "GOÝBOLSUN"),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      StaticData
                                                                          staticData =
                                                                          StaticData();
                                                                      final connectionResult =
                                                                          await checkNetwork();

                                                                      if (connectionResult) {
                                                                        final body =
                                                                            {
                                                                          'new_status':
                                                                              -1
                                                                        };

                                                                        var response =
                                                                            await http.put(
                                                                          Uri.parse(
                                                                              "${staticData.getUrl()}/update_post?key=$userToken&user_id=$userID&post_id=${myPosts[index].id}&status=true"),
                                                                          body:
                                                                              json.encode(body),
                                                                        );

                                                                        var jsonData =
                                                                            jsonDecode(response.body);

                                                                        if (!jsonData[
                                                                            'status']) {
                                                                          showToastMethod(
                                                                              "Käbir ýalnyşlyk ýüze çykdy");
                                                                          return;
                                                                        }

                                                                        setState(
                                                                            () {
                                                                          myPosts.removeWhere((element) =>
                                                                              element.id ==
                                                                              myPosts[index].id);
                                                                        });

                                                                        showToastMethod(
                                                                            "Bildiriş üstünlikli pozuldy!");

                                                                        if (mounted) {
                                                                          Navigator.pop(
                                                                              context);
                                                                        }
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          _internetConnection =
                                                                              false;
                                                                        });
                                                                      }
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                            "OK"),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: const Icon(
                                                            Icons.cancel,
                                                            color: Colors.red),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      GestureDetector(
                                                        child: const Icon(
                                                            Icons.edit),
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      AddPostPage(
                                                                isAddPostPage:
                                                                    false,
                                                                isShowPage:
                                                                    false,
                                                                title: myPosts[
                                                                        index]
                                                                    .title,
                                                                desciption: myPosts[
                                                                        index]
                                                                    .description,
                                                                phone: myPosts[
                                                                        index]
                                                                    .phone,
                                                                postID: myPosts[
                                                                        index]
                                                                    .id,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(myPosts[index].title),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              child: Text(
                                                myPosts[index]
                                                            .description
                                                            .length <=
                                                        85
                                                    ? myPosts[index].description
                                                    : "${myPosts[index].description.substring(0, 85)}...",
                                              ),
                                            ),
                                            Text(
                                              myPosts[index].statusText,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color:
                                                    myPosts[index].status == "0"
                                                        ? Colors.amber.shade800
                                                        : Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
                    ? errorHandleMethod(context, _getMyPosts)
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
