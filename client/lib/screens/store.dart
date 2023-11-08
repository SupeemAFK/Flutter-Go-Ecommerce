import 'dart:convert';

import 'package:client/model/userModel.dart';
import 'package:client/provider/userProvider.dart';
import 'package:client/widgets/productCard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Store extends StatefulWidget {
  final dynamic id;
  const Store({ super.key, this.id });

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  User? store;

  void getUserProducts() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/user/${widget.id}/products'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
    );
    if (response.statusCode == 200) {
      final data = User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      setState(() {
        store = data;
      });
    }
  }

  @override
  void initState() {
    super.initState;
    getUserProducts();
  }

  @override
  Widget build(BuildContext context){
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(), 
          icon: Icon(Icons.arrow_back)
        ),
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
        ],
      ),
      body: Container(
        child: Column(
          children: [
            ListTile(
              leading: store != null ? CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(store!.avatar),
              ) : CircleAvatar(
                radius: 30,
              ),
              tileColor: Colors.white,
              contentPadding: EdgeInsets.all(10),
              title: Text(store != null ? store!.username : ""),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.7,
                ), 
                itemCount: store?.products?.length,
                itemBuilder: (context, int index) {
                  return Container(
                    child:  FittedBox(
                      child: store?.products != null ? ProductCard(
                        product: store!.products![index],
                      ) : null
                    )
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}