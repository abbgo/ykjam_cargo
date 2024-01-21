class History {
  num height, width, lenght, price;
  int quantity;
  String date;

  History(
    this.height,
    this.width,
    this.lenght,
    this.price,
    this.quantity,
    this.date,
  );

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'width': width,
      'lenght': lenght,
      'price': price,
      'quantity': quantity,
      'date': date,
    };
  }
}
