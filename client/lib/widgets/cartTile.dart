import 'dart:convert';

import 'package:client/model/userModel.dart';
import 'package:client/provider/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartTile extends StatefulWidget {
  final Cart cart;
  const CartTile({ Key? key, required this.cart }) : super(key: key);

  @override
  State<CartTile> createState() => _CartTileState();
}

class _CartTileState extends State<CartTile> {
  bool selected = false;
  int amount = 1;

  void increaseAmount() async {
    if (amount < widget.cart.product!.stock) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final tokenTrim = token?.substring(1, token.length - 1);
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8080/cart/${widget.cart.id}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            'Authorization': 'Bearer $tokenTrim'
          },
          body: jsonEncode(<String, dynamic>{
            "amount": amount + 1
          })
      );

      if (response.statusCode == 200) {
        setState(() => amount++);
      }
    }
  }

  void decreaseAmount() async {
    if (amount > 1) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final tokenTrim = token?.substring(1, token.length - 1);
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8080/cart/${widget.cart.id}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            'Authorization': 'Bearer $tokenTrim'
          },
          body: jsonEncode(<String, dynamic>{
            "amount": amount - 1
          })
      );

      if (response.statusCode == 200) {
        setState(() => amount--);
      }
    }
  }

  @override
  Widget build(BuildContext context){
    final userProvider = context.read<UserProvider>();

    return Card(
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Checkbox(
                            value: selected, 
                            onChanged: (value) {
                              setState(() {
                                selected = value!;
                              });
                            }
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(widget.cart.product!.files.first.url),
                                fit: BoxFit.fitHeight
                              )
                            )
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Text(widget.cart.product!.name),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => decreaseAmount(), 
                                      icon: Icon(Icons.remove)
                                    ),
                                    Text(amount.toString()),
                                    IconButton(
                                      onPressed: () => increaseAmount(), 
                                      icon: Icon(Icons.add)
                                    ),
                                  ]
                                ),
                                Text('${widget.cart.product!.price.toString()} THB'),
                              ]
                            ),
                          )
                        ]
                      ),
                    ),
                    TextButton(
                      onPressed: () => userProvider.removetoCurrentUserCart(widget.cart.id),
                      child: Text("Remove", style: TextStyle(color: Colors.red)),
                    )
                  ],
                ),
              ),
            );
  }
}