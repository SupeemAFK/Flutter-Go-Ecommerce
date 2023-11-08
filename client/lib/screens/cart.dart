import 'dart:convert';

import 'package:client/model/userModel.dart';
import 'package:client/provider/userProvider.dart';
import 'package:client/widgets/cartTile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Cart extends StatelessWidget {
  const Cart({ super.key });

  @override
  Widget build(BuildContext context){
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop("/"),
        ),
        backgroundColor: Colors.white,
        title: const Text('Cart'),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
          ),
          onPressed: () {},
          label: Icon(Icons.shopping_cart_checkout),
          icon: Text("Checkout")
        ),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: userProvider!.currentUser!.carts!.length > 0 ? userProvider.currentUser?.carts!.first.product != null ? userProvider.currentUser!.carts!.length : 0 : 0,
          itemBuilder: (context, index) {
            return CartTile(
              cart: userProvider.currentUser!.carts![index],
            );
          },
        )
      )
    );
  }
}