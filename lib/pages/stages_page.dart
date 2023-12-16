import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/parts.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:ykjam_cargo/methods/stages_page_methods.dart';
import 'package:ykjam_cargo/pages/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:ykjam_cargo/pages/repositories_page.dart';

class StagesPage extends StatefulWidget {
  const StagesPage({super.key});

  @override
  State<StagesPage> createState() => _StagesPageState();
}

class _StagesPageState extends State<StagesPage> {
  // INIT STATE ----------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _getParts();
  }

  // VARIABLES -------------------------------------------------------------------
  bool _internetConnection = true;
  String userToken = "";
  bool _showErr = false;
  bool _loading = true;

  List<Part> parts = [];

  // FUNCTIONS -----------------------------------------------------------------
  _getParts() async {
    final internetConnection = await checkNetwork();
    _internetConnection = internetConnection;

    if (_internetConnection) {
      if (context.mounted) {
        final localStoragde =
            Provider.of<LocalStoradge>(context, listen: false);

        await localStoragde.getUserTokenFromSharedPref();

        setState(() {
          userToken = localStoragde.getUserToken();
        });
      }

      StaticData staticData = StaticData();

      var response = await http
          .get(Uri.parse("${staticData.getUrl()}/parts?key=$userToken"));
      var jsonData = jsonDecode(response.body);

      if (jsonData is List) {
        for (var data in jsonData) {
          Part part = Part(
            int.parse(data['id']),
            data['name'],
          );

          setState(() {
            parts.add(part);
            _loading = false;
          });
        }

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
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomScrollView(
                  slivers: [
                    sliverAppBarMethod(context, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    }, "Tapgyrlar", false, false, () {}, (String value) {},
                        () {}, () {}, () {}, () {}),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        _loading
                            ? shimmerListMethod(6, 80)
                            : _showErr
                                ? showErrMethod(
                                    context, "Häzirlikçe sizde tapgyr ýok!")
                                : List.generate(
                                    parts.length,
                                    (index) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade200,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RepositoriesPage(
                                                partID: parts[index].id,
                                                isUnowned: false,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                parts[index].name,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.east,
                                                color: Colors.black,
                                              )
                                            ],
                                          ),
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
                    ? errorHandleMethod(context, _getParts)
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
