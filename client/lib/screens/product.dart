import 'dart:convert';
import 'package:client/provider/userProvider.dart';
import 'package:client/widgets/reviewTile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:client/model/productModel.dart';

class ProductPage extends StatefulWidget {
  final dynamic id;
  const ProductPage({ super.key, required this.id });

  @override
  State<StatefulWidget> createState() => _ProductState();
}

class _ProductState extends State<ProductPage> {
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: context.watch<UserProvider>().currentUser?.id != product?.user?.id ? ElevatedButton.icon(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
          ),
          onPressed: () => userProvider.addtoCurrentUserCart(product!.id, 1),
          label: Icon(Icons.shopping_cart),
          icon: Text("Add to cart"),
        ) : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: product?.files != null ? CarouselSlider(
                options: CarouselOptions(
                  height: 400.0,
                  autoPlay: true,
                ),
                items: product!.files.map((file) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(0)
                            ),
                            image: DecorationImage(
                              image: NetworkImage(file.url),
                              fit: BoxFit.fitHeight
                            ),
                          ),
                        )
                      );
                    },
                  );
                }).toList(),
              ) : null,
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    title: Text(product != null ? product!.name : ""),
                  ),
                  ListTile(
                    title: Text(
                      product != null ? '${product!.price.toString()} THB' : "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    shape: Border(
                      bottom: BorderSide(width: 1, color: Colors.grey.shade300),
                    )
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              margin: EdgeInsets.only(top: 10),
              child: ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(product != null ? product!.user!.avatar : ""),
                    ),
                    title: Text(product != null ? product!.user!.username : ""),
                    trailing: OutlinedButton(
                      onPressed: () => {
                        if (product?.user != null) context.push('/store/${product!.user!.id}')
                      },
                      child: const Text("View store"),
                    ),
                    shape:  Border(
                      bottom: BorderSide(width: 1, color: Colors.grey.shade300),
                    )
                  ),
            ),
            Container(
              color: Colors.white,
              margin: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  ListTile(
                    title: Text("Category: ${product?.category}")
                  ),
                  ListTile(
                    title: const Text("Details"),
                    subtitle: Text(product != null ? product!.details : ""),
                    shape:  Border(
                      bottom: BorderSide(width: 1, color: Colors.grey.shade300),
                    )
                  ),
                  ListTile(
                    title: Text(product != null ? 'Stock: ${product!.stock.toString()}' : "")
                  ), 
                ],
              ),
            ),
            Container(
              color: Colors.white,
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  ListTile(
                    title: Text("Reviews"),
                    trailing: TextButton.icon(
                      onPressed: () => context.push('/reviews/${widget.id}'),
                      label: Icon(Icons.arrow_right),
                      icon: Text("See all"),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: product?.reviews != null ? product!.reviews!.length > 3 ? 3 : product!.reviews!.length : 0,
                    itemBuilder: (context, int index) {
                      return Container(
                        child: ReviewTile(review: product!.reviews![index])
                      );
                    },
                  ),
                ],
              )
            )
          ],
        ),
      )
    );
  }
}