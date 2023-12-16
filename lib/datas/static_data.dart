import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StaticData with ChangeNotifier {
  final String _url = dotenv.env['URL']!;
  final String _staticFilePath = dotenv.env['STATIC_FILE_PATH']!;

  String getUrl() {
    return _url;
  }

  String getStaticFilePath() {
    return _staticFilePath;
  }
}
