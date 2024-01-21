class ServicePrice {
  int id;
  num price;
  String priceTxt, description;
  bool isCalculation = false;

  ServicePrice(
      this.id, this.price, this.priceTxt, this.description, this.isCalculation);
}
