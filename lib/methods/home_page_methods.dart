import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ykjam_cargo/datas/contact_data.dart';
import 'package:ykjam_cargo/datas/static_data.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:ykjam_cargo/helpers/font_size.dart';
import 'package:ykjam_cargo/pages/login_page.dart';
import 'package:ykjam_cargo/pages/posts_page.dart';
import 'package:ykjam_cargo/pages/register_page.dart';
import 'package:ykjam_cargo/pages/repositories_page.dart';
import 'package:ykjam_cargo/pages/service_prices_page.dart';
import 'package:ykjam_cargo/pages/stages_page.dart';
import 'package:ykjam_cargo/pages/statute_page.dart';

StaticData staticData = StaticData();

_showContactBottomModel(BuildContext context, List<Contact> contacts) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Wrap(
        children: [
          const Text(
            "Habarlaşmak",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          if (contacts.isEmpty)
            const LinearProgressIndicator()
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: contacts
                    .map(
                      (contact) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Text(
                                  "${contact.name} ",
                                  style: TextStyle(
                                    fontSize: calculateFontSize(context, 16),
                                  ),
                                ),
                                Text(
                                  contact.value,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: calculateFontSize(context, 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.content_copy),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: contact.value,
                                ),
                              );

                              showToastMethod("Maglumat bufera nusgalandy");
                            },
                          ),
                        ],
                      ),
                    )
                    .toList()
                  ..add(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).primaryColor),
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "OK",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ),
            ),
        ],
      ),
    ),
  );
}

_showModalBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Wrap(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ulgama giriň",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const Text(
              "Programmanyň esasy funksiýalaryny ulanmak üçin ulgama girmelisiňiz",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black26,
              ),
            ),
            const SizedBox(height: 5),
            elevationButtonMethod(
              context,
              "Içine girmek",
              Theme.of(context).primaryColor,
              Colors.white,
              () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            ),
            elevationButtonMethod(
              context,
              "Hasaba durmak",
              Theme.of(context).primaryColor,
              Colors.white,
              () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()));
              },
            ),
          ],
        ),
      );
    },
  );
}

Padding elevationButtonMethod(
  BuildContext context,
  String text,
  Color buttonColor,
  Color textColor,
  Function() onTap,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: calculateFontSize(context, 20),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}

Padding listTileMethod(String image, String title, subTitle, bool isDisable,
    int index, BuildContext context, String userToken, List<Contact> contacts) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Container(
      decoration: const BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: ListTile(
        onTap: () {
          switch (index) {
            case 0:
              if (userToken == "") {
                _showModalBottomSheet(context);
                return;
              }
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const StagesPage()));
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RepositoriesPage(
                    partID: 30,
                    isUnowned: true,
                  ),
                ),
              );
              break;
            case 2:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const PostsPage()));
              break;
            case 3:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ServicePrices()));
              break;
            case 4:
              _showContactBottomModel(context, contacts);
              break;
            case 5:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatutePage(),
                ),
              );
              break;
            case 6:
              break;
          }
        },
        contentPadding: const EdgeInsets.all(2),
        leading: SizedBox(
          width: 60,
          child: Image.asset(image),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: calculateFontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: isDisable ? Colors.black26 : Colors.black,
          ),
        ),
        subtitle: subTitle != ""
            ? Text(
                subTitle,
                style: TextStyle(
                  fontSize: calculateFontSize(context, 12),
                  color: isDisable ? Colors.black26 : Colors.black,
                ),
              )
            : null,
      ),
    ),
  );
}
