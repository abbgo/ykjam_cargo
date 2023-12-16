import 'package:flutter/material.dart';

class ShowImage extends StatelessWidget {
  const ShowImage({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.adaptive.arrow_back),
        ),
      ),
      body: InteractiveViewer(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Image.network(
              image,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
    );
  }
}
