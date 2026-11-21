
// import 'package:flutter/material.dart';

// class ProductModel {
//   final String id;
//   final String name;
//   final double pricePerKg;
//   final String imageUrl;
//   final Color color;

//   const ProductModel({
//     required this.id,
//     required this.name,
//     required this.pricePerKg,
//     required this.imageUrl,
//     required this.color,
//   });
// }
// // class ProductModel {
// //   final int id;
// //   final String nameAr;
// //   final String nameEn;
// //   final String category;
// //   final String unitOfMsrSo;
// //   final String? imageUrl;
// //   final bool inStock;

// //   final int priceId;
// //   final double unitPrice;

// //   const ProductModel({
// //     required this.id,
// //     required this.nameAr,
// //     required this.nameEn,
// //     required this.category,
// //     required this.unitOfMsrSo,
// //     this.imageUrl,
// //     required this.inStock,
// //     required this.priceId,
// //     required this.unitPrice,
// //   });
// // }


class ProductModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final String category;
  final String unitOfMsrSo;
  final String? imageUrl;
  final bool inStock;
  final double unitPrice;

  const ProductModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.category,
    required this.unitOfMsrSo,
    this.imageUrl,
    required this.inStock,
    required this.unitPrice,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final stockValue = json['in_stock'];

    return ProductModel(
      id: int.parse(json['id'].toString()),
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      unitOfMsrSo: json['unit_of_msr_so']?.toString() ?? '',
      imageUrl: json['photo_url']?.toString(),
      inStock: stockValue == true ||
          stockValue == 1 ||
          stockValue.toString() == '1',
      unitPrice: double.tryParse(
            (json['unit_price'] ?? 0).toString(),
          ) ??
          0.0,
    );
  }
}
