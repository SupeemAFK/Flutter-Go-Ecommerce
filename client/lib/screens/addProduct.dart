import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({ super.key });

  @override
  State<AddProduct> createState() => _AddProductState();

}

class _AddProductState extends State<AddProduct> {
  final nameController = TextEditingController();
  final detailsController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  List<File> files = [];
  var addProductLoading = false;

  void addProduct() async {
    setState(() {
      addProductLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final tokenTrim = token?.substring(1, token.length - 1);

    final productFiles = await Future.wait(files.map((element) async { 
      final path = 'files/${element.path}';

      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = ref.putFile(element);

      final snapShot = await uploadTask.whenComplete(() {});
      final urlDownload = await snapShot.ref.getDownloadURL();
      return { "name": element.path, "url": urlDownload };
    }));

    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/product/"),
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
        addProductLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Product created",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
      );
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
  Widget build(BuildContext context){
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
        title: const Text('Add product'),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
          ),
          onPressed: () => addProduct(),
          label: Icon(Icons.sell),
          icon: Text("Sell product")
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: addProductLoading ? LinearProgressIndicator() : null,
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
                              child: Image.file(files[index]),
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