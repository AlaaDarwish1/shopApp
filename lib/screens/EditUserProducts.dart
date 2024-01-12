import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/Product.dart';
import '../providers/Products.dart';

class EditUserProducts extends StatefulWidget {
  const EditUserProducts({Key? key}) : super(key: key);
  static const routeName = "EditUserProducts";

  @override
  State<EditUserProducts> createState() => _EditUserProductsState();
}

class _EditUserProductsState extends State<EditUserProducts> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  Product? _editedProduct = Product(
      id: "",
      title: "",
      price: 0,
      description: "",
      imageUrl:
          "https://images.unsplash.com/photo-1579818276744-a8ce9771445c?q=80&w=1780&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D");
  var isInit = true;
  var _initValues = {
    "title": "",
    "price": "",
    "description": "",
    "imageUrl": null,
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is String) {
        final productId = arguments;
        _editedProduct = Provider.of<Products>(context).findById(productId);
        if (_editedProduct != null) {
          _initValues = {
            "title": _editedProduct!.title,
            "price": _editedProduct!.price.toString(),
            "description": _editedProduct!.description,
            "imageUrl": null,
          };
          //Ensure initialValue is null when using a controller:
          // If you are using a controller, make sure that the initialValue property is set to null.
          _imageUrlController.text = _editedProduct!.imageUrl;
        }
      }
    }
    isInit = false;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          !_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https') ||
          !_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg')) {
        return;
      }
      setState(() {});
    }
  }

  void _saveForm() async {
    final isValid = _form.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    _form.currentState?.save();

    if (_editedProduct?.id != null) {
      await Provider.of<Products>(context, listen: false)
          .addProduct(_editedProduct!.id, _editedProduct!)
          .catchError((error) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text("An error occurred"),
                  content: Text("Something went wrong"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Okay"))
                  ],
                ));
      }).then((_) => Navigator.pop(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit your products"),
        centerTitle: true,
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _initValues["title"],
                decoration: InputDecoration(labelText: "Title"),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                validator: (value) {
                  if (value?.isEmpty != false) {
                    return "Please type a title";
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  if (_editedProduct != null) {
                    _editedProduct = Product(
                      id: _editedProduct?.id ?? "",
                      title: value ?? "Title is empty",
                      description: _editedProduct?.description ?? "",
                      price: _editedProduct?.price ?? 0,
                      imageUrl: _editedProduct?.imageUrl ?? "",
                      isFavorite: _editedProduct?.isFavorite ?? false,
                    );
                  }
                },
              ),
              TextFormField(
                initialValue: _initValues["price"],
                decoration: InputDecoration(labelText: "Price"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                validator: (value) {
                  if (value?.isEmpty != false) {
                    return "Please enter a price";
                  }
                  if (double.tryParse(value ?? "") == null) {
                    return "Please enter a valid number";
                  }
                  if (double.parse(value ?? "") <= 0) {
                    return "Please enter a number greater than zero";
                  }
                  return null;
                },
                onSaved: (value) {
                  if (_editedProduct != null) {
                    _editedProduct = Product(
                      id: _editedProduct!.id,
                      title: _editedProduct!.title,
                      description: _editedProduct!.description,
                      price: double.parse(value ?? "Price is empty"),
                      imageUrl: _editedProduct!.imageUrl,
                      isFavorite: _editedProduct!.isFavorite,
                    );
                  }
                },
              ),
              TextFormField(
                initialValue: _initValues["description"],
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                onSaved: (value) {
                  if (_editedProduct != null) {
                    _editedProduct = Product(
                      id: _editedProduct!.id,
                      title: _editedProduct!.title,
                      description: value ?? "Description is empty",
                      price: _editedProduct!.price,
                      imageUrl: _editedProduct!.imageUrl,
                      isFavorite: _editedProduct!.isFavorite,
                    );
                  }
                },
                validator: (value) {
                  if (value?.isEmpty != false) {
                    return "Please enter a description";
                  }
                  // "(value?.length ?? 0) < 10" performs the same action
                  if (value?.length.compareTo(10) == -1) {
                    return "Please enter a longer text";
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                    ),
                    child: _imageUrlController.text.isEmpty
                        ? Icon(
                            Icons.insert_page_break_sharp,
                            color: Colors.red,
                          )
                        : FittedBox(
                            child: Image.network(_imageUrlController.text,
                                fit: BoxFit.cover),
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue: _initValues["imageUrl"],
                      decoration: InputDecoration(labelText: "Image URL"),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onSaved: (value) {
                        if (_editedProduct != null) {
                          _editedProduct = Product(
                              id: _editedProduct!.id,
                              title: _editedProduct!.title,
                              description: _editedProduct!.description,
                              price: _editedProduct!.price,
                              isFavorite: _editedProduct!.isFavorite,
                              imageUrl: value ??
                                  "https://images.unsplash.com/photo-1579818276744-a8ce9771445c?q=80&w=1780&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D");
                        }
                      },
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
