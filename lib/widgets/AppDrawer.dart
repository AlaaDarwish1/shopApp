import 'package:flutter/material.dart';
import 'package:shop_app_return/screens/OrdersOverview.dart';
import 'package:shop_app_return/screens/ProductsOverview.dart';
import 'package:shop_app_return/screens/UserProducts.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text("Hello There"),
            automaticallyImplyLeading: true,
          ),
          ListTile(
            leading: Icon(
              Icons.shopping_cart_checkout,
              color: Colors.brown,
            ),
            title: Text("SHOP"),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ProductsOverview.routeName);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.payments_outlined,
              color: Colors.brown,
            ),
            title: Text("ORDERS"),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersOverview.routeName);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.edit,
              color: Colors.brown,
            ),
            title: Text("Products Manager"),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProducts.routeName);
            },
          ),
          // Divider(),
        ],
      ),
    );
  }
}
