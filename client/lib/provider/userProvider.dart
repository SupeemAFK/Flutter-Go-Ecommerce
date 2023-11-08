import 'dart:convert';
import 'dart:io';
import 'package:client/model/userModel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  User? currentUser;
  
  void getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final tokenTrim = token?.substring(1, token.length - 1);
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8080/user/currentuser"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenTrim'
        },
    );

    if (response.statusCode == 200) {
      final data = User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      currentUser = data;
      notifyListeners();
    }
  }

  Future<void> updateCurrentUser(String username, String bio, String email, String ogAvatar, File? avatar) async {
    var updateAvatar = ogAvatar;
    if (avatar != null) {
      final path = 'files/${avatar.path}';

      final ref =FirebaseStorage.instance.ref().child(path);
      final uploadTask = ref.putFile(avatar);

      final snapShot = await uploadTask.whenComplete(() {});
      final urlDownload = await snapShot.ref.getDownloadURL();
      updateAvatar = urlDownload;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final tokenTrim = token?.substring(1, token.length - 1);
    final response = await http.put(
      Uri.parse("http://10.0.2.2:8080/user/currentuser"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenTrim'
        },
        body: jsonEncode(<String, dynamic>{
          "username": username,
          "bio": bio,
          "email": email,
          "avatar": updateAvatar
        })
    );

    if (response.statusCode == 200) {
      final data = User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      currentUser = User(
        id: data.id, 
        username: data.username, 
        bio: data.bio, 
        email: data.email, 
        avatar: data.avatar, 
        products: currentUser!.products, 
        carts: currentUser!.carts
      );
      notifyListeners();
    }
  }

  void getUserCarts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final tokenTrim = token?.substring(1, token.length - 1);
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/user/currentuser/carts'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenTrim'
        },
    );

    if (response.statusCode == 200) {
      final data = User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      currentUser = data;
      notifyListeners();
    }
  }

  void addtoCurrentUserCart(int productID, int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final tokenTrim = token?.substring(1, token.length - 1);
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/cart/"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenTrim'
        },
        body: jsonEncode(<String, dynamic>{
          "productID": productID,
          "amount": amount,
        })
    );

    if (response.statusCode == 200) {
      final cartDecode = jsonDecode(response.body) as Map<String, dynamic>;
      final data = Cart(id: cartDecode["ID"], product: null, amount: cartDecode["amount"]);
      currentUser!.carts!.add(data);
      notifyListeners();
    }
  }

  void removetoCurrentUserCart(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final tokenTrim = token?.substring(1, token.length - 1);
    final response = await http.delete(
      Uri.parse("http://10.0.2.2:8080/cart/${id}"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenTrim'
        }
    );

    if (response.statusCode == 200) {
      currentUser!.carts!.removeWhere((e) => e.id == id);
      notifyListeners();
    }
  }
}