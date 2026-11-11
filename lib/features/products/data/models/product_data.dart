
import 'package:el_nada_market/features/products/data/models/product_model.dart';
import 'package:flutter/material.dart';
class ProductData {
  ProductData._();

  static const List<ProductModel> fruits = [
    ProductModel(
      id: 'fruit_apple',
      name: 'تفاح',
      pricePerKg: 45,
      imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=160',
      color: Color(0xFFE5B9B4),
    ),
    ProductModel(
      id: 'fruit_banana',
      name: 'موز',
      pricePerKg: 30,
      imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=160',
      color: Color(0xFFF3E4A1),
    ),
    ProductModel(
      id: 'fruit_orange',
      name: 'برتقال',
      pricePerKg: 25,
      imageUrl: 'https://images.unsplash.com/photo-1547514701-42782101795e?w=160',
      color: Color(0xFFF3C99F),
    ),
    ProductModel(
      id: 'fruit_grapes',
      name: 'عنب',
      pricePerKg: 55,
      imageUrl: 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=160',
      color: Color(0xFFCBB9D9),
    ),
  ];

  static const List<ProductModel> vegetables = [
    ProductModel(
      id: 'veg_tomato',
      name: 'طماطم',
      pricePerKg: 15,
      imageUrl: 'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=160',
      color: Color(0xFFE5B9B4),
    ),
    ProductModel(
      id: 'veg_potato',
      name: 'بطاطس',
      pricePerKg: 20,
      imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=160',
      color: Color(0xFFD7C3A5),
    ),
    ProductModel(
      id: 'veg_cucumber',
      name: 'خيار',
      pricePerKg: 18,
      imageUrl: 'https://images.unsplash.com/photo-1604977042946-1eecc30f269e?w=160',
      color: Color(0xFFB8D5A8),
    ),
    ProductModel(
      id: 'veg_carrot',
      name: 'جزر',
      pricePerKg: 25,
      imageUrl: 'https://images.unsplash.com/photo-1445282768818-728615cc910a?w=160',
      color: Color(0xFFF3C99F),
    ),
    ProductModel(
      id: 'veg_pepper',
      name: 'فلفل',
      pricePerKg: 35,
      imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=160',
      color: Color(0xFFB8D5A8),
    ),
  ];
}
