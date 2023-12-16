import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ykjam_cargo/datas/static_data.dart';

class StatutePage extends StatefulWidget {
  const StatutePage({super.key});

  @override
  State<StatutePage> createState() => _StatutePageState();
}

class _StatutePageState extends State<StatutePage> {
  // VARIABLES --------------------------------------------------------------------
  String pageTitle = "";
  late final WebViewController _controller;
  StaticData staticData = StaticData();

  void setAppBarTitle() {
    _controller.getTitle().then((value) {
      setState(() {
        pageTitle = value!;
      });
    });
  }

// INIT STATE ------------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('${staticData.getUrl()}/policy.html'),
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          setAppBarTitle();
        },
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
