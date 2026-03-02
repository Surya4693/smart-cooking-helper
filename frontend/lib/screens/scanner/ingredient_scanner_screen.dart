import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../models/food_model.dart';
import 'dart:io';

class IngredientScannerScreen extends StatefulWidget {
  const IngredientScannerScreen({Key? key}) : super(key: key);

  @override
  State<IngredientScannerScreen> createState() => _IngredientScannerScreenState();
}

class _IngredientScannerScreenState extends State<IngredientScannerScreen> {
  final _apiService = ApiService();
  final _imagePicker = ImagePicker();
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isScanning = false;
  FoodItem? _scannedFood;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
        );
        await _cameraController!.initialize();
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() => _isScanning = true);

    try {
      final XFile image = await _cameraController!.takePicture();
      // In a real app, you would use ML Kit or a barcode scanner API here
      // For now, we'll simulate scanning
      await _processImage(image.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking picture: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() => _isScanning = true);

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        await _processImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _processImage(String imagePath) async {
    try {
      // Simulate barcode scanning - in production, use ML Kit or barcode scanner
      // For demo purposes, we'll use a mock barcode
      const mockBarcode = '1234567890123';
      
      final foodItem = await _apiService.scanBarcode(mockBarcode);
      setState(() => _scannedFood = foodItem);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanning error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Scanner'),
      ),
      body: _scannedFood != null
          ? _buildScannedFoodView()
          : _buildCameraView(),
    );
  }

  Widget _buildCameraView() {
    if (!_isInitialized || _cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(_cameraController!),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: _pickImageFromGallery,
                    heroTag: 'gallery',
                    child: const Icon(Icons.photo_library),
                  ),
                  FloatingActionButton(
                    onPressed: _isScanning ? null : _takePicture,
                    heroTag: 'capture',
                    backgroundColor: Colors.orange,
                    child: _isScanning
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.camera_alt),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Point camera at barcode or ingredient',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScannedFoodView() {
    final food = _scannedFood!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Column(
              children: [
                Image.network(
                  food.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text('Barcode: ${food.barcode}'),
                      const SizedBox(height: 16),
                      Text(
                        'Nutrition Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildNutritionRow('Calories', '${food.nutritionInfo.calories.toStringAsFixed(0)} cal'),
                      _buildNutritionRow('Protein', '${food.nutritionInfo.protein.toStringAsFixed(1)}g'),
                      _buildNutritionRow('Carbs', '${food.nutritionInfo.carbohydrates.toStringAsFixed(1)}g'),
                      _buildNutritionRow('Fat', '${food.nutritionInfo.fat.toStringAsFixed(1)}g'),
                      if (food.ingredients.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Ingredients',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ...food.ingredients.map((ing) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('• $ing'),
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _scannedFood = null);
                  },
                  child: const Text('Scan Another'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Add to shopping list or ingredients
                    Navigator.pop(context, food);
                  },
                  child: const Text('Add to List'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
