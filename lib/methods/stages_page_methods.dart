import 'package:flutter/material.dart';
import 'package:ykjam_cargo/functions/functions.dart';
import 'package:ykjam_cargo/helpers/shimmer_loading.dart';

SliverAppBar sliverAppBarMethod(
    BuildContext context,
    Function() onTap,
    String text,
    bool showAction,
    bool showSearchBar,
    Function() onTapSearch,
    Function(String newValue) search,
    Function() sortAZ,
    Function() sortZA,
    Function() sortCodeASC,
    Function() sortCodeDESC) {
  return SliverAppBar(
    actions: !showAction
        ? []
        : [
            if (!showSearchBar)
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GestureDetector(
                      onTap: onTapSearch,
                      child: const Icon(Icons.search),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (_) {
                              return Padding(
                                padding: const EdgeInsets.all(20),
                                child: Wrap(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Tertibi",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        textButtonMethod("Ady (A-Z)", () {
                                          sortAZ();
                                          Navigator.pop(context);
                                          showToastMethod(
                                              "Ady A-dan Z tertiplendi");
                                        }),
                                        const Divider(),
                                        textButtonMethod("Ady (Z-A)", () {
                                          sortZA();
                                          Navigator.pop(context);
                                          showToastMethod(
                                              "Ady Z-dan A tertiplendi");
                                        }),
                                        const Divider(),
                                        textButtonMethod(
                                            "Senesi (başda köneler)", () {
                                          sortCodeASC();
                                          Navigator.pop(context);
                                          showToastMethod(
                                              "Başda gelenler ýokarda");
                                        }),
                                        const Divider(),
                                        textButtonMethod(
                                            "Senesi (başda täzeler)", () {
                                          sortCodeDESC();
                                          Navigator.pop(context);
                                          showToastMethod(
                                              "Soňda gelenler ýokarda");
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      child: const Icon(Icons.sort),
                    ),
                  ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: SearchBar(
                    onChanged: search,
                    backgroundColor:
                        MaterialStateProperty.all(Colors.grey.shade300),
                    elevation: MaterialStateProperty.all(0),
                    trailing: [
                      IconButton(
                        onPressed: onTapSearch,
                        icon: const Icon(Icons.close),
                      )
                    ],
                    hintText: "Gözleg...",
                    leading: const Icon(Icons.search),
                  ),
                ),
              ),
          ],
    leading: GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Icon(Icons.adaptive.arrow_back),
      ),
    ),
    expandedHeight: 130,
    surfaceTintColor: Colors.white,
    pinned: true,
    floating: true,
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: true,
      titlePadding: const EdgeInsets.only(bottom: 20, left: 10),
      title: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

SizedBox textButtonMethod(String text, void Function()? onPressed) {
  return SizedBox(
    height: 35,
    width: double.infinity,
    child: GestureDetector(
      onTap: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    ),
  );
}

List<Widget> shimmerListMethod(int lenght, double height) {
  return List.generate(
    lenght,
    (index) => ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          height: height,
          decoration: const BoxDecoration(
            color: Color(0xFFEBEBF4),
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: const UnconstrainedBox(
              child: CircularProgressIndicator.adaptive()),
        ),
      ),
    ),
  );
}

List<Widget> showErrMethod(BuildContext context, String text) {
  return List.generate(
    1,
    (index) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Center(
        child: Text(
          textAlign: TextAlign.center,
          text,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 18,
          ),
        ),
      ),
    ),
  );
}
