import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_return/providers/Products.dart';

import '../providers/Product.dart';
import 'ProductItem.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavOnly;

  const ProductsGrid({super.key, required this.showFavOnly});
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFavOnly ? productsData.favOnly : productsData.items;

    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: products.length,
        // Use .value when providing a single item from a list or grid:
        itemBuilder: (context, i) => ChangeNotifierProvider.value(
              child: ProductItem(),
              value: products[i],
            )
        // ProductItem(
        //     id: products[i].id,
        //     title: products[i].title,
        //     imageUrl: products[i].imageUrl),
        );
  }
}
