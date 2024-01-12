import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_return/screens/EditUserProducts.dart';
import 'package:shop_app_return/widgets/AppDrawer.dart';
import 'package:shop_app_return/widgets/UserProductsItem.dart';

import '../providers/Products.dart';

class UserProducts extends StatelessWidget {
  const UserProducts({Key? key}) : super(key: key);
  static const routeName = "UserProducts";

  Future<void> _refreshProducts(BuildContext ctx) async {
    await Provider.of<Products>(ctx, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products Manager"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, EditUserProducts.routeName);
            },
            icon: const Icon(Icons.add_sharp),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemBuilder: (_, i) => Column(
              children: [
                UserProductsItem(
                  id: productsData.items[i].id,
                  title: productsData.items[i].title,
                  imageUrl: productsData.items[i].imageUrl,
                ),
                Divider(
                  // indent: 50,
                  // endIndent: 50,
                  thickness: 2,
                ),
              ],
            ),
            itemCount: productsData.items.length,
          ),
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}
