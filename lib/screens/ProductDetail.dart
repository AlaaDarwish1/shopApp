import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/Products.dart';

class ProductDetail extends StatelessWidget {
  const ProductDetail({Key? key}) : super(key: key);
  // final productId;
  static const routeName = "ProductDetail";

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: Image.network(
                loadedProduct.imageUrl,
                fit: BoxFit.fill,
                height: 250,
                width: double.infinity,
              ),
              elevation: 5,
            ),
            Text(
              loadedProduct.description,
              style: TextStyle(fontSize: 30),
            ),
            const Divider(
              indent: 50,
              endIndent: 50,
              thickness: 2,
            ),
            Row(
              children: [
                const Text(
                  "Price:",
                  style: TextStyle(fontSize: 25, color: Colors.red),
                ),
                Text(
                  " \$${loadedProduct.price}",
                  style: TextStyle(fontSize: 21),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
