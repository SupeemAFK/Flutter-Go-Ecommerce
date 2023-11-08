import 'dart:convert';

import 'package:client/model/productModel.dart';
import 'package:flutter/material.dart';

class Cart {
  final int id;
  final Product? product;
  final int amount;

  const Cart({
    required this.id,
    required this.product,
    required this.amount,
  });
}

class User {
  final int id;
  final String username;
  final String bio;
  final String email;
  final String avatar;
  final List<Product>? products;
  final List<Cart>? carts;

  const User({
    required this.id, 
    required this.username, 
    required this.bio, 
    required this.email, 
    required this.avatar,
    required this.products,
    required this.carts
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final jsonProducts = json['products'] != null ? json['products'] as List<dynamic> : null;
    final userProducts = jsonProducts != null ? jsonProducts.map((element) => Product.fromJson(element as Map<String, dynamic>)).toList() : null;

    final jsonCarts = json['carts'] != null ? json['carts'] as List<dynamic> : null;
    final userCarts = jsonCarts != null ? jsonCarts.map((element) => Cart(id: element["ID"], product: element["product"] != null ? Product.fromJson(element["product"]) : null, amount: element["amount"])).toList() : null;

    return User(
      id: json['ID'] as int,
      username: json['username'] as String,
      bio: json['bio'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String,
      products: userProducts,
      carts: userCarts
    );
  }
}