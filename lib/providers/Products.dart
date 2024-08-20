import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/HttpException.dart';
import 'Product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  final String authToken;
  final String? userId;
  Products(this.authToken, this._items, this.userId);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favOnly {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts({String? updateToken, String? updateUserId, bool filterByUser = false}) async {
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    Uri url = Uri.parse(
        'https://shopappreturn-default-rtdb.asia-southeast1.firebasedatabase.app/Products.json?auth=$authToken&$filterString');
      print("Products class.User ID: $userId");
      final response = await http.get(url);
      if (response.statusCode == 200){
        final extractedData = await json.decode(response.body) as Map<String, dynamic>;
        url = Uri.parse(
            'https://shopappreturn-default-rtdb.asia-southeast1.firebasedatabase.app/UserFavorites/$userId.json?auth=$authToken');
        final favoriteResponse = await http.get(url);
        final favoriteData = json.decode(favoriteResponse.body);
        final List<Product> loadedProducts = [];
        extractedData.forEach((prodId, prodData) {
          loadedProducts.add(Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
              isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,));
        });
        _items = loadedProducts;
        notifyListeners();
        print("Products class JSON RESPONSE: ${json.decode(response.body)}");
      } else {
        throw Exception("Products class Faild to load ...");
      }
  }

  Future addProduct(String id, Product product) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      await http.patch(
          Uri.parse(
              'https://shopappreturn-default-rtdb.asia-southeast1.firebasedatabase.app/Products/$id.json?auth=$authToken'),
          body: jsonEncode({
            'title': product.title,
            'imageUrl': product.imageUrl,
            'description': product.description,
            'creatorId': userId,
          }));
      _items[productIndex] = product;
      notifyListeners();
    } else {
      Uri url = Uri.parse(
          'https://shopappreturn-default-rtdb.asia-southeast1.firebasedatabase.app/Products.json?auth=$authToken');
      try {
        final response = await http.post(
          url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          }),
        );

        if (response.statusCode == 200) {
          final newProduct = Product(
            id: json.decode(response.body)['name'],
            title: product.title,
            description: product.description,
            price: product.price,
            imageUrl: product.imageUrl,
          );
          _items.add(newProduct);
          notifyListeners();
          print('Products class.Product added successfully: ${newProduct.id}');
        } else {
          print('Products class.Failed to add product. Status code: ${response.statusCode}');
        }
      } catch (error) {
        print('Products class.Error adding product: $error');
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    Uri url = Uri.parse(
        'https://shopappreturn-default-rtdb.asia-southeast1.firebasedatabase.app/Products/$id.json?auth=$authToken');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException(message: "Unable to delete the product.");
    }
    existingProduct = null;
  }
}
