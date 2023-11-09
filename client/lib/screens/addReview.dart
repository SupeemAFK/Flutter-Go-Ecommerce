import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddReview extends StatefulWidget {
  final dynamic productID;
  const AddReview({ Key? key, this.productID }) : super(key: key);

  @override
  State<AddReview> createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  final reviewController = TextEditingController();

  void addReview() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final tokenTrim = token?.substring(1, token.length - 1);
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/reviews/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenTrim'
        },
        body: jsonEncode(<String, dynamic>{
          "productID": int.parse(widget.productID),
          "review": reviewController.text
        })
    );
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Review writed!",
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.push('/reviews/${widget.productID}')
              .then((value) => context.pop())
              .then((value) => context.pop());
          },
        ),
        title: const Text('Add review'),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
          ),
          onPressed: () => addReview(),
          label: Icon(Icons.sell),
          icon: Text("Review")
        ),
      ),
      body: Container(
              margin: EdgeInsets.only(top: 20),
              color: Colors.white,
              child: ListTile(
                leading: Icon(Icons.title),
                title: TextFormField(
                  controller: reviewController,
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
    );
  }
}