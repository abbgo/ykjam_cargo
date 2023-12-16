class Item {
  int id, count;
  String code,
      name,
      cubeText,
      weightText,
      cubeWeightText,
      supposedWeightText,
      extraWeightText,
      date;
  bool imgOK;

  List<ItemImage> images;
  Total total;

  Item(
      this.id,
      this.code,
      this.name,
      this.cubeText,
      this.weightText,
      this.count,
      this.cubeWeightText,
      this.supposedWeightText,
      this.extraWeightText,
      this.date,
      this.imgOK,
      this.images,
      this.total);
}

class ItemImage {
  int id;
  String image;

  ItemImage(this.id, this.image);
}

class Total {
  String totalCubePriceText,
      extraWeightText,
      servicePriceText,
      totalPriceText,
      totalCubeText,
      totalCubeWeightText,
      totalSupposedWeightText,
      totalExtraWeightText;
  int totalCount, totalStuk;
  num totalCube, totalWeight;

  Total(
      this.totalCubePriceText,
      this.extraWeightText,
      this.servicePriceText,
      this.totalPriceText,
      this.totalCount,
      this.totalCube,
      this.totalCubeText,
      this.totalWeight,
      this.totalCubeWeightText,
      this.totalStuk,
      this.totalSupposedWeightText,
      this.totalExtraWeightText);
}
