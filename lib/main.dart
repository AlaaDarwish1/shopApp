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
              previousProducts?.items == null ? [] : previousProducts!.items),
          create: (BuildContext context) => Products('', []),
        ),
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (context, auth, previousOrders) => Orders(
              auth.token.toString(),
              previousOrders == null ? [] : previousOrders.orders),
          create: (BuildContext context) => Orders('', []),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          // darkTheme: ThemeData.dark(),
          title: 'MyShop',
          theme: ThemeData(
              fontFamily: 'Righteous',
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.teal,
              ),
              scaffoldBackgroundColor: Colors.white
              // brightness: Brightness.dark,
              ),
          home: auth.isAuth ? ProductsOverview() : AuthScreen(),
          // home: ProductsOverview(),
          // initialRoute:
          //     auth.isAuth ? ProductsOverview() : AuthScreen(),
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
