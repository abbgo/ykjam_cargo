import 'package:flutter/material.dart';
import 'package:ykjam_cargo/datas/repository_data.dart';
import 'package:ykjam_cargo/methods/stages_page_methods.dart';
import 'package:ykjam_cargo/pages/inven_item_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({
    super.key,
    required this.inventories,
    required this.supposedWeight,
    required this.partID,
    required this.isUnowned,
  });

  final List<Inventory> inventories;
  final int supposedWeight, partID;
  final bool isUnowned;

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: CustomScrollView(
          slivers: [
            sliverAppBarMethod(context, () {
              Navigator.pop(context);
            }, "Ýükiň ugry", false, false, () {}, (String value) {}, () {},
                () {}, () {}, () {}),
            SliverList(
              delegate: SliverChildListDelegate(
                List.generate(
                  widget.inventories.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: GestureDetector(
                      onTap: () {
                        widget.inventories[index].count != 0
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InvenItemPage(
                                    invenName: widget.inventories[index].name,
                                    invenID: widget.inventories[index].id,
                                    partID: widget.partID,
                                    supposedWeight: widget.supposedWeight,
                                    isUnowned: widget.isUnowned,
                                  ),
                                ),
                              )
                            : null;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.inventories[index].count != 0
                              ? Colors.grey.shade300
                              : Colors.grey.shade100,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.inventories[index].name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: widget.inventories[index].count != 0
                                      ? Colors.black
                                      : Colors.black26,
                                ),
                              ),
                              Text(
                                "Ýer sany: ${widget.inventories[index].count}",
                                style: TextStyle(
                                  color: widget.inventories[index].count != 0
                                      ? Colors.black
                                      : Colors.black26,
                                ),
                              ),
                              Text(
                                "Göwrümi: ${widget.inventories[index].cube} ${widget.inventories[index].cubeUnit}",
                                style: TextStyle(
                                  color: widget.inventories[index].count != 0
                                      ? Colors.black
                                      : Colors.black26,
                                ),
                              ),
                              Text(
                                "Agramy: ${widget.inventories[index].weight} ${widget.inventories[index].weightUnit}",
                                style: TextStyle(
                                  color: widget.inventories[index].count != 0
                                      ? Colors.black
                                      : Colors.black26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
