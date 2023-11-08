import 'dart:io';
import 'package:client/provider/userProvider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({ super.key });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final emailController = TextEditingController();
  File? avatar;
  var updateProfileLoading = false;

  void selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      setState(() {
        avatar = result.paths.map((path) => File(path!)).toList().first;
      });
    } 
  }

  @override
  Widget build(BuildContext context){
    final userProvider = context.watch<UserProvider>();
    usernameController.text = userProvider.currentUser != null ? userProvider.currentUser!.username : "";
    bioController.text = userProvider.currentUser != null ? userProvider.currentUser!.bio : "";
    emailController.text = userProvider.currentUser != null ? userProvider.currentUser!.email : "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go("/"),
        ),
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              if (userProvider.currentUser != null) {
                setState(() => updateProfileLoading = true);
                await userProvider.updateCurrentUser(usernameController.text, bioController.text, emailController.text, userProvider.currentUser!.avatar, avatar);
                setState(() => updateProfileLoading = false);
                Fluttertoast.showToast(
                  msg: "Profile updated",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0
                );
              }
            }, 
            icon: const Icon(Icons.check, color: Colors.green)
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: updateProfileLoading ? LinearProgressIndicator() : null,
            ),
            Container(
              padding: EdgeInsets.only(top: 50, bottom: 50),
              child: avatar != null ? CircleAvatar(
                radius: 100,
                backgroundImage: FileImage(avatar!),
                child: IconButton(
                  onPressed: () => selectFile(), 
                  icon: const Icon(Icons.edit)
                ),
              ) : userProvider.currentUser != null ? CircleAvatar(
                radius: 100,
                backgroundImage: NetworkImage(userProvider.currentUser!.avatar),
                child: IconButton(
                  onPressed: () => selectFile(), 
                  icon: const Icon(Icons.edit)
                ),
              ) : null,
            ),
            Container(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Username:',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                 TextFormField(
                    controller: bioController,
                    decoration: const InputDecoration(
                      hintText: 'Bio:',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Email:',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
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