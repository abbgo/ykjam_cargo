import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/repository_data.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:http/http.dart' as http;
import 'package:ykjam_cargo/helpers/font_size.dart';
import 'package:ykjam_cargo/methods/stages_page_methods.dart';
import 'package:ykjam_cargo/pages/item_page.dart';

class InvenItemPage extends StatefulWidget {
  const InvenItemPage({
    super.key,
    required this.invenName,
    required this.invenID,
    required this.partID,
    required this.supposedWeight,
    required this.isUnowned,
  });

  final String invenName;
  final int invenID, partID, supposedWeight;
  final bool isUnowned;

  @override
  State<InvenItemPage> createState() => _InvenItemPageState();
}

class _InvenItemPageState extends State<InvenItemPage> {
  // INIT STATE ----------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _getInvenItem();
  }

  // VARIABLES -------------------------------------------------------------------
  bool _internetConnection = true;
  String token = "";
  bool _showErr = false;
  bool _loading = true;
  bool _showSearchBar = false;
  StaticData staticData = StaticData();
  InvenItem invenItem = InvenItem("", "", "", "", [], []);
  List<Item> searchResult = [];

  // FUNCTIONS -----------------------------------------------------------------
  Future<void> _getInvenItem() async {
    final internetConnection = await checkNetwork();
    _internetConnection = internetConnection;

    if (_internetConnection) {
      if (context.mounted) {
        final localStoragde =
            Provider.of<LocalStoradge>(context, listen: false);

        await localStoragde.getGuestTokenFromSharedPref();

        setState(() {
          token = localStoragde.getGuestToken();
        });
      }

      var response = await http.get(Uri.parse(
          "${staticData.getUrl()}/inven_items?key=$token&part_id=${widget.partID}&inv=${widget.invenID}&supp_weight=${widget.supposedWeight}"));

      var jsonData = jsonDecode(response.body);

      if ((response.statusCode == 400) ||
          ((response.statusCode == 200) && jsonData.containsKey('status'))) {
        setState(() {
          _showErr = true;
          _loading = false;
        });

        return;
      }

      setState(() {
        invenItem.totalCubeText = jsonData['total_cube_text'];
        invenItem.extraWeightText = jsonData['extra_weight_text'];
        invenItem.servicePriceText = jsonData['service_price_text'];
        invenItem.totalPriceText = jsonData['total_price_text'];

        List<Service> services = [];
        List<Item> items = [];

        for (var serv in jsonData['services']) {
          Service service = Service(
            int.parse(serv['id']),
            serv['price'],
            serv['descr'],
            serv['date'],
          );

          services.add(service);
        }
        invenItem.services = services;

        for (var itm in jsonData['items']) {
          Item item = Item(
            itm['id'],
            itm['code'],
            itm['name'],
            itm['cube'],
            itm['count'],
            itm['stuk'],
            itm['weight'],
            itm['weight_unit'],
            itm['cube_unit'],
            itm['date'],
            itm['extra_weight'],
            itm['price'],
            itm['total_price'],
          );

          items.add(item);
        }
        invenItem.items = items;
        searchResult = items;

        _loading = false;
      });
    } else {
      setState(() {
        _internetConnection = false;
      });
    }
  }

  _toggleSearchBar() {
    setState(() {
      searchResult = invenItem.items;
      _showSearchBar = !_showSearchBar;
    });
  }

  _search(String newValue) {
    setState(() {
      searchResult = [];

      for (var itm in invenItem.items) {
        if (itm.name.toLowerCase().contains(newValue..toLowerCase()) ||
            itm.code.toLowerCase().contains(newValue.toLowerCase())) {
          searchResult.add(itm);
        }
      }
    });
  }

  _sortByName(int sort) {
    setState(() {
      int lenItems = searchResult.length;

      for (var i = 0; i < lenItems; i++) {
        for (var j = i; j < lenItems; j++) {
          Item itm;
          String iName = searchResult[i].name.toLowerCase();
          String jName = searchResult[j].name.toLowerCase();

          if (jName.compareTo(iName) == sort) {
            itm = searchResult[i];
            searchResult[i] = searchResult[j];
            searchResult[j] = itm;
          }
        }
      }
    });
  }

  _sortByCode(int sort) {
    setState(() {
      int lenItems = searchResult.length;

      for (var i = 0; i < lenItems; i++) {
        for (var j = i; j < lenItems; j++) {
          Item itm;

          List<String> iDateStrArr = searchResult[i].date.split(".");
          List<String> jDateStrArr = searchResult[j].date.split(".");

          DateTime iDate = DateTime.parse(
              "${iDateStrArr[2]}-${iDateStrArr[1]}-${iDateStrArr[0]}");
          DateTime jDate = DateTime.parse(
              "${jDateStrArr[2]}-${jDateStrArr[1]}-${jDateStrArr[0]}");

          if (jDate.compareTo(iDate) == sort) {
            itm = searchResult[i];
            searchResult[i] = searchResult[j];
            searchResult[j] = itm;
          }
        }
      }
    });
  }

  _sortAZ() {
    _sortByName(-1);
  }

  _sortZA() {
    _sortByName(1);
  }

  _sortCodeASC() {
    _sortByCode(-1);
  }

  _sortCodeDESC() {
    _sortByCode(1);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocalStoradge>(
      create: (context) => LocalStoradge(),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _getInvenItem,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomScrollView(
                  slivers: [
                    sliverAppBarMethod(context, () {
                      Navigator.pop(context);
                    }, widget.invenName, true, _showSearchBar, _toggleSearchBar,
                        _search, _sortAZ, _sortZA, _sortCodeASC, _sortCodeDESC),
                    SliverList(
                      delegate: SliverChildListDelegate(_loading
                          ? shimmerListMethod(4, 150)
                          : _showErr
                              ? showErrMethod(
                                  context, "Käbir ýalňyşlyk ýüze çykdy!")
                              : (searchResult.isEmpty)
                                  ? showErrMethod(
                                      context, "Hiçhili haryt tapylmady!")
                                  : List.generate(
                                      _showSearchBar
                                          ? searchResult.length
                                          : invenItem.items.length,
                                      (index) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ItemPage(
                                                          itemID: _showSearchBar
                                                              ? searchResult[
                                                                      index]
                                                                  .id
                                                              : invenItem
                                                                  .items[index]
                                                                  .id,
                                                          invenID:
                                                              widget.invenID,
                                                          partID: widget.partID,
                                                          supposedWeight: widget
                                                              .supposedWeight,
                                                          invenItemCount:
                                                              _showSearchBar
                                                                  ? searchResult[
                                                                          index]
                                                                      .count
                                                                  : invenItem
                                                                      .items[
                                                                          index]
                                                                      .count,
                                                          invenItemStuk:
                                                              _showSearchBar
                                                                  ? searchResult[
                                                                          index]
                                                                      .stuk
                                                                  : invenItem
                                                                      .items[
                                                                          index]
                                                                      .stuk,
                                                        )));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(20),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      _showSearchBar
                                                          ? searchResult[index]
                                                              .name
                                                          : invenItem
                                                              .items[index]
                                                              .name,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            calculateFontSize(
                                                                context, 16),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        _showSearchBar
                                                            ? "Kody: ${searchResult[index].code}"
                                                            : "Kody: ${invenItem.items[index].code}",
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade600,
                                                          fontSize:
                                                              calculateFontSize(
                                                                  context, 14),
                                                        ),
                                                      ),
                                                      !widget.isUnowned
                                                          ? Text(
                                                              _showSearchBar
                                                                  ? searchResult[index]
                                                                              .totalPrice !=
                                                                          0
                                                                      ? "\$${searchResult[index].totalPrice}"
                                                                      : ""
                                                                  : invenItem.items[index]
                                                                              .totalPrice !=
                                                                          0
                                                                      ? "\$${invenItem.items[index].totalPrice}"
                                                                      : "",
                                                              style:
                                                                  const TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      _showSearchBar
                                                          ? "Ugra gelen sene: ${searchResult[index].date}"
                                                          : "Ugra gelen sene: ${invenItem.items[index].date}",
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontSize:
                                                            calculateFontSize(
                                                                context, 14),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Text(
                                                            _showSearchBar
                                                                ? "Ýer sany: ${searchResult[index].count}"
                                                                : "Ýer sany: ${invenItem.items[index].count}",
                                                            style: TextStyle(
                                                              fontSize:
                                                                  calculateFontSize(
                                                                      context,
                                                                      14),
                                                            ),
                                                          ),
                                                          Text(
                                                            _showSearchBar
                                                                ? "Sany: ${searchResult[index].stuk} st"
                                                                : "Sany: ${invenItem.items[index].stuk} st",
                                                            style: TextStyle(
                                                              fontSize:
                                                                  calculateFontSize(
                                                                      context,
                                                                      14),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          Text(
                                                            _showSearchBar
                                                                ? "Göwrümi: ${searchResult[index].cube} ${searchResult[index].cubeUnit}"
                                                                : "Göwrümi: ${invenItem.items[index].cube} ${invenItem.items[index].cubeUnit}",
                                                            style: TextStyle(
                                                              fontSize:
                                                                  calculateFontSize(
                                                                      context,
                                                                      14),
                                                            ),
                                                          ),
                                                          Text(
                                                            _showSearchBar
                                                                ? "Agramy: ${searchResult[index].weight} ${searchResult[index].weightUnit}"
                                                                : "Agramy: ${invenItem.items[index].weight} ${invenItem.items[index].weightUnit}",
                                                            style: TextStyle(
                                                              fontSize:
                                                                  calculateFontSize(
                                                                      context,
                                                                      14),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                        ..add(
                          const Padding(
                            padding: EdgeInsets.only(bottom: 20),
                          ),
                        )
                        ..add(
                          !_showSearchBar && !widget.isUnowned
                              ? Padding(
                                  padding: EdgeInsets.zero,
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      labelText: '  Harytlaryň jemi hasabaty  ',
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              textMethod("Jemi göwrüm:"),
                                              textMethod("Jemi artyk agramy:"),
                                              textMethod("Goşmaça töleg:"),
                                              textMethod("Jemi töleg:"),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                invenItem.totalCubeText,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: calculateFontSize(
                                                      context, 16),
                                                ),
                                              ),
                                              Text(
                                                invenItem.extraWeightText,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: calculateFontSize(
                                                      context, 16),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        backgroundColor:
                                                            Colors.white,
                                                        title: const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  bottom: 10),
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.info),
                                                              SizedBox(
                                                                  width: 10),
                                                              Text("Maglumat"),
                                                            ],
                                                          ),
                                                        ),
                                                        content: FittedBox(
                                                          fit: BoxFit.fill,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: invenItem
                                                                .services
                                                                .map(
                                                                    (service) =>
                                                                        Row(
                                                                          children: [
                                                                            Text("${service.date} - "),
                                                                            Text(
                                                                              "\$${service.price}",
                                                                              style: const TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                            Text(" - ${service.descr}"),
                                                                          ],
                                                                        ))
                                                                .toList(),
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                                "OK"),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      invenItem
                                                          .servicePriceText,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            calculateFontSize(
                                                                context, 16),
                                                      ),
                                                    ),
                                                    const Icon(Icons.info,
                                                        size: 18),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                invenItem.totalPriceText,
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: calculateFontSize(
                                                      context, 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const Padding(padding: EdgeInsets.zero),
                        )),
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
                    ? errorHandleMethod(context, _getInvenItem)
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Text textMethod(String text) => Text(
        text,
        style: TextStyle(
          fontSize: calculateFontSize(context, 16),
        ),
      );
}
