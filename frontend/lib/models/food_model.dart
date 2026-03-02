class FoodItem {
  final String id;
  final String name;
  final String barcode;
  final String imageUrl;
  final NutritionInfo nutritionInfo;
  final double servingSize;
  final String servingUnit;
  final List<String> ingredients;
  final DateTime expiryDate;
  final DateTime scannedAt;

  FoodItem({
    required this.id,
    required this.name,
    required this.barcode,
    required this.imageUrl,
    required this.nutritionInfo,
    required this.servingSize,
    required this.servingUnit,
    required this.ingredients,
    required this.expiryDate,
    required this.scannedAt,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      barcode: json['barcode'] as String,
      imageUrl: json['image_url'] as String,
      nutritionInfo: NutritionInfo.fromJson(json['nutrition_info'] as Map<String, dynamic>),
      servingSize: (json['serving_size'] as num?)?.toDouble() ?? 0.0,
      servingUnit: json['serving_unit'] as String,
      ingredients: List<String>.from(json['ingredients'] as List? ?? []),
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      scannedAt: DateTime.parse(json['scanned_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'image_url': imageUrl,
      'nutrition_info': nutritionInfo.toJson(),
      'serving_size': servingSize,
      'serving_unit': servingUnit,
      'ingredients': ingredients,
      'expiry_date': expiryDate.toIso8601String(),
      'scanned_at': scannedAt.toIso8601String(),
    };
  }
}

class NutritionInfo {
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final double sodium;
  final double sugar;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.fiber,
    required this.sodium,
    required this.sugar,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0.0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'fiber': fiber,
      'sodium': sodium,
      'sugar': sugar,
    };
  }
}

class ShoppingItem {
  final String id;
  final String name;
  final int quantity;
  final String unit;
  final bool isPurchased;
  final DateTime addedAt;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.isPurchased = false,
    required this.addedAt,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      isPurchased: json['is_purchased'] as bool? ?? false,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'is_purchased': isPurchased,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
