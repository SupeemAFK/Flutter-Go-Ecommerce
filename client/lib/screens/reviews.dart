import 'dart:convert';

import 'package:client/model/productModel.dart';
import 'package:client/widgets/reviewTile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Reviews extends StatefulWidget {
  final dynamic id;
  const Reviews({super.key, required this.id});

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  Product? product;

  void getProduct() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final tokenTrim = token?.substring(1, token.length - 1);
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/product/${widget.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenTrim'
        },
    );

    if (response.statusCode == 200) {
      final data = Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      setState(() {
        product = data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            context.push('/product/${widget.id}')
              .then((value) => context.pop())
              .then((value) => context.pop());
          }, 
          icon: Icon(Icons.arrow_back)
        ),
        title: const Text("Reviews"),
        actions: [
          OutlinedButton(
            onPressed: () => context.push('/addReview/${widget.id}'), 
            child: const Text("Write review")
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: ListView.builder(
          shrinkWrap: true,
          primary: false,
          physics: NeverScrollableScrollPhysics(),
          itemCount: product?.reviews != null ? product!.reviews!.length : 0,
          itemBuilder: (context, int index) {
            return Container(
              child: ReviewTile(review: product!.reviews![index]),
            );
          },
        ),
      ),
    );
  }
}