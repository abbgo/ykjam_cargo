import 'package:flutter/material.dart';
import 'package:ykjam_cargo/datas/static_data.dart';

class StartPage extends StatelessWidget {
  StartPage({
    super.key,
  });

  final StaticData staticData = StaticData();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset("${staticData.getStaticFilePath()}/logo.webp"),
            ),
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(color: Colors.white),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
