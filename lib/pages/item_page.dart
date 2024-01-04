import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/item_data.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:http/http.dart' as http;
import 'package:ykjam_cargo/helpers/font_size.dart';
import 'package:ykjam_cargo/methods/item_page_methods.dart';
import 'package:ykjam_cargo/methods/stages_page_methods.dart';
import 'package:ykjam_cargo/pages/show_image_page.dart';

class ItemPage extends StatefulWidget {
  const ItemPage(
      {super.key,
      required this.itemID,
      required this.invenID,
      required this.partID,
      required this.supposedWeight,
      required this.invenItemCount,
      required this.invenItemStuk});

  final int itemID,
      invenID,
      partID,
      supposedWeight,
      invenItemCount,
      invenItemStuk;

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  // INIT STATE ----------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _getItem();
  }

  // VARIABLES -----------------------------------------------------------------
  bool _internetConnection = true;
  String token = "";
  StaticData staticData = StaticData();
  bool _showErr = false;
  bool _loading = true;
  Item item = Item(0, "", "", "", "", 0, "", "", "", "", false, [],
      Total("", "", "", "", 0, 0, "", 0, "", 0, "", ""));

  late final PageController _pageController;
  int pageNo = 1;
  int imagesLengh = 0;

  // FUNCTIONS -----------------------------------------------------------------
  Future<void> _getItem() async {
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
          "${staticData.getUrl()}/item?key=$token&part_id=${widget.partID}&inv=${widget.invenID}&supp_weight=${widget.supposedWeight}&id=${widget.itemID}"));

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
        item.id = jsonData['id'];
        item.code = jsonData['code'];
        item.name = jsonData['name'];
        item.cubeText = jsonData['cube_text'];
        item.weightText = jsonData['weight_text'];
        item.count = jsonData['count'];
        item.cubeWeightText = jsonData['cube_weight_text'];
        item.supposedWeightText = jsonData['supposed_weight_text'];
        item.extraWeightText = jsonData['extra_weight_text'];
        item.date = jsonData['date'];
        item.imgOK = jsonData['img_ok'];

        List<ItemImage> images = [];
        Total itemTotal = Total("", "", "", "", 0, 0, "", 0, "", 0, "", "");

        for (var img in jsonData['images']) {
          if (img['image'].toString().contains(".jpg")) {
            ItemImage image = ItemImage(int.parse(img['id']), img['image']);
            images.add(image);
          }
        }

        Map<String, dynamic> total = jsonData['total'] as Map<String, dynamic>;

        itemTotal.totalCubePriceText = (total['total_cube_price_text'] != null)
            ? total['total_cube_price_text']
            : "";
        itemTotal.extraWeightText = total['extra_weight_text'];
        itemTotal.servicePriceText = total['service_price_text'];
        itemTotal.totalPriceText = total['total_price_text'];
        itemTotal.totalCount = total['total_count'];
        itemTotal.totalCube = total['total_cube'];
        itemTotal.totalCubeText = total['total_cube_text'];
        itemTotal.totalWeight = total['total_weight'];
        itemTotal.totalCubeWeightText = total['total_cube_weight_text'];
        itemTotal.totalStuk = total['total_stuk'];
        itemTotal.totalSupposedWeightText = total['total_supposed_weight_text'];
        itemTotal.totalExtraWeightText = total['total_extra_weight_text'];

        item.total = itemTotal;
        item.images = images;
        imagesLengh = images.length;

        _loading = false;
      });
    } else {
      setState(() {
        _internetConnection = false;
      });
    }
  }

  // DISPOSE -------------------------------------------------------------------
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider<LocalStoradge>(
      create: (context) => LocalStoradge(),
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _getItem,
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    _loading
                        ? SliverAppBar(
                            expandedHeight: screenHeight * 0.35,
                          )
                        : SliverAppBar(
                            expandedHeight: screenHeight * 0.35,
                            leading: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Icon(Icons.adaptive.arrow_back),
                              ),
                            ),
                            flexibleSpace: FlexibleSpaceBar(
                              background: imagesLengh == 0
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.photo_camera,
                                          size: 100,
                                          color: Colors.grey.shade500,
                                        ),
                                        Text(
                                          "NO IMAGE",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    )
                                  : PageView.builder(
                                      onPageChanged: (value) {
                                        setState(() {
                                          pageNo = value + 1;
                                        });
                                      },
                                      controller: _pageController,
                                      itemBuilder: (_, index) {
                                        return AnimatedBuilder(
                                          animation: _pageController,
                                          builder: (context, child) {
                                            return child!;
                                          },
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        Dialog.fullscreen(
                                                  child: ShowImage(
                                                    image:
                                                        "${staticData.getUrl()}/image/products/${item.images[index].image}",
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Image(
                                              image: NetworkImage(
                                                "${staticData.getUrl()}/image/products/${item.images[index].image}",
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: imagesLengh,
                                    ),
                              centerTitle: false,
                              titlePadding:
                                  const EdgeInsets.only(bottom: 20, left: 10),
                            ),
                          ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        _loading
                            ? shimmerListMethod(4, 150)
                            : _showErr
                                ? showErrMethod(
                                    context, "Käbir ýalňyşlyk ýüze çykdy!")
                                : [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10, left: 10, top: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: imagesLengh == 0
                                                ? [
                                                    const Text("Surat ýok"),
                                                  ]
                                                : [
                                                    const Text("Surat: "),
                                                    Text(pageNo.toString()),
                                                    Text("/$imagesLengh"),
                                                  ],
                                          ),
                                          Text(
                                            item.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: calculateFontSize(
                                                  context, 20),
                                            ),
                                          ),
                                          Text(
                                            "Kody: ${item.code}",
                                            style: TextStyle(
                                              fontSize: calculateFontSize(
                                                  context, 18),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Senesi: ",
                                                style: TextStyle(
                                                  fontSize: calculateFontSize(
                                                      context, 18),
                                                ),
                                              ),
                                              Text(
                                                item.date,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: calculateFontSize(
                                                      context, 18),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20),
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                labelStyle: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                labelText:
                                                    '  Bir ýer sany barada maglumat  ',
                                                border:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  rowMethod(
                                                      "Haryt sany: ",
                                                      widget.invenItemCount
                                                          .toString(),
                                                      context),
                                                  rowMethod("Göwrümi: ",
                                                      item.cubeText, context),
                                                  rowMethod("Agramy: ",
                                                      item.weightText, context),
                                                  Row(
                                                    children: [
                                                      RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            const TextSpan(
                                                              text: 'm',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            WidgetSpan(
                                                              child: Transform
                                                                  .translate(
                                                                offset:
                                                                    const Offset(
                                                                        2, -4),
                                                                child:
                                                                    const Text(
                                                                  '3',
                                                                  textScaler:
                                                                      TextScaler
                                                                          .linear(
                                                                              0.7),
                                                                  // textScaleFactor:
                                                                  //     0.7,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      rowMethod(
                                                          " düşýän paý agramy: ",
                                                          item.cubeWeightText,
                                                          context),
                                                    ],
                                                  ),
                                                  rowMethod(
                                                      "Artyk agramy: ",
                                                      item.extraWeightText,
                                                      context),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "*Bellik: ",
                                                        style: TextStyle(
                                                            fontSize:
                                                                calculateFontSize(
                                                                    context,
                                                                    14)),
                                                      ),
                                                      RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            const TextSpan(
                                                              text: 'm',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            WidgetSpan(
                                                              child: Transform
                                                                  .translate(
                                                                offset:
                                                                    const Offset(
                                                                        2, -4),
                                                                child:
                                                                    const Text(
                                                                  '3',
                                                                  textScaler:
                                                                      TextScaler
                                                                          .linear(
                                                                              0.7),
                                                                  // textScaleFactor:
                                                                  //     0.7,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      rowMethod(
                                                          " rugsat berilen agram: ",
                                                          item.supposedWeightText,
                                                          context),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          InputDecorator(
                                            decoration: InputDecoration(
                                              labelStyle: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              labelText:
                                                  '  Haryt barada jemi maglumat  ',
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      textWithoutBoldMethod(
                                                          "Jemi ýer sany:"),
                                                      textWithoutBoldMethod(
                                                          "Jemi haryt sany:"),
                                                      textWithoutBoldMethod(
                                                          "Jemi göwrümi:"),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Jemi ",
                                                            style: TextStyle(
                                                              fontSize:
                                                                  calculateFontSize(
                                                                      context,
                                                                      14),
                                                            ),
                                                          ),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                const TextSpan(
                                                                  text: 'm',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                WidgetSpan(
                                                                  child: Transform
                                                                      .translate(
                                                                    offset:
                                                                        const Offset(
                                                                            2,
                                                                            -4),
                                                                    child:
                                                                        const Text(
                                                                      '3',
                                                                      textScaler:
                                                                          TextScaler.linear(
                                                                              0.7),
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Text(
                                                            " agramy",
                                                            style: TextStyle(
                                                              fontSize:
                                                                  calculateFontSize(
                                                                      context,
                                                                      14),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      textWithoutBoldMethod(
                                                          "Jemi rugsat berilen agram:"),
                                                      textWithoutBoldMethod(
                                                          "Jemi artyk agramy:"),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      textMethod(
                                                          widget.invenItemCount
                                                              .toString(),
                                                          context),
                                                      textMethod(
                                                          widget.invenItemStuk
                                                              .toString(),
                                                          context),
                                                      textMethod(
                                                          item.total
                                                              .totalCubeText,
                                                          context),
                                                      textMethod(
                                                          item.total
                                                              .totalCubeWeightText,
                                                          context),
                                                      const Text(""),
                                                      textMethod(
                                                          item.total
                                                              .totalSupposedWeightText,
                                                          context),
                                                      textMethod(
                                                          item.total
                                                              .totalExtraWeightText,
                                                          context),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: SizedBox(
                        height: screenHeight * 0.2,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  left: 15,
                  child: !(_internetConnection)
                      ? errorHandleMethod(context, _getItem)
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Text textWithoutBoldMethod(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: calculateFontSize(context, 14),
      ),
    );
  }
}
