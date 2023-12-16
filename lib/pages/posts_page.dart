import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/post_data.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:http/http.dart' as http;
import 'package:ykjam_cargo/methods/posts_page_methods.dart';
import 'package:ykjam_cargo/methods/stages_page_methods.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ykjam_cargo/pages/add_post_page.dart';
import 'package:ykjam_cargo/pages/home_page.dart';
import 'package:ykjam_cargo/pages/my_posts_page.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  // INIT STATE ----------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _getPosts();
  }

  // VARIABLES -------------------------------------------------------------------
  bool _internetConnection = true;
  String token = "";
  bool _showErr = false;
  bool _loading = true;

  List<Post> posts = [];
  StaticData staticData = StaticData();
  List<String> postIds = [];
  bool _isFavoritePage = false;

  // FUNCTIONS -----------------------------------------------------------------
  Future<void> _getPosts() async {
    posts = [];
    _isFavoritePage = false;
    _loading = true;

    final internetConnection = await checkNetwork();
    _internetConnection = internetConnection;

    if (_internetConnection) {
      if (context.mounted) {
        final localStoragde =
            Provider.of<LocalStoradge>(context, listen: false);

        await localStoragde.getGuestTokenFromSharedPref();
        await localStoragde.getPostIdsFromSharedPref();

        setState(() {
          token = localStoragde.getGuestToken();
          postIds = localStoragde.getPostIDS();
        });
      }

      var response = await http
          .get(Uri.parse("${staticData.getUrl()}/posts?key=$token&page=0"));

      var jsonData = jsonDecode(response.body);

      if (jsonData is List) {
        for (var data in jsonData) {
          Post post = Post(
            data['id'],
            data['title'],
            data['description'],
            data['date'],
            data['view_count'],
            data['author_id'],
            data['author_name'],
            data['expire_date'],
            data['phone'] ?? "",
            data['time_ago'],
            false,
          );

          for (var postID in postIds) {
            if (postID == post.id.toString()) {
              setState(() {
                post.isFavorite = true;
              });
            }
          }

          setState(() {
            posts.add(post);
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

  _getFavoritePosts() async {
    posts = [];
    _loading = true;

    final internetConnection = await checkNetwork();
    _internetConnection = internetConnection;

    if (_internetConnection) {
      if (context.mounted) {
        final localStoragde =
            Provider.of<LocalStoradge>(context, listen: false);

        await localStoragde.getGuestTokenFromSharedPref();
        await localStoragde.getPostIdsFromSharedPref();

        setState(() {
          token = localStoragde.getGuestToken();
          postIds = localStoragde.getPostIDS();
        });
      }

      String ids = "";
      for (var postID in postIds) {
        ids = "$ids$postID,";
      }

      var response = await http.get(Uri.parse(
          "${staticData.getUrl()}/favorite_posts?key=$token&ids=$ids"));
      var jsonData = jsonDecode(response.body);

      if ((jsonData.containsKey('status') &&
              (jsonData['status'].toString() == "false")) ||
          jsonData["posts"].isEmpty) {
        setState(() {
          _showErr = true;
          _loading = false;
        });

        return;
      }

      for (var data in jsonData["posts"]) {
        Post post = Post(
          int.parse(data['id']),
          data['title'],
          data['description'],
          data['date'],
          int.parse(data['view_count']),
          int.parse(data['author_id']),
          data['author_name'],
          "",
          data['phone'] ?? "",
          data['time_ago'],
          false,
        );

        for (var postID in postIds) {
          if (postID == post.id.toString()) {
            setState(() {
              post.isFavorite = true;
            });
          }
        }

        setState(() {
          posts.add(post);
        });
      }
      setState(() {
        _loading = false;
      });
    } else {
      setState(() {
        _internetConnection = false;
      });
    }

    _isFavoritePage = true;
  }

  @override
  Widget build(BuildContext context) {
    final listenTrue = Provider.of<LocalStoradge>(context);
    listenTrue.getUserTokenFromSharedPref();
    String userToken = listenTrue.getUserToken();

    listenTrue.getGuestTokenFromSharedPref();
    String guestToken = listenTrue.getGuestToken();

    return ChangeNotifierProvider<LocalStoradge>(
      create: (context) => LocalStoradge(),
      child: PopScope(
        canPop: true,
        onPopInvoked: (bool didPop) {
          if (!_isFavoritePage) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const HomePage()));
            });
          }
          _getPosts();
        },
        child: Scaffold(
          floatingActionButton: _isFavoritePage
              ? null
              : FloatingActionButton(
                  shape: const CircleBorder(),
                  onPressed: () {
                    userToken == ""
                        ? dialogMethod(context)
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddPostPage(
                                      isAddPostPage: true,
                                      isShowPage: false,
                                      title: "",
                                      desciption: "",
                                      phone: "",
                                      postID: 0,
                                    )));
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add),
                ),
          body: RefreshIndicator(
            onRefresh: _getPosts,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        actions: _isFavoritePage
                            ? []
                            : [
                                PopupMenuButton(
                                  icon: const Icon(Icons.more_horiz, size: 30),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      onTap: () {
                                        userToken == ""
                                            ? dialogMethod(context)
                                            : Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const AddPostPage(
                                                          isAddPostPage: true,
                                                          isShowPage: false,
                                                          title: "",
                                                          desciption: "",
                                                          phone: "",
                                                          postID: 0,
                                                        )));
                                      },
                                      child: const Text("Täze bildiriş"),
                                    ),
                                    PopupMenuItem(
                                      child: GestureDetector(
                                        child:
                                            const Text("Meniň bildirişlerim"),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MyPostsPage()));
                                        },
                                      ),
                                    ),
                                    PopupMenuItem(
                                      onTap: () {
                                        setState(() {
                                          _getFavoritePosts();
                                        });
                                      },
                                      child: const Text("Halanlarym"),
                                    ),
                                  ],
                                ),
                              ],
                        leading: GestureDetector(
                          onTap: () {
                            !_isFavoritePage
                                ? Navigator.pop(context)
                                : _getPosts();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Icon(Icons.adaptive.arrow_back),
                          ),
                        ),
                        expandedHeight: 150,
                        surfaceTintColor: Colors.white,
                        pinned: true,
                        floating: true,
                        flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          titlePadding:
                              const EdgeInsets.only(bottom: 20, left: 10),
                          title: Text(
                            _isFavoritePage ? "Halanlarym" : "Bildirişler",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          _loading
                              ? shimmerListMethod(4, 150)
                              : _showErr
                                  ? showErrMethod(
                                      context, "Bildiriş tapylmady!")
                                  : List.generate(
                                      posts.length,
                                      (index) => GestureDetector(
                                        onTap: () async {
                                          StaticData staticData = StaticData();
                                          final connectionResult =
                                              await checkNetwork();

                                          if (connectionResult) {
                                            // var response = await http.put(
                                            //   Uri.parse(
                                            //       "${staticData.getUrl()}/viewed_post?key=$userToken&user_id=$userID&post_id=${posts[index].id}"),
                                            // );

                                            var response = await http.put(
                                              Uri.parse(
                                                  "${staticData.getUrl()}/viewed_post?key=$guestToken&post_id=${posts[index].id}"),
                                            );

                                            var jsonData =
                                                jsonDecode(response.body);

                                            if (!jsonData['status']) {
                                              showToastMethod(
                                                  "Käbir ýalnyşlyk ýüze çykdy");
                                              return;
                                            }

                                            setState(() {
                                              posts[index].viewCount++;
                                            });
                                          } else {
                                            setState(() {
                                              _internetConnection = false;
                                            });
                                          }

                                          if (mounted) {
                                            showModalBottomSheet(
                                              isScrollControlled: true,
                                              context: context,
                                              builder: (context) {
                                                return StatefulBuilder(
                                                  builder: (BuildContext
                                                          context,
                                                      void Function(
                                                              void Function())
                                                          setState) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20,
                                                          vertical: 30),
                                                      child: Wrap(
                                                        children: [
                                                          columnMethod(
                                                              index, posts),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        10),
                                                            child: Text(
                                                              posts[index]
                                                                  .description,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600),
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                posts[index]
                                                                    .phone,
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 18,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                onPressed: () {
                                                                  Clipboard
                                                                      .setData(
                                                                    ClipboardData(
                                                                      text: posts[
                                                                              index]
                                                                          .phone,
                                                                    ),
                                                                  );
                                                                },
                                                                icon: const Icon(
                                                                    Icons.copy,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              elevatedButtonMethod(
                                                                  "Haladym",
                                                                  posts[index]
                                                                          .isFavorite
                                                                      ? Icons
                                                                          .favorite
                                                                      : Icons
                                                                          .favorite_border,
                                                                  () {
                                                                Provider.of<LocalStoradge>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .changePostIDToSharedPref(
                                                                        posts[index]
                                                                            .id
                                                                            .toString());

                                                                setState(
                                                                  () {
                                                                    posts[index]
                                                                        .isFavorite = !posts[
                                                                            index]
                                                                        .isFavorite;
                                                                  },
                                                                );
                                                              }, posts),
                                                              elevatedButtonMethod(
                                                                  "Paýlaş",
                                                                  Icons.share,
                                                                  () async {
                                                                await Share.share(
                                                                    "Ykjam Cargo ${posts[index].title} Düşündiriş: ${posts[index].description.substring(0, 31)}... Bildirişi doly okamak üçin Play Google-dan ýükle: https://play.google.com/store/apps/details?id=com.grsofts.cargotracker");
                                                              }, posts),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          }
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
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              columnMethod(index, posts),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Provider.of<LocalStoradge>(
                                                                context,
                                                                listen: false)
                                                            .changePostIDToSharedPref(
                                                                posts[index]
                                                                    .id
                                                                    .toString());

                                                        setState(
                                                          () {
                                                            posts[index]
                                                                    .isFavorite =
                                                                !posts[index]
                                                                    .isFavorite;

                                                            if (_isFavoritePage &&
                                                                !posts[index]
                                                                    .isFavorite) {
                                                              posts.removeWhere(
                                                                  (element) =>
                                                                      element
                                                                          .id ==
                                                                      posts[index]
                                                                          .id);
                                                            }
                                                          },
                                                        );
                                                      },
                                                      child: Icon(posts[index]
                                                              .isFavorite
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        await Share.share(
                                                            "Ykjam Cargo ${posts[index].title} Düşündiriş: ${posts[index].description.substring(0, 31)}... Bildirişi doly okamak üçin Play Google-dan ýükle: https://play.google.com/store/apps/details?id=com.grsofts.cargotracker");
                                                      },
                                                      child: const Icon(
                                                          Icons.share),
                                                    ),
                                                  ],
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
                      ? errorHandleMethod(context, _getPosts)
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> dialogMethod(BuildContext context) {
    return showDialog(
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
          content: const Text("Ulgama girmegiňizi haýyş edýäris !"),
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
  }
}
