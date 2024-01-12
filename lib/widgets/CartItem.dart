import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_return/providers/Cart.dart';

class CartItem extends StatelessWidget {
  const CartItem(
      {Key? key,
      required this.id,
      required this.productId,
      required this.price,
      required this.quantity,
      required this.title});
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context, listen: true);
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ),
      ),
      onDismissed: (direction) {
        cartData.removeItem(productId);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 5.0,
            backgroundColor: Colors.white,
            duration: Duration(seconds: 3),
            content: Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Item dismissed',
                  style: TextStyle(color: Colors.black),
                )
              ],
            ),
            action: SnackBarAction(
                label: "Undo",
                onPressed: () {
                  cartData.returnCartItem(productId);
                  print("Undo done");
                }),
          ),
        );
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Are You Sure?"),
            content: Text("Do you want to remove this item from the cart?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
                child: Text("NO"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
                child: Text("YES"),
              ),
            ],
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            // dense: true,
            leading: Container(
              alignment: Alignment.center,
              // height: 30,
              width: 65,
              child: Text(
                '\$$price',
                style: TextStyle(fontSize: 20, overflow: TextOverflow.ellipsis),
              ),
            ),
            title: Text(title),
            subtitle: Row(
              children: [
                Text('Total:'),
                Text(
                  ' \$${(price * quantity).toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.red),
                )
              ],
            ),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
