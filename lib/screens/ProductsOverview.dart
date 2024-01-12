import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_return/screens/CartDetail.dart';
import 'package:shop_app_return/widgets/AppDrawer.dart';
import 'package:shop_app_return/widgets/Badge.dart';

import '../providers/Cart.dart';
import '../providers/Products.dart';
import '../widgets/ProductsGrid.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverview extends StatefulWidget {
  static String routeName = "";
  ProductsOverview({Key? key}) : super(key: key);

  @override
  State<ProductsOverview> createState() => _ProductsOverviewState();
}

class _ProductsOverviewState extends State<ProductsOverview> {
  var _showOnlyFav = false;

  get showOnlyFav => _showOnlyFav;

  set showOnlyFav(showOnlyFav) {
    _showOnlyFav = showOnlyFav;
  }

  var isInit = true;
  var isLoading = false;

  @override
  void initState() {
    if (isInit) {
      setState(() {
        isLoading = true;
        Future.delayed(Duration.zero)
            .then((_) => Provider.of<Products>(context, listen: false)
                .fetchAndSetProducts())
            .then((_) {
          setState(() {
            isLoading = false;
          });
        });
      });
    }
    isInit = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shop"),
        centerTitle: true,
        actions: <Widget>[
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
                value: cart.itemCount.toString(),
                color: Colors.deepOrange,
                child: ch!),
            child: IconButton(
              icon: Icon(Icons.shopping_cart_checkout),
              onPressed: () {
                Navigator.pushNamed(context, CartDetail.routeName);
              },
            ),
          ),
          PopupMenuButton(
              icon: Icon(Icons.more_vert_rounded),
              onSelected: (FilterOptions selectedVal) {
                setState(() {
                  if (selectedVal == FilterOptions.Favorites) {
                    _showOnlyFav = true;
                  } else {
                    _showOnlyFav = false;
                  }
                });
              },
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text("Only Fav"),
                      value: FilterOptions.Favorites,
                    ),
                    PopupMenuItem(
                      child: Text("Show all"),
                      value: FilterOptions.All,
                    ),
                  ]),
        ],
      ),
      drawer: AppDrawer(),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(showFavOnly: showOnlyFav),
    );
  }
}
