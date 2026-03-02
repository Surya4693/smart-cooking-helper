import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/food_model.dart';

class ShoppingListScreen extends StatefulWidget {
  final List<String>? missingIngredients;

  const ShoppingListScreen({Key? key, this.missingIngredients}) : super(key: key);

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _apiService = ApiService();
  final List<ShoppingItem> _shoppingList = [];
  final _newItemController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.missingIngredients != null) {
      _addMissingIngredients(widget.missingIngredients!);
    }
    _loadShoppingList();
  }

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  Future<void> _loadShoppingList() async {
    setState(() => _isLoading = true);
    try {
      // Load shopping list from API
      // For now, using local list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading list: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addMissingIngredients(List<String> ingredients) {
    for (var ingredient in ingredients) {
      _shoppingList.add(ShoppingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: ingredient,
        quantity: 1,
        unit: 'item',
        addedAt: DateTime.now(),
      ));
    }
  }

  void _addItem() {
    if (_newItemController.text.trim().isEmpty) return;

    setState(() {
      _shoppingList.add(ShoppingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _newItemController.text.trim(),
        quantity: 1,
        unit: 'item',
        addedAt: DateTime.now(),
      ));
      _newItemController.clear();
    });
  }

  void _toggleItem(ShoppingItem item) {
    setState(() {
      final index = _shoppingList.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _shoppingList[index] = ShoppingItem(
          id: item.id,
          name: item.name,
          quantity: item.quantity,
          unit: item.unit,
          isPurchased: !item.isPurchased,
          addedAt: item.addedAt,
        );
      }
    });
  }

  void _removeItem(ShoppingItem item) {
    setState(() {
      _shoppingList.removeWhere((i) => i.id == item.id);
    });
  }

  void _clearCompleted() {
    setState(() {
      _shoppingList.removeWhere((item) => item.isPurchased);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pendingItems = _shoppingList.where((item) => !item.isPurchased).toList();
    final completedItems = _shoppingList.where((item) => item.isPurchased).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          if (completedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearCompleted,
              tooltip: 'Clear completed',
            ),
        ],
      ),
      body: Column(
        children: [
          // Add item section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newItemController,
                    decoration: InputDecoration(
                      hintText: 'Add item to shopping list...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_circle),
                  color: Theme.of(context).primaryColor,
                  iconSize: 32,
                ),
              ],
            ),
          ),
          // Shopping list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _shoppingList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your shopping list is empty',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          if (pendingItems.isNotEmpty) ...[
                            Text(
                              'Pending (${pendingItems.length})',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            ...pendingItems.map((item) => _buildShoppingItem(item)),
                            const SizedBox(height: 24),
                          ],
                          if (completedItems.isNotEmpty) ...[
                            Text(
                              'Completed (${completedItems.length})',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            ...completedItems.map((item) => _buildShoppingItem(item)),
                          ],
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingItem(ShoppingItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: item.isPurchased,
          onChanged: (_) => _toggleItem(item),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isPurchased ? TextDecoration.lineThrough : null,
            color: item.isPurchased ? Colors.grey : null,
          ),
        ),
        subtitle: Text('${item.quantity} ${item.unit}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _removeItem(item),
          color: Colors.red,
        ),
      ),
    );
  }
}
