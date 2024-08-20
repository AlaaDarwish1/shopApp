import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shop_app_return/providers/Auth.dart';
import 'package:shop_app_return/providers/Cart.dart';
import 'package:shop_app_return/providers/Orders.dart';
import 'package:shop_app_return/screens/AuthScreen.dart';
import 'package:shop_app_return/screens/CartDetail.dart';
import 'package:shop_app_return/screens/EditUserProducts.dart';
import 'package:shop_app_return/screens/OrdersOverview.dart';
import 'package:shop_app_return/screens/ProductDetail.dart';
import 'package:shop_app_return/screens/ProductsOverview.dart';
import 'package:shop_app_return/screens/SplashScreen.dart';
import 'package:shop_app_return/screens/UserProducts.dart';

import 'firebase_options.dart';
import 'providers/Products.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (context, auth, previousProducts) => Products(
              auth.token.toString(),
              previousProducts?.items == null ? [] : previousProducts!.items,
              auth.userId),
          create: (BuildContext context) => Products('', [], ''),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (context, auth, previousOrders) => Orders(
              auth.token.toString(),
              previousOrders == null ? [] : previousOrders.orders,
              auth.userId),
          create: (BuildContext context) => Orders('', [], ''),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
              fontFamily: 'Righteous',
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.teal,
              ),
              scaffoldBackgroundColor: Colors.white,
              ),
          home: auth.isAuth
              ? ProductsOverview()
              : FutureBuilder(
                  future: auth.tryAutoLogin(context),
                  builder: (ctx, authResultSnapshot) {
                    if (authResultSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return SplashScreen();
                    } else {
                      return AuthScreen();
                    }
                  },
                ),
          routes: {
            ProductsOverview.routeName: (context) => ProductsOverview(),
            ProductDetail.routeName: (context) => ProductDetail(),
            CartDetail.routeName: (context) => CartDetail(),
            OrdersOverview.routeName: (context) => OrdersOverview(),
            UserProducts.routeName: (context) => UserProducts(),
            EditUserProducts.routeName: (context) => EditUserProducts(),
            AuthScreen.routeName: (context) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
