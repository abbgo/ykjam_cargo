import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ykjam_cargo/functions/functions.dart';

showUserCodeBottomSheet(BuildContext context, String userCode) {
  showModalBottomSheet(
    context: context,
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Üns beriň",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText.rich(
                      TextSpan(
                        text: userCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 18,
                        ),
                        children: const <TextSpan>[
                          TextSpan(
                            text:
                                ' - bu siziň marka belgiňizdir. Bu belgi siziň ýüküňiziň ýüzünde görkezilmelidir we sorag ýüze çykanda Şu belginiň kömegi bilen Siz administrasiýa ýüz tutup bilersiňiz !',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              fontStyle: FontStyle.normal,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                ),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: userCode,
                    ),
                  );

                  showToastMethod("Marka belgi bufera nusgalandy");

                  Navigator.pop(context);
                },
                child: const Text(
                  "MARKA BELGINI NUSGALA",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

ElevatedButton settingFormInputButtonMethod(
    String text, Color textColor, Color buttonColor, Function() onPress) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
    ),
    onPressed: onPress,
    child: Text(
      text,
      style: TextStyle(
        color: textColor,
      ),
    ),
  );
}
