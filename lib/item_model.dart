enum Priority { low, medium, high }

class ShoppingItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final String repeat;
  final String notes;
  final bool isPurchased;
  final bool isPinned; 
  final Priority priority;
  final DateTime scheduledDate;
  final double price;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1.0,
    this.unit = 'pcs',
    this.repeat = 'None',
    this.notes = '',
    this.isPurchased = false,
    this.isPinned = false,
    this.priority = Priority.medium,
    required this.scheduledDate,
    this.price = 0.0,
  });

  ShoppingItem copyWith({
    String? name,
    String? category,
    double? quantity,
    String? unit,
    String? repeat,
    String? notes,
    bool? isPurchased,
    bool? isPinned,
    Priority? priority,
    DateTime? scheduledDate,
    double? price,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      repeat: repeat ?? this.repeat,
      notes: notes ?? this.notes,
      isPurchased: isPurchased ?? this.isPurchased,
      isPinned: isPinned ?? this.isPinned,
      priority: priority ?? this.priority,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'repeat': repeat,
      'notes': notes,
      'isPurchased': isPurchased ? 1 : 0,
      'isPinned': isPinned ? 1 : 0,
      'priority': priority.index,
      'scheduledDate': scheduledDate.toIso8601String(),
      'price': price,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] ?? 'pcs',
      repeat: map['repeat'] ?? 'None',
      notes: map['notes'],
      isPurchased: map['isPurchased'] == 1,
      isPinned: (map['isPinned'] ?? 0) == 1,
      priority: Priority.values[map['priority']],
      scheduledDate: DateTime.parse(map['scheduledDate']),
      price: map['price'],
    );
  }
}
