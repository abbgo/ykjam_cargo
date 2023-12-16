class Repository {
  String name, image, unitKub, unitWeight;
  int totalCount, supposedWeight;
  num totalKub, totalweight, totalPrice;

  List<Inventory> inventories;

  Repository(
    this.name,
    this.image,
    this.totalKub,
    this.unitKub,
    this.totalweight,
    this.unitWeight,
    this.totalCount,
    this.totalPrice,
    this.inventories,
    this.supposedWeight,
  );
}

class Inventory {
  int id, count;
  String name, cubeUnit, weightUnit;
  num cube, weight, totalPrice;

  Inventory(this.id, this.name, this.cube, this.cubeUnit, this.weight,
      this.weightUnit, this.count, this.totalPrice);
}

class InvenItem {
  String totalCubeText, extraWeightText, servicePriceText, totalPriceText;
  List<Service> services;
  List<Item> items;

  InvenItem(this.totalCubeText, this.extraWeightText, this.servicePriceText,
      this.totalPriceText, this.services, this.items);
}

class Service {
  int id;
  num price;
  String descr, date;

  Service(this.id, this.price, this.descr, this.date);
}

class Item {
  int id, count, stuk;
  String code, name, weightUnit, cubeUnit, date;
  num cube, weight, extraWeight, price, totalPrice;

  Item(
      this.id,
      this.code,
      this.name,
      this.cube,
      this.count,
      this.stuk,
      this.weight,
      this.weightUnit,
      this.cubeUnit,
      this.date,
      this.extraWeight,
      this.price,
      this.totalPrice);
}
