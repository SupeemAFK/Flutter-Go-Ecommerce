import 'package:client/provider/userProvider.dart';
import 'package:client/screens/addProduct.dart';
import 'package:client/screens/addReview.dart';
import 'package:client/screens/cart.dart';
import 'package:client/screens/editProduct.dart';
import 'package:client/screens/home.dart';
import 'package:client/screens/myStore.dart';
import 'package:client/screens/product.dart';
import 'package:client/screens/reviews.dart';
import 'package:client/screens/signin.dart';
import 'package:client/screens/signup.dart';
import 'package:client/screens/profile.dart';
import 'package:client/screens/store.dart';
import 'package:client/screens/userPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => UserProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    userProvider.getCurrentUser();

    return MaterialApp.router(
      title: 'Ecommerce App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router(),
    );
  }
}

GoRouter router() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const BottomNavigationBarExample(),
        redirect: (context, state) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString("token");
          if (token == null) {
            return '/signin';
          }
        }
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters["id"];
          return ProductPage(id: id);
        },
      ),
      GoRoute(
        path: '/store/:id',
        builder: (context, state) {
          final id = state.pathParameters["id"];
          return Store(id: id);
        },
      ),
      GoRoute(
        path: '/reviews/:id',
        builder: (context, state) {
          final id = state.pathParameters["id"];
          return Reviews(id: id);
        },
      ),
      GoRoute(
        path: '/addReview/:productID',
        builder: (context, state) {
          final id = state.pathParameters["productID"];
          return AddReview(productID: id);
        },
      ),
      GoRoute(
        path: '/myStore',
        builder: (context, state) {
          final userProvider = context.read<UserProvider>();
          return MyStore(id: userProvider.currentUser!.id);
        },
      ),
      GoRoute(
        path: '/addProduct',
        builder: (context, state) => const AddProduct(),
      ),
       GoRoute(
        path: '/editProduct/:id',
        builder: (context, state) {
          final id = state.pathParameters["id"];
          return EditProduct(id: id);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) {
          final userProvider = context.read<UserProvider>();
          userProvider.getUserCarts();
          return const Cart();
        },
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const Signin(),
        redirect: (context, state) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString("token");
          if (token != null) {
            return '/';
          }
        }
      ),
       GoRoute(
        path: '/signup',
        builder: (context, state) => const Signup(),
        redirect: (context, state) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString("token");
          if (token != null) {
            return '/';
          }
        }
      )
    ],
  );
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    Home(),
    UserPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}