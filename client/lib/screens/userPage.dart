import 'package:client/provider/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPage extends StatefulWidget {
  const UserPage({ super.key });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  void signout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    context.go('/signin');
  }

  @override
  Widget build(BuildContext context){
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                child: user.currentUser != null && user.currentUser!.carts!.length > 0 ? 
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
                      user.currentUser!.carts!.length.toString(),
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
            InkWell(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Container(
                            child: user.currentUser != null ? CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(user.currentUser!.avatar),
                            ) : CircleAvatar(radius: 35),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: user.currentUser != null ? Text(
                              user.currentUser!.username,
                              style: TextStyle(fontSize: 16),
                            ) : null,
                          ),
                        ]
                      ),
                    ),
                    Icon(Icons.edit)
                  ],
                ),
              ),
              onTap: () => context.push('/profile'),
            ),
            Container(
              color: Colors.white,
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => {},
                    child: Container(
                      child: const Column(
                        children: [
                          Icon(Icons.wallet),
                          Text("Purchase")
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => {},
                    child: Container(
                      child: const Column(
                        children: [
                          Icon(Icons.account_box),
                          Text("Packing")
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => {},
                    child: Container(
                      child: const Column(
                        children: [
                          Icon(Icons.local_shipping),
                          Text("Shipping")
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => {},
                    child: Container(
                      child: const Column(
                        children: [
                          Icon(Icons.reviews),
                          Text("Review")
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              color: Colors.white,
              margin: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => {
                      if (user.currentUser != null) context.push('/myStore')
                    },
                    child: ListTile(
                      leading: Icon(Icons.store_rounded),
                      title: Text("My Store"),
                    ),
                  ),
                  InkWell(
                    onTap: () => {},
                    child: ListTile(
                      leading: Icon(Icons.account_box),
                      title: Text("Account"),
                    ),
                  ),
                  InkWell(
                    onTap: () => {},
                    child: ListTile(
                      leading: Icon(Icons.remove_red_eye_sharp),
                      title: Text("Lastest View"),
                    ),
                  ),
                  InkWell(
                    onTap: () => {},
                    child: ListTile(
                      leading: Icon(Icons.thumb_up),
                      title: Text("Liked"),
                    ),
                  ),
                  InkWell(
                    onTap: () => {},
                    child: ListTile(
                      leading: Icon(Icons.contact_support),
                      title: Text("Contact Support"),
                    ),
                  )
                ],
              ),
            ),
            Container(
              color: Colors.white,
              margin: EdgeInsets.only(top: 10),
              child: InkWell(
                onTap: () => signout(),
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text("Log out", style: TextStyle(color: Colors.red)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}