import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:ykjam_cargo/datas/service_price_data.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:http/http.dart' as http;
import 'package:ykjam_cargo/helpers/font_size.dart';
import 'package:ykjam_cargo/methods/stages_page_methods.dart';
import 'package:ykjam_cargo/pages/calculate_page.dart';

class ServicePrices extends StatefulWidget {
  const ServicePrices({super.key});

  @override
  State<ServicePrices> createState() => _ServicePricesState();
}

class _ServicePricesState extends State<ServicePrices> {
  // INIT STATE ----------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _getServicePrices();
  }

  // VARIABLES -------------------------------------------------------------------
  bool _internetConnection = true;
  String guestToken = "";
  bool _showErr = false;
  bool _loading = true;

  StaticData staticData = StaticData();
  List<ServicePrice> prices = [];

  // FUNCTIONS -----------------------------------------------------------------
  Future<void> _getServicePrices() async {
    final internetConnection = await checkNetwork();
    _internetConnection = internetConnection;

    if (_internetConnection) {
      if (context.mounted) {
        final localStoragde =
            Provider.of<LocalStoradge>(context, listen: false);

        await localStoragde.getGuestTokenFromSharedPref();

        setState(() {
          guestToken = localStoragde.getGuestToken();
        });
      }

      var response = await http
          .get(Uri.parse("${staticData.getUrl()}/prices?key=$guestToken"));
      var jsonData = jsonDecode(response.body);

      if (jsonData is List) {
        for (var data in jsonData) {
          ServicePrice price = ServicePrice(
            data['id'],
            data['price'],
            data['price_txt'],
            data['description'],
          );
          setState(() {
            prices.add(price);
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
    return ChangeNotifierProvider<LocalStoradge>(
      create: (context) => LocalStoradge(),
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomScrollView(
                slivers: [
                  sliverAppBarMethod(context, () {
                    Navigator.pop(context);
                  }, "Hyzmat bahalary", false, false, () {}, (String value) {},
                      () {}, () {}, () {}, () {}),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      _loading
                          ? shimmerListMethod(6, 100)
                          : _showErr
                              ? showErrMethod(
                                  context, "Käbit ýalňyşlyk ýüze çykdy!")
                              : List.generate(
                                  prices.length,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    // padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ListTile(
                                      title: Html(
                                        data: prices[index].description,
                                        style: {
                                          'body': Style(
                                            fontSize: FontSize(
                                                calculateFontSize(context, 18)),
                                          ),
                                        },
                                      ),
                                      subtitle: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "  ${prices[index].priceTxt}",
                                          style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontSize:
                                                calculateFontSize(context, 20),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      trailing: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CalculatePage(
                                                price: prices[index],
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.calculate,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
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
                  ? errorHandleMethod(context, _getServicePrices)
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
