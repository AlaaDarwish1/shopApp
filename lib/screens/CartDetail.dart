import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_return/screens/OrdersOverview.dart';
import '../providers/Orders.dart';
import '../widgets/CartItem.dart' as ci;
// OR:
// import '../providers/Cart.dart' show Cart;
// letting the compiler know that we only need the Cart class not the CartItem class inside it
import '../providers/Cart.dart';

class CartDetail extends StatelessWidget {
  const CartDetail({Key? key}) : super(key: key);
  static const routeName = "CartDetail";

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Card(
            elevation: 5,
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("TOTAL"),
                      Chip(
                        label: Text(
                          "\$${cartData.totalAmount.toStringAsFixed(2)}",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  OrderButton(cartData: cartData)
                ],
              ),
            ),
          ),
          SizedBox(),
          Expanded(
            child: ListView.builder(
              itemCount: cartData.itemCount,
              itemBuilder: (context, i) => ci.CartItem(
                  id: cartData.items.values.toList()[i].id,
                  productId: cartData.items.keys.toList()[i],
                  title: cartData.items.values.toList()[i].title,
                  quantity: cartData.items.values.toList()[i].quantity,
                  price: cartData.items.values.toList()[i].price),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cartData,
  }) : super(key: key);

  final Cart cartData;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: (widget.cartData.totalAmount <= 0 || _isLoading)
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });
                await Provider.of<Orders>(context, listen: false).addOrder(
                    widget.cartData.items.values.toList(),
                    widget.cartData.totalAmount);
                widget.cartData.clear();
                setState(() {
                  _isLoading = false;
                });
                // Navigator.of(context)
                //     .pushReplacementNamed(OrdersOverview.routeName);
              },
        child: _isLoading
            ? CircularProgressIndicator()
            : Text(
                "Order Now",
                style: TextStyle(fontSize: 17, color: Colors.teal),
              ));
  }
}
