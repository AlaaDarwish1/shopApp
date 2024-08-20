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
    await Provider.of<Products>(ctx, listen: false).fetchAndSetProducts(filterByUser: true);
  }

  @override
  Widget build(BuildContext context) {
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
      // the user will Work only on the product the user owns
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) => snapshot.connectionState == ConnectionState.waiting ? Center(child: CircularProgressIndicator(),)  : RefreshIndicator(
          onRefresh: () => _refreshProducts(context),
          child: Consumer <Products>(
            builder: (ctx, productsData, _) => Padding(
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                itemBuilder: (_, i) => Column(
                  children: [
                    UserProductsItem(
                      id: productsData.items[i].id,
                      title: productsData.items[i].title,
                      imageUrl: productsData.items[i].imageUrl,
                    ),
                    const Divider(
                      thickness: 2,
                    ),
                  ],
                ),
                itemCount: productsData.items.length,
              ),
            ),
          ),
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}
