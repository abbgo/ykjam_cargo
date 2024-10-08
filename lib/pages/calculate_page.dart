import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ykjam_cargo/database/db.dart';
import 'package:ykjam_cargo/datas/history.dart';
import 'package:ykjam_cargo/datas/service_price_data.dart';
import 'package:intl/intl.dart';
import 'package:ykjam_cargo/helpers/font_size.dart';

// ignore: must_be_immutable
class CalculatePage extends StatefulWidget {
  CalculatePage({super.key, required this.price});

  ServicePrice price;

  @override
  State<CalculatePage> createState() => _CalculatePageState();
}

class _CalculatePageState extends State<CalculatePage> {
  // String _selectedValue = "Metr";

  final TextEditingController _width = TextEditingController();
  final TextEditingController _height = TextEditingController();
  final TextEditingController _length = TextEditingController();
  final TextEditingController _quantity = TextEditingController();

  num result = 0;
  num cube = 0;

  void _showSnackbar(BuildContext context, String input) {
    var snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        '$input - barada doly we dogry maglumat giriziň',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      duration: const Duration(
        seconds: 2,
      ), // Optional: Set the duration for which the Snackbar will be displayed
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _width.dispose();
    _height.dispose();
    _length.dispose();
    _quantity.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "CBM kalkulýator",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Html(
              data: widget.price.description,
              style: {
                'body': Style(
                  fontSize: FontSize(calculateFontSize(context, 18)),
                ),
              },
            ),
            subtitle: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "  ${widget.price.priceTxt}",
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontSize: calculateFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          inputMethod(" Ini ", _width, 0),
          inputMethod(" Boýy ", _height, 1),
          inputMethod(" Uzynlygy ", _length, 2),
          inputMethod(" Sany ", _quantity, 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Container(
              //   decoration: BoxDecoration(
              //     border: Border.all(),
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   margin: const EdgeInsets.only(left: 20),
              //   padding: const EdgeInsets.all(5),
              //   child: DropdownButton<String>(
              //     underline: const SizedBox(),
              //     borderRadius: BorderRadius.circular(10),
              //     value: _selectedValue, // Track the selected value
              //     items: <String>['Metr', 'Santimetr']
              //         .map<DropdownMenuItem<String>>(
              //       (String value) {
              //         return DropdownMenuItem<String>(
              //           value: value,
              //           child: Text(value),
              //         );
              //       },
              //     ).toList(),
              //     onChanged: (newValue) {
              //       setState(() {
              //         _selectedValue = newValue!;
              //       });
              //     },
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (_width.text == "" || _width.text[0] == "0") {
                      _showSnackbar(context, "Ini");
                      return;
                    }
                    if (_height.text == "" || _height.text[0] == "0") {
                      _showSnackbar(context, "Boýy");
                      return;
                    }
                    if (_length.text == "" || _length.text[0] == "0") {
                      _showSnackbar(context, "Uzynlygy");
                      return;
                    }
                    if (_length.text == "" || _length.text[0] == "0") {
                      _showSnackbar(context, "Sany");
                      return;
                    }

                    result = (num.parse(_width.text) *
                            num.parse(_height.text) *
                            num.parse(_length.text) *
                            num.parse(_quantity.text) *
                            widget.price.price) /
                        1000000;

                    cube = num.parse(_width.text) *
                        num.parse(_height.text) *
                        num.parse(_length.text) *
                        num.parse(_quantity.text);

                    // if (_selectedValue == "Santimetr") {
                    //   result = result / 1000000;
                    // }

                    if (result != 0) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Wrap(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Göwrümi:",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      "$cube sm³",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                    Text(
                                      "${cube / 1000000} m³",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    const Text(
                                      "Baha:",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      "${cube / 1000000}m³ * ${widget.price.price}\$ =  $result\$",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Container(
                                      color: Colors.amber.shade200,
                                      child: const ListTile(
                                        leading: Icon(
                                          Icons.warning_amber,
                                          size: 30,
                                        ),
                                        subtitle: Text(
                                            "Ýokardaky baha takmynan bahadyr. Käbir ýagdaýlar sebäpli baha üýtgäp biler !"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  DateTime now = DateTime.now();
                                  String formattedDateTime =
                                      DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .format(now);
                                  final historyDatabase = HistoryDatabase();
                                  final history = History(
                                      num.parse(_height.text),
                                      num.parse(_width.text),
                                      num.parse(_length.text),
                                      widget.price.price,
                                      int.parse(_quantity.text),
                                      formattedDateTime);

                                  await historyDatabase
                                      .insertHistory(history)
                                      .then((value) {
                                    Navigator.pop(context);
                                  });
                                },
                                child: const Text(
                                  "Bolýar",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }

                    setState(() {});
                  },
                  child: const Text(
                    "Hasapla",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // if (result != 0)
          //   Padding(
          //     padding: const EdgeInsets.only(top: 20, left: 20),
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.start,
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           "Göwrümi: $cube sm³",
          //           style: const TextStyle(
          //             fontSize: 18,
          //             fontWeight: FontWeight.bold,
          //             color: Colors.green,
          //           ),
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.only(left: 90, bottom: 10),
          //           child: Text(
          //             " ${cube / 1000000} m³",
          //             style: const TextStyle(
          //               fontSize: 18,
          //               fontWeight: FontWeight.bold,
          //               color: Colors.green,
          //             ),
          //           ),
          //         ),
          //         Text(
          //           "Baha: ${cube / 1000000}m³ * ${widget.price.price}\$ =  $result\$",
          //           style: const TextStyle(
          //             fontSize: 18,
          //             fontWeight: FontWeight.bold,
          //             color: Colors.green,
          //           ),
          //         ),
          //         Container(
          //           decoration: BoxDecoration(color: Colors.amber.shade200),
          //           margin: const EdgeInsets.only(top: 10, right: 20),
          //           padding: const EdgeInsets.all(8),
          //           child: const Row(
          //             children: [
          //               Icon(
          //                 Icons.warning_amber,
          //                 size: 30,
          //               ),
          //               SizedBox(width: 5),
          //               Expanded(
          //                 child: Text(
          //                     "Ýokardaky baha takmynan bahadyr. Käbir ýagdaýlar sebäpli baha üýtgäp biler !"),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ],
          //     ),
          //   )
          // else
          //   const SizedBox(),
        ],
      ),
    );
  }

  Padding inputMethod(
      String labelText, TextEditingController controller, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextField(
        controller: controller,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
        ],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          suffixText: index != 3 ? "santimetr" : "sany",
        ),
      ),
    );
  }
}
