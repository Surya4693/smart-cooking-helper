import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/recipe_model.dart';
import '../models/food_model.dart' as food;

class ApiService {
  late Dio _dio;
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000/api';
  
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add token if available
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  // Recipe endpoints
  Future<List<Recipe>> searchRecipes(String query, {Map<String, dynamic>? filters}) async {
    try {
      final response = await _dio.get(
        '/recipes/search',
        queryParameters: {
          'q': query,
          ...?filters,
        },
      );
      
      final List<dynamic> data = response.data['recipes'] ?? [];
      return data.map((recipe) => Recipe.fromJson(recipe as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Recipe>> getRecommendedRecipes(List<String> availableIngredients) async {
    try {
      final response = await _dio.post(
        '/recipes/recommendations',
        data: {
          'available_ingredients': availableIngredients,
        },
      );

      final List<dynamic> data = response.data['recipes'] ?? [];
      return data.map((recipe) => Recipe.fromJson(recipe as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Recipe> getRecipeDetails(String recipeId) async {
    try {
      final response = await _dio.get('/recipes/$recipeId');
      return Recipe.fromJson(response.data['recipe'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Recipe> getTodayRecommendation(List<String> dietaryPreferences) async {
    try {
      final response = await _dio.post(
        '/recipes/today-recommendation',
        data: {
          'dietary_preferences': dietaryPreferences,
        },
      );
      return Recipe.fromJson(response.data['recipe'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Food/Nutrition endpoints
  Future<food.FoodItem> scanBarcode(String barcode) async {
    try {
      final response = await _dio.get(
        '/nutrition/scan-barcode',
        queryParameters: {'barcode': barcode},
      );
      return food.FoodItem.fromJson(response.data['food_item'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<NutritionInfo> getNutritionInfo(String foodName) async {
    try {
      final response = await _dio.get(
        '/nutrition/info',
        queryParameters: {'food_name': foodName},
      );
      return NutritionInfo.fromJson(response.data['nutrition_info'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<String>> getShoppingListSuggestions(Recipe recipe, List<String> availableIngredients) async {
    try {
      final response = await _dio.post(
        '/nutrition/shopping-list',
        data: {
          'recipe_id': recipe.id,
          'available_ingredients': availableIngredients,
        },
      );
      return List<String>.from(response.data['missing_ingredients'] as List? ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Favorite endpoints
  Future<void> addFavorite(String recipeId) async {
    try {
      await _dio.post('/favorites/add', data: {'recipe_id': recipeId});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> removeFavorite(String recipeId) async {
    try {
      await _dio.post('/favorites/remove', data: {'recipe_id': recipeId});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Recipe>> getFavorites() async {
    try {
      final response = await _dio.get('/favorites');
      final List<dynamic> data = response.data['favorites'] ?? [];
      return data.map((recipe) => Recipe.fromJson(recipe as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // History endpoints
  Future<void> addToHistory(String recipeId) async {
    try {
      await _dio.post('/history/add', data: {'recipe_id': recipeId});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Recipe>> getRecentHistory() async {
    try {
      final response = await _dio.get('/history/recent');
      final List<dynamic> data = response.data['history'] ?? [];
      return data.map((recipe) => Recipe.fromJson(recipe as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['message'] ?? 'An error occurred';
    }
    return error.message ?? 'Network error';
  }
}
