import 'package:nachos_pet_care_flutter/models/pet.dart';

class MarketplaceProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String affiliateUrl;
  final String category; // e.g., 'Alimentación', 'Juguetes', 'Higiene', 'Salud'
  final String source; // e.g., 'Amazon', 'Kiwoko', 'Tiendanimal'
  final double commissionPercentage; // between 8.0 and 12.0
  final double rating;
  final int reviewCount;

  // Matching metadata for recommendations
  final List<PetType> targetPetTypes;
  final int? minAgeMonths;
  final int? maxAgeMonths;
  final double? minWeightKg;
  final double? maxWeightKg;
  final List<String> recommendedKeywords; // e.g., ['gastritis', 'dermatitis', 'rabia', 'artritis']

  MarketplaceProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.affiliateUrl,
    required this.category,
    required this.source,
    required this.commissionPercentage,
    this.rating = 4.5,
    this.reviewCount = 120,
    required this.targetPetTypes,
    this.minAgeMonths,
    this.maxAgeMonths,
    this.minWeightKg,
    this.maxWeightKg,
    this.recommendedKeywords = const [],
  });

  // Calculate estimated commission earned
  double get commissionAmount => price * (commissionPercentage / 100);

  // Checks if this product is generally suitable for a pet type
  bool supportsPetType(PetType type) {
    return targetPetTypes.contains(type);
  }
}
