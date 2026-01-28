import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'list_provider.dart';

class RegularItemsScreen extends StatelessWidget {
  const RegularItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ListProvider>(context);
    final regularItems = provider.regularItems;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Manage Quick Items")),
      body: regularItems.isEmpty 
        ? const Center(child: Text("No items yet. Add one below!"))
        : GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            crossAxisSpacing: 12, 
            mainAxisSpacing: 12, 
            childAspectRatio: 1.5 // Rectangular cards
          ),
          itemCount: regularItems.length,
          itemBuilder: (context, index) {
            final item = regularItems[index];
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 32),
                        const SizedBox(height: 8),
                        Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("\$${item['price']}", style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 4, right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: () => provider.deleteRegularItem(item['id']),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        label: const Text("New Quick Item"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Quick Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Item Name", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Default Price", border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Provider.of<ListProvider>(context, listen: false).addRegularItem(
                  nameController.text,
                  double.tryParse(priceController.text) ?? 0.0,
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}