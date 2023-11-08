import 'dart:convert';

import 'package:client/model/productModel.dart';
import 'package:client/provider/userProvider.dart';
import 'package:client/widgets/productCard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({ super.key });

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Product> recommendProducts = [];

  void getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final tokenTrim = token?.substring(1, token.length - 1);

    final response = await http.get(
      Uri.parse("http://10.0.2.2:8080/product/"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenTrim'
        },
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body) as List<dynamic>;
      final data = res.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
      setState(() {
        recommendProducts = data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          child: SearchBar(
            leading: const Icon(Icons.search)
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () => context.push('/cart'),
                icon: const Icon(
                  Icons.shopping_cart_rounded,
                  size: 30,
                ),
              ),
              Container(
                child: userProvider.currentUser != null && userProvider.currentUser!.carts!.length > 0 ? 
                Positioned(
                  top: 4,
                  right: 6,
                  child: Container(
                    height: 22,
                    width: 22,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange,
                    ),
                    child: Center(
                      child: Text(
                      userProvider.currentUser!.carts!.length.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ),
                ) : null,
              )
            ],
          ),
        ]
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.7,
        ), 
        itemCount: recommendProducts.length,
        itemBuilder: (context, int index) {
          return Container(
            child:  FittedBox(
              child: ProductCard(
                product: recommendProducts[index],
              )
            )
          );
        },
      )
    );
  }
}