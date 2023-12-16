import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Padding inputMethod(
    String inputText,
    String regexpText,
    String counterText,
    bool hasIcon,
    bool passwordVisible,
    Function() toggleFunction,
    BuildContext context,
    TextEditingController ctrl,
    int maxLength,
    bool enable) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: SizedBox(
      height: counterText != "" ? 80 : 65,
      child: TextField(
        enabled: enable,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(regexpText)),
        ],
        maxLength: maxLength != 0 ? maxLength : null,
        controller: ctrl,
        obscureText: passwordVisible,
        keyboardType:
            (inputText == "* Telefon 1..." || inputText == "* Telefon 2...")
                ? TextInputType.number
                : TextInputType.text,
        decoration: InputDecoration(
          prefixText:
              (inputText == "* Telefon 1..." || inputText == "* Telefon 2...")
                  ? "+993"
                  : null,
          counterText: counterText,
          border: const OutlineInputBorder(),
          labelText: inputText,
          labelStyle: const TextStyle(fontSize: 14),
          suffixIcon: hasIcon
              ? GestureDetector(
                  onTap: toggleFunction,
                  child: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : null,
        ),
      ),
    ),
  );
}
