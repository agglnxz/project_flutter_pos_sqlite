class Item {
  final int id;
  final String name;
  final double price;
  final String category;

  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });

  // Convert ke Map (misalnya untuk simpan ke DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
    };
  }

  // Buat dari Map (misalnya ambil dari DB)
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int,
      name: map['name'] as String,
      price: (map['price'] is int) 
          ? (map['price'] as int).toDouble() 
          : map['price'] as double,
      category: map['category'] as String,
    );
  }
}