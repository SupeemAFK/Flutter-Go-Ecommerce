import 'dart:convert';
import 'package:client/provider/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Signin extends StatefulWidget {
  const Signin({ super.key });

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signinSubmit(UserProvider userProvider) async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/auth/signin"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': emailController.text,
          'password': passwordController.text,
        })
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.body);
      userProvider.getCurrentUser();
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Sign In",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28
                ),
              ),
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [ 
                  TextButton(
                    onPressed:(){}, 
                    child: Text("Forgot password")
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: OutlinedButton(
                onPressed: () => signinSubmit(context.read<UserProvider>()),
                child: const Text('Submit'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have account yet?"),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text("Sign up"),
                )
              ],
            )
          ],
        )
      ),
    );
  }
}