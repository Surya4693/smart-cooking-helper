class Recipe {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<RecipeStep> steps;
  final String imageUrl;
  final String? videoUrl;
  final int preparationTime;
  final int cookingTime;
  final int servings;
  final double rating;
  final NutritionInfo nutritionInfo;
  final List<String> tags;
  final bool isFavorite;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    this.videoUrl,
    required this.preparationTime,
    required this.cookingTime,
    required this.servings,
    required this.rating,
    required this.nutritionInfo,
    required this.tags,
    this.isFavorite = false,
    required this.createdAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      ingredients: List<String>.from(json['ingredients'] as List? ?? []),
      steps: (json['steps'] as List? ?? [])
          .map((step) => RecipeStep.fromJson(step as Map<String, dynamic>))
          .toList(),
      imageUrl: json['image_url'] as String,
      videoUrl: json['video_url'] as String?,
      preparationTime: json['preparation_time'] as int,
      cookingTime: json['cooking_time'] as int,
      servings: json['servings'] as int,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      nutritionInfo: NutritionInfo.fromJson(json['nutrition_info'] as Map<String, dynamic>),
      tags: List<String>.from(json['tags'] as List? ?? []),
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps.map((step) => step.toJson()).toList(),
      'image_url': imageUrl,
      'video_url': videoUrl,
      'preparation_time': preparationTime,
      'cooking_time': cookingTime,
      'servings': servings,
      'rating': rating,
      'nutrition_info': nutritionInfo.toJson(),
      'tags': tags,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? ingredients,
    List<RecipeStep>? steps,
    String? imageUrl,
    String? videoUrl,
    int? preparationTime,
    int? cookingTime,
    int? servings,
    double? rating,
    NutritionInfo? nutritionInfo,
    List<String>? tags,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      preparationTime: preparationTime ?? this.preparationTime,
      cookingTime: cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
      rating: rating ?? this.rating,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RecipeStep {
  final int stepNumber;
  final String instruction;
  final String? imageUrl;
  final String? videoUrl;
  final int? durationSeconds;

  RecipeStep({
    required this.stepNumber,
    required this.instruction,
    this.imageUrl,
    this.videoUrl,
    this.durationSeconds,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      stepNumber: json['step_number'] as int,
      instruction: json['instruction'] as String,
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step_number': stepNumber,
      'instruction': instruction,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'duration_seconds': durationSeconds,
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
