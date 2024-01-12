import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop_app_return/providers/Orders.dart' as ord;
import 'package:intl/intl.dart';

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;
  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "\$${widget.order.amount.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 25, color: Colors.red),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.symmetric(horizontal: 8),
              height: min(widget.order.products.length * 20.0 + 10, 180),
              child: ListView(
                children: widget.order.products
                    .map((prod) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              prod.title,
                              style: TextStyle(letterSpacing: 1),
                            ),
                            Text(
                              "${prod.price * prod.quantity}",
                              style: TextStyle(letterSpacing: 1),
                            ),
                          ],
                        ))
                    .toList(),
              ),
            )
        ],
      ),
    );
  }
}
