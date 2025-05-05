import 'package:flora_manager/models/plant.dart';

class Product {
  int? id;
  Plant? plant;
  double? price;
  double? discount;
  int? stockQty;
  bool? isDeleted;
  int? soldQty;

  Product({
    this.id,
    this.plant,
    this.price = 0.0,
    this.discount = 0.0,
    this.stockQty = 0,
    this.isDeleted = false,
    this.soldQty = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      plant: json['plant'] != null ? Plant.fromJson(json['plant']) : null,
      price: json['price']?.toDouble() ?? 0.0,
      discount: json['discount']?.toDouble() ?? 0.0,
      stockQty: json['stockQty'] ?? 0,
      isDeleted: json['isDeleted'] ?? false,
      soldQty: json['soldQty'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plant': plant?.toJson(),
      'price': price,
      'discount': discount,
      'stockQty': stockQty,
      'isDeleted': isDeleted,
      'soldQty': soldQty,
    };
  }

  // Tính giá sau khi giảm giá
  double get discountedPrice {
    return price! - (price! * discount! / 100);
  }
}