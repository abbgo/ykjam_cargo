import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/repository_data.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:http/http.dart' as http;
import 'package:ykjam_cargo/methods/repositories_page_methods.dart';
import 'package:ykjam_cargo/methods/stages_page_methods.dart';
import 'package:ykjam_cargo/pages/inventory_page.dart';

class RepositoriesPage extends StatefulWidget {
  const RepositoriesPage(
      {super.key, required this.partID, required this.isUnowned});

  final int partID;
  final bool isUnowned;

  @override
  State<RepositoriesPage> createState() => _RepositoriesPageState();
}

class _RepositoriesPageState extends State<RepositoriesPage> {
  // INIT STATE ----------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _getRepositories();
  }

  // VARIABLES -------------------------------------------------------------------
  bool _internetConnection = true;
  String token = "";
  bool _showErr = false;
  bool _loading = true;

  List<Repository> repositories = [];
  StaticData staticData = StaticData();

  // FUNCTIONS -----------------------------------------------------------------
  Future<void> _getRepositories() async {
    final internetConnection = await checkNetwork();
    _internetConnection = internetConnection;

    if (_internetConnection) {
      if (context.mounted) {
        final localStoragde =
            Provider.of<LocalStoradge>(context, listen: false);

        if (widget.isUnowned) {
          await localStoragde.getGuestTokenFromSharedPref();
          setState(() {
            token = localStoragde.getGuestToken();
          });
        } else {
          await localStoragde.getUserTokenFromSharedPref();
          setState(() {
            token = localStoragde.getUserToken();
          });
        }
      }

      Response response;

      if (widget.isUnowned) {
        response = await http
            .get(Uri.parse("${staticData.getUrl()}/unowned?key=$token"));
      } else {
        response = await http.get(Uri.parse(
            "${staticData.getUrl()}/repositories?key=$token&part_id=${widget.partID}"));
      }

      var jsonData = jsonDecode(response.body);

      if (jsonData is List) {
        for (var data in jsonData) {
          List<Inventory> inventories = [];

          for (var inventor in data['inventory']) {
            Inventory inventory = Inventory(
              int.parse(inventor['id']),
              inventor['name'],
              inventor['cube'],
              inventor['cube_unit'],
              inventor['weight'],
              inventor['weight_unit'],
              inventor['count'],
              inventor['total_price'],
            );

            setState(() {
              inventories.add(inventory);
            });
          }

          Repository repository = Repository(
            data['name'],
            data['img'],
            data['total_kub'],
            data['unit_kub'],
            data['total_weight'],
            data['unit_weight'],
            data['total_count'],
            data['total_price'],
            inventories,
            int.parse(data['supposed_weight']),
          );

          setState(() {
            repositories.add(repository);
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
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _getRepositories,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomScrollView(
                  slivers: [
                    sliverAppBarMethod(context, () {
                      Navigator.pop(context);
                    }, "Ýükiň ýeri", false, false, () {}, (String value) {},
                        () {}, () {}, () {}, () {}),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        _loading
                            ? shimmerListMethod(4, 150)
                            : _showErr
                                ? showErrMethod(
                                    context, "Häzirlikçe sizde ýüküň ýeri ýok!")
                                : List.generate(
                                    repositories.length,
                                    (index) => listGeneratePaddingMethod(
                                        index,
                                        context,
                                        repositories[index].totalCount != 0,
                                        (context) {
                                      return InventoryPage(
                                        inventories:
                                            repositories[index].inventories,
                                        supposedWeight:
                                            repositories[index].supposedWeight,
                                        partID: widget.partID,
                                        isUnowned: widget.isUnowned,
                                      );
                                    }, repositories, staticData,
                                        widget.isUnowned),
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
                    ? errorHandleMethod(context, _getRepositories)
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
