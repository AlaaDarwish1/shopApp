import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_return/providers/Product.dart';
import 'package:shop_app_return/screens/ProductDetail.dart';

import '../providers/Cart.dart';

class ProductItem extends StatelessWidget {
  ProductItem({
    Key? key,
  }) : super(key: key);
  // final String id;
  // final String title;
  // final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .pushNamed(ProductDetail.routeName, arguments: product.id);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'AmaticSC'),
          ),
          // Consumer is used to only rebuilds the part that with change over use:
          leading: Consumer<Product>(
            // the child keyword is used to prevent a widget from rebuilding when a widget of the Consumer rebuilds
            builder: (context, product, child) => IconButton(
              onPressed: () {
                product.toggleFavoriteStatus();
              },
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Item Added To Cart"),
                duration: Duration(seconds: 3),
                action: SnackBarAction(
                    label: "Undo",
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    }),
              ));
            },
            icon: Icon(Icons.shopping_cart_checkout),
          ),
        ),
      ),
    );
  }
}
