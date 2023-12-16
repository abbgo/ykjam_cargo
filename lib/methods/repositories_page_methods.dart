import 'package:flutter/material.dart';
import 'package:ykjam_cargo/datas/repository_data.dart';
import 'package:ykjam_cargo/datas/static_data.dart';

Padding listGeneratePaddingMethod(
    int index,
    BuildContext context,
    bool condition,
    Widget Function(BuildContext) builderFunction,
    List<Repository> repositories,
    StaticData staticData,
    bool isUnowned) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: GestureDetector(
      onTap: () {
        condition
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: builderFunction,
                ),
              )
            : null;
      },
      child: Container(
        decoration: BoxDecoration(
          color: condition ? Colors.grey.shade300 : Colors.grey.shade200,
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 3,
                child: Opacity(
                  opacity: condition ? 1 : 0.2,
                  child: Image.network(
                    "${staticData.getUrl()}/image/${repositories[index].image}",
                  ),
                ),
              ),
              const Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      repositories[index].name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: condition ? Colors.black : Colors.black26,
                      ),
                    ),
                    Text(
                      "Ýer sany: ${repositories[index].totalCount}",
                      style: TextStyle(
                        color: condition ? Colors.black : Colors.black26,
                      ),
                    ),
                    Text(
                      "Göwrümi: ${repositories[index].totalKub} ${repositories[index].unitKub}",
                      style: TextStyle(
                        color: condition ? Colors.black : Colors.black26,
                      ),
                    ),
                    Text(
                      "Agramy: ${repositories[index].totalweight} ${repositories[index].unitWeight}",
                      style: TextStyle(
                        color: condition ? Colors.black : Colors.black26,
                      ),
                    ),
                    !isUnowned
                        ? condition
                            ? Text(
                                "\$${repositories[index].totalPrice}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const SizedBox()
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
