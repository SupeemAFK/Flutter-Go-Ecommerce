import 'dart:convert';
import 'dart:io';

import 'package:client/model/productModel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditProduct extends StatefulWidget {
  final dynamic id;
  const EditProduct({super.key, this.id});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final nameController = TextEditingController();
  final detailsController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  List<dynamic> files = [];
  var editProductLoading = false;

  void editProduct() async {
    setState(() {
      editProductLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final tokenTrim = token?.substring(1, token.length - 1);

    final productFiles = await Future.wait(files.map((element) async { 
      if (element is ProductFile) {
        return { "name": element.name, "url": element.url };
      }

      final path = 'files/${element.path}';

      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = ref.putFile(element);

      final snapShot = await uploadTask.whenComplete(() {});
      final urlDownload = await snapShot.ref.getDownloadURL();
      return { "name": element.path, "url": urlDownload };
    }));

    final response = await http.put(
      Uri.parse("http://10.0.2.2:8080/product/${widget.id}"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenTrim'
        },
        body: jsonEncode(<String, dynamic>{
          "name": nameController.text,
          "details": detailsController.text,
          "category": categoryController.text,
          "price": int.parse(priceController.text),
          "stock": int.parse(stockController.text),
          "files": productFiles
        })
    );
    if (response.statusCode == 200) {
      setState(() {
        editProductLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Product updated",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
      );
    }
  }

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
        files = data.files;
        nameController.text = data.name;
        detailsController.text = data.details;
        categoryController.text = data.category;
        priceController.text = data.price.toString();
        stockController.text = data.stock.toString();
      });
    }
  }

  void addFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        files = [...files, ...result.paths.map((path) => File(path!)).toList()];
      });
    } 
  }

  void removeFile(int index) {
    setState(() {
      files.remove(files[index]);
    });
  }

  @override
  void initState() {
    super.initState;
    getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.push('/myStore')
              .then((value) => context.pop())
              .then((value) => context.pop());
          },
        ),
        title: const Text('Edit product'),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
          ),
          onPressed: () => editProduct(),
          label: Icon(Icons.edit),
          icon: Text("Edit product")
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: editProductLoading ? LinearProgressIndicator() : null,
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: OutlinedButton.icon(
                  onPressed: () => addFile(), 
                  icon: Icon(Icons.image),
                  label: const Text('Add Image')
                ),
              ),
            ),
            SizedBox(
              height: files.length > 0 ? 150 : 0,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 100,
                      height: 100,
                      child: Stack(
                        children: [
                          FittedBox(
                            child: Container(
                              width: 100,
                              height: 100,
                              child: files[index] is ProductFile ? Image.network(files[index].url) : Image.file(files[index]),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => removeFile(index),
                              child: Icon(
                                Icons.delete,
                              ),
                            )
                          ),
                        ],
                      ),
                    );
                  }
                ),
              )
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              color: Colors.white,
              child: ListTile(
                leading: Icon(Icons.title),
                title: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Name',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                )
              ),
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: Icon(Icons.details),
                title: TextFormField(
                  controller: detailsController,
                  decoration: const InputDecoration(
                    hintText: 'Details',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.category),
                    title: TextFormField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        hintText: 'Category',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.price_change),
                    title: TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        hintText: 'Price',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.warehouse),
                    title: TextFormField(
                      controller: stockController,
                      decoration: const InputDecoration(
                        hintText: 'Stock',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}