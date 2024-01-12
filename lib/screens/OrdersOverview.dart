import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_return/widgets/AppDrawer.dart';
import 'package:shop_app_return/widgets/OrderItem.dart';

import '../providers/Orders.dart' show Orders;

class OrdersOverview extends StatefulWidget {
  static const String routeName = 'OrdersOverview';

  @override
  State<OrdersOverview> createState() => _OrdersOverviewState();
}

class _OrdersOverviewState extends State<OrdersOverview> {
  Future? _orderFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _orderFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Orders"),
          centerTitle: true,
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: _orderFuture,
          builder: (context, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapshot.error != null) {
                return Center(child: Text("An Error Occured"));
              } else {
                return Consumer<Orders>(
                  builder: (context, orderData, child) => ListView.builder(
                    itemBuilder: (context, i) => OrderItem(orderData.orders[i]),
                    itemCount: orderData.orders.length,
                  ),
                );
              }
            }
          },
        ));
  }
}
