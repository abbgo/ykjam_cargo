import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ykjam_cargo/datas/service_price_data.dart';
import 'package:ykjam_cargo/helpers/font_size.dart';

// ignore: must_be_immutable
class CalculatePage extends StatefulWidget {
  CalculatePage({super.key, required this.price});

  ServicePrice price;

  @override
  State<CalculatePage> createState() => _CalculatePageState();
}

class _CalculatePageState extends State<CalculatePage> {
  String _selectedValue = "Metr";

  final TextEditingController _width = TextEditingController();
  final TextEditingController _height = TextEditingController();
  final TextEditingController _length = TextEditingController();
  final TextEditingController _quantity = TextEditingController();

  num result = 0;

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
          inputMethod(" Ini ", _width),
          inputMethod(" Boýy ", _height),
          inputMethod(" Uzynlygy ", _length),
          inputMethod(" Sany ", _quantity),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(left: 20),
                padding: const EdgeInsets.all(5),
                child: DropdownButton<String>(
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(10),
                  value: _selectedValue, // Track the selected value
                  items: <String>['Metr', 'Santimetr']
                      .map<DropdownMenuItem<String>>(
                    (String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    },
                  ).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedValue = newValue!;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.all(18),
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

                    result = num.parse(_width.text) *
                        num.parse(_height.text) *
                        num.parse(_length.text) *
                        num.parse(_quantity.text) *
                        widget.price.price;

                    if (_selectedValue == "Santimetr") {
                      result = result / 1000000;
                    }

                    setState(() {});
                  },
                  child: const Text(
                    "Hasapla",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          result != 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Center(
                    child: Text(
                      "Netije: $result \$",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Padding inputMethod(String labelText, TextEditingController controller) {
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
        ),
      ),
    );
  }
}
