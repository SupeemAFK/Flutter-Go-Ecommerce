import 'dart:convert';

import 'package:client/model/userModel.dart';

class ProductFile {
  final String name;
  final String url;

  ProductFile({
    required this.name,
    required this.url
  });
}

class Review {
  final User user;
  final String review;

  Review({
    required this.user,
    required this.review
  });
}

class Product {
  final int id;
  final String name;
  final String details;
  final String category;
  final int price;
  final int stock;
  final DateTime createdAt;
  final List<ProductFile> files;
  final User? user;
  final List<Review>? reviews;

  Product({
    required this.id, 
    required this.name, 
    required this.details, 
    required this.category,
    required this.price, 
    required this.stock, 
    required this.createdAt,
    required this.files,
    required this.user,
    required this.reviews
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final filesJson = json["files"] as List<dynamic>;
    final productFiles = filesJson.map((e) => ProductFile(name: e["name"], url: e["url"])).toList();
   
    var productUser = json["user"] != null ? User.fromJson(json["user"] as Map<String, dynamic>) : null;

    var reviewsJson =  json["reviews"] != null ? json["reviews"] as List<dynamic> : null;
    var productReviews = reviewsJson != null ? reviewsJson.map((e) => Review(user: User.fromJson(e["user"] as Map<String, dynamic>), review: e["review"])).toList() : null;

    return Product(
      id: json['ID'] as int,
      name: json['name'] as String,
      details: json['details'] as String,
      category: json['category'] as String,
      price: json['price'] as int,
      stock: json['stock'] as int,
      createdAt: DateTime.parse(json['CreatedAt'] as String),
      files: productFiles,
      user: productUser,
      reviews: productReviews,
    );
  }
}