
import 'package:flutter/material.dart';

class ProductModel {
  final String id;
  final String name;
  final double pricePerKg;
  final String imageUrl;
  final Color color;

  const ProductModel({
    required this.id,
    required this.name,
    required this.pricePerKg,
    required this.imageUrl,
    required this.color,
  });
}
