import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel with ChangeNotifier {
  final String productId; // Admin uses String for ID
  final String title; // Aligning the field name with mobile model
  final String description;
  final String category;
  final String
      productQuantity; // Keeping as String for now, assuming admin input is text
  final double price; // Changed to double to match mobile model
  final double discountPercentage; // Added to match mobile model
  final String images; // Aligning field name with mobile model
  final bool isonsale; // Added to match mobile model
  final bool isStrip; // Added to match mobile model
  final Timestamp? timestamp;

  ProductModel({
    this.timestamp,
    required this.productId,
    required this.title,
    required this.description,
    required this.category,
    required this.productQuantity,
    required this.price,
    required this.discountPercentage,
    required this.images,
    required this.isonsale,
    required this.isStrip,
  });
}
