import 'dart:convert';
import 'package:client/model/userModel.dart';
import 'package:client/provider/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyStore extends StatefulWidget {
  final dynamic id;
  const MyStore({super.key, required this.id});

  @override
  State<MyStore> createState() => _MyStoreState();
}

class _MyStoreState extends State<MyStore> {
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

  void deleteProduct(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final tokenTrim = token?.substring(1, token.length - 1);

    final response = await http.delete(
      Uri.parse("http://10.0.2.2:8080/product/${id}"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenTrim'
        }
    );
    if (response.statusCode == 200) {
      setState(() {
        if (store != null) {
          store = User(
            id: store!.id, 
            username: store!.username, 
            bio: store!.bio, 
            email: store!.email, 
            avatar: store!.avatar, 
            carts: store!.carts,
            products: store!.products!.where((product) => product.id != id).toList(),
          );
        }
      });
      Fluttertoast.showToast(
        msg: "Product deleted",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
      );
    }
  }

  @override
  void initState() {
    super.initState;
    getUserProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(), 
          icon: Icon(Icons.arrow_back)
        ),
        title: const Text("MyStore"),
      ),
      body: SingleChildScrollView(
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
              trailing: OutlinedButton(
                onPressed: () => context.push('/addProduct'), 
                child: const Text("Add new product")
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              primary: false,
              physics: NeverScrollableScrollPhysics(),
              itemCount: store != null ? store!.products!.length : 0,
              itemBuilder: (context, int index) {
                return InkWell(
                  onTap:() => context.push('/product/${store!.products![index].id}'),
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.8,
                    color: Colors.white,
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: SizedBox(
                            child: Row(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(0),
                                      topRight: Radius.circular(0)
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(store!.products![index].files.first.url),
                                      fit: BoxFit.fitHeight
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 200,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        store!.products![index].name.length > 50 ? store!.products![index].name.substring(0, 50) : store!.products![index].name,
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),  
                                      ),
                                      Text(
                                        '${store!.products![index].price.toString()} THB',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold
                                        ), 
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ),
                        PopupMenuButton(
                          itemBuilder: (context) => <PopupMenuEntry>[
                            PopupMenuItem<String>(
                              onTap: () => context.push('/editProduct/${store!.products![index].id}'),
                              child: Container(
                                child: Row(
                                  children: [
                                    Text("Edit"),
                                    Icon(Icons.edit, size: 14)
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem<String>(
                              onTap: () => deleteProduct(store!.products![index].id),
                              child: Container(
                                child: Row(
                                  children: [
                                    Text("Delete"),
                                    Icon(Icons.delete, size: 14)
                                  ],
                                ),
                              ),
                            ),
                          ]
                        )
                      ],
                    )
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}