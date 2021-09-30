class ItemEntity {
  final int? id;
  final String description;
  final String unit;
  final int quantity;
  final int hasItbis;
  final double price;

  const ItemEntity({
    this.id,
    required this.description,
    required this.unit,
    required this.quantity,
    required this.hasItbis,
    required this.price,
  });
}
