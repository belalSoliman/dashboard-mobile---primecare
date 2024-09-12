import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final List<ProductModel> _products = []; // Internal list to hold product data

  // Getter to return the list of products
  List<ProductModel> get getProducts {
    return [..._products]; // Return a copy of the list
  }

  // Method to find a product by its ID
  ProductModel? findByProdId(String productId) {
    try {
      return _products.firstWhere(
        (element) => element.productId == productId,
      );
    } catch (e) {
      return null; // Return null if no product is found
    }
  }

  // Method to find products by category
  List<ProductModel> findByCategory({required String ctgName}) {
    return _products
        .where((element) =>
            element.category.toLowerCase().contains(ctgName.toLowerCase()))
        .toList();
  }

  // Method to search products by title within a specific product list
  List<ProductModel> searchQuery({
    required String searchText,
    required List<ProductModel> productList, // Added productList as a parameter
  }) {
    return productList
        .where((element) =>
            element.title.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  // Method to add a product to the list
  void addProduct(ProductModel product) {
    _products.add(product);
    notifyListeners(); // Notify listeners that the data has changed
  }

  // Method to remove a product from the list
  void removeProduct(String productId) {
    _products.removeWhere((element) => element.productId == productId);
    notifyListeners(); // Notify listeners that the data has changed
  }

  // Method to update an existing product
  void updateProduct(ProductModel updatedProduct) {
    final index = _products
        .indexWhere((element) => element.productId == updatedProduct.productId);
    if (index >= 0) {
      _products[index] = updatedProduct;
      notifyListeners(); // Notify listeners that the data has changed
    }
  }
}
