import 'dart:async';
import 'package:flutter/material.dart';
import 'item_model.dart';
import 'notification_service.dart';
import 'database_helper.dart';

enum SortMethod { defaultSort, byPriority, byPrice }

class ListProvider extends ChangeNotifier {
  List<ShoppingItem> _items = [];
  DateTime _selectedDate = DateTime.now();
  bool _isDarkMode = false;
  SortMethod _sortMethod = SortMethod.defaultSort;
  List<Map<String, dynamic>> _regularItems = [];
  List<Map<String, dynamic>> _topPicks = [];

  Color _themeColor = Colors.deepPurple;
  double _dailyBudget = 500.0;
  String _selectedCategoryFilter = 'All';
  double _taxRate = 0.0;
  bool _isGroupedByCategory = false;

  bool _isMarketMode = false;
  int _marketInterval = 4;
  Timer? _marketTimer;

  String _languageCode = 'en';
  String _currencySymbol = '₹'; 
  double _currencyRate = 1.0;

  final Map<String, Map<String, String>> _translations = {
    'en': { 'app_title': 'Plan My Shop', 'shop': 'Shop', 'expenses': 'Expenses', 'settings': 'Settings', 'total': 'Total', 'spent': 'Spent', 'budget': 'Budget', 'add_item': 'Add Item', 'edit_item': 'Edit Item', 'shopping_mode': 'Shopping Mode', 'copy': 'Copy List', 'clear': 'Clear Purchased', 'move': 'Move to Tomorrow', 'search': 'Search...', 'history': 'History', 'spending_category': 'Spending by Category', 'top_picks': 'Top Picks', 'quick_add': 'Quick Add', 'save': 'Save', 'cancel': 'Cancel', 'language': 'Language', 'currency': 'Currency', 'share': 'Share List', 'market_mode': 'Market Mode', 'enable_aisle': 'Enable Aisle Mode', 'tax_rate': 'Tax Rate', 'change_theme': 'Change Theme' },
    'hi': { 'app_title': 'मेरा शॉप प्लान', 'shop': 'खरीदारी', 'expenses': 'खर्चे', 'settings': 'सेटिंग्स', 'total': 'कुल', 'spent': 'खर्च', 'budget': 'बजट', 'add_item': 'सामान जोड़ें', 'edit_item': 'संपादित करें', 'shopping_mode': 'शॉपिंग मोड', 'copy': 'कॉपी करें', 'clear': 'खरीदे गए हटाएं', 'move': 'कल पर टालें', 'search': 'खोजें...', 'history': 'इतिहास', 'spending_category': 'श्रेणी अनुसार खर्च', 'top_picks': 'शीर्ष चयन', 'quick_add': 'जल्दी जोड़ें', 'save': 'सहेजें', 'cancel': 'रद्द करें', 'language': 'भाषा', 'currency': 'मुद्रा', 'share': 'साझा करें', 'market_mode': 'मार्केट मोड', 'enable_aisle': 'ऐसल मोड सक्षम करें', 'tax_rate': 'कर दर', 'change_theme': 'थीम बदलें' },
    'es': { 'app_title': 'Mi Compra', 'shop': 'Tienda', 'expenses': 'Gastos', 'settings': 'Ajustes', 'total': 'Total', 'spent': 'Gastado', 'budget': 'Presupuesto', 'add_item': 'Añadir', 'edit_item': 'Editar', 'shopping_mode': 'Modo Compra', 'copy': 'Copiar', 'clear': 'Borrar Comprados', 'move': 'Mover a Mañana', 'search': 'Buscar...', 'history': 'Historial', 'spending_category': 'Gastos por Categoría', 'top_picks': 'Favoritos', 'quick_add': 'Añadir Rápido', 'save': 'Guardar', 'cancel': 'Cancelar', 'language': 'Idioma', 'currency': 'Moneda', 'share': 'Compartir', 'market_mode': 'Modo Mercado', 'enable_aisle': 'Modo Pasillo', 'tax_rate': 'Tasa de Impuesto', 'change_theme': 'Cambiar Tema' }
  };

  final List<String> _notifications = ["Welcome! Long press items to Pin them."];

  List<ShoppingItem> get allItems => _items;
  DateTime get selectedDate => _selectedDate;
  bool get isDarkMode => _isDarkMode;
  Color get themeColor => _themeColor;
  List<String> get notifications => _notifications;
  List<Map<String, dynamic>> get regularItems => _regularItems;
  List<Map<String, dynamic>> get topPicks => _topPicks;
  double get dailyBudget => _dailyBudget;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  double get taxRate => _taxRate;
  bool get isGroupedByCategory => _isGroupedByCategory;
  String get currencySymbol => _currencySymbol;
  String get languageCode => _languageCode;
  bool get isMarketMode => _isMarketMode;
  int get marketInterval => _marketInterval;

  String t(String key) => _translations[_languageCode]?[key] ?? key;

  List<ShoppingItem> get purchasedItems => _items.where((i) => i.isPurchased).toList();
  // FIXED: 0.0
  double get totalLifetimeExpense => purchasedItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity)) * _currencyRate;
  double get estimatedTotal => filteredItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity)) * (1 + _taxRate) * _currencyRate;
  double get spentTotal => filteredItems.where((i) => i.isPurchased).fold(0.0, (sum, item) => sum + (item.price * item.quantity)) * (1 + _taxRate) * _currencyRate;

  Map<String, double> get categoryExpenses {
    Map<String, double> totals = {};
    for (var item in purchasedItems) {
      double cost = (item.price * item.quantity) * _currencyRate;
      totals[item.category] = (totals[item.category] ?? 0) + cost;
    }
    return totals;
  }

  List<double> get last7DaysSpending {
    List<double> dailyTotals = List.filled(7, 0.0);
    DateTime today = DateTime.now();
    for (int i = 0; i < 7; i++) {
      DateTime checkDate = today.subtract(Duration(days: 6 - i));
      var dayItems = purchasedItems.where((item) => 
        item.scheduledDate.year == checkDate.year &&
        item.scheduledDate.month == checkDate.month &&
        item.scheduledDate.day == checkDate.day
      );
      // FIXED: 0.0
      dailyTotals[i] = dayItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity)) * _currencyRate;
    }
    return dailyTotals;
  }

  ListProvider() {
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    await DatabaseHelper.instance.database; 
    _items = await DatabaseHelper.instance.getItems();
    _regularItems = await DatabaseHelper.instance.getRegularItems();
    _topPicks = await DatabaseHelper.instance.getTopFrequentItems();
    NotificationService.scheduleReminders(_items);
    notifyListeners();
  }

  List<ShoppingItem> get filteredItems {
    var result = _items.where((item) => DateUtils.isSameDay(item.scheduledDate, _selectedDate)).toList();
    if (_selectedCategoryFilter != 'All') {
      result = result.where((item) => item.category == _selectedCategoryFilter).toList();
    }

    result.sort((a, b) {
      if (a.isPurchased != b.isPurchased) {
        return a.isPurchased ? 1 : -1;
      }
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      if (_isGroupedByCategory) {
        int catCompare = a.category.compareTo(b.category);
        if (catCompare != 0) {
          return catCompare;
        }
      }
      switch (_sortMethod) {
        case SortMethod.byPriority: return b.priority.index.compareTo(a.priority.index);
        case SortMethod.byPrice: return b.price.compareTo(a.price);
        case SortMethod.defaultSort: return 0;
      }
    });
    return result;
  }

  String getShareText() {
    StringBuffer sb = StringBuffer();
    sb.writeln("🛒 *${t('app_title')}*");
    for (var item in filteredItems) {
      String check = item.isPurchased ? "✅" : "⬜";
      sb.writeln("$check ${item.name} (${item.quantity} ${item.unit})");
    }
    sb.writeln("${t('total')}: $_currencySymbol${estimatedTotal.toStringAsFixed(2)}");
    return sb.toString();
  }

  Color getDateStatusColor(DateTime date, bool isDark) {
    final items = _items.where((i) => DateUtils.isSameDay(i.scheduledDate, date)).toList();
    if (items.isEmpty) {
      return Colors.transparent;
    }
    // FIXED: withValues
    return items.every((i) => i.isPurchased) 
      ? (isDark ? Colors.green.withValues(alpha: 0.2) : Colors.green.shade100) 
      : (isDark ? _themeColor.withValues(alpha: 0.6) : _themeColor.withValues(alpha: 0.3));
  }

  void toggleTheme() { _isDarkMode = !_isDarkMode; notifyListeners(); }
  void setDate(DateTime date) { _selectedDate = date; notifyListeners(); }
  void setSortMethod(SortMethod method) { _sortMethod = method; notifyListeners(); }
  void setCategoryFilter(String category) { _selectedCategoryFilter = category; notifyListeners(); }
  void setDailyBudget(double amount) { _dailyBudget = amount; notifyListeners(); }
  void setThemeColor(Color color) { _themeColor = color; notifyListeners(); }
  void setTaxRate(double rate) { _taxRate = rate; notifyListeners(); }
  void toggleGrouping() { _isGroupedByCategory = !_isGroupedByCategory; notifyListeners(); }
  void setLanguage(String code) { _languageCode = code; notifyListeners(); }
  void setCurrency(String symbol, double rate) { _currencySymbol = symbol; _currencyRate = rate; notifyListeners(); }

  void toggleMarketMode(bool enable) {
    _isMarketMode = enable;
    _marketTimer?.cancel();
    if (_isMarketMode) {
      _startMarketTimer();
      _notifications.insert(0, "Market Mode ON: Alerts every $_marketInterval min");
    } else {
      _notifications.insert(0, "Market Mode OFF");
    }
    notifyListeners();
  }

  void setMarketInterval(int minutes) {
    _marketInterval = minutes;
    if (_isMarketMode) {
      toggleMarketMode(true); 
    } else {
      notifyListeners();
    }
  }

  void _startMarketTimer() {
    _marketTimer = Timer.periodic(Duration(minutes: _marketInterval), (timer) {
      final unbought = filteredItems.where((i) => !i.isPurchased).toList();
      if (unbought.isNotEmpty) {
        String names = unbought.take(3).map((i) => i.name).join(", ");
        if (unbought.length > 3) names += " +${unbought.length - 3} more";
        NotificationService.showMarketNotification(names);
      } else {
        toggleMarketMode(false);
      }
    });
  }

  Future<Map<String, dynamic>?> predictPrice(String name) async => await DatabaseHelper.instance.getLastItemDetails(name);

  Future<void> movePendingToNextDay() async {
    final pending = filteredItems.where((i) => !i.isPurchased).toList();
    if (pending.isEmpty) return;
    final nextDay = _selectedDate.add(const Duration(days: 1));
    for (var item in pending) {
      final updated = item.copyWith(scheduledDate: nextDay);
      await DatabaseHelper.instance.updateItem(updated);
      int index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) _items[index] = updated;
    }
    _notifications.insert(0, "Moved ${pending.length} items to tomorrow.");
    NotificationService.scheduleReminders(_items);
    notifyListeners();
  }

  Future<void> deletePurchasedItems() async {
    final purchased = filteredItems.where((i) => i.isPurchased).toList();
    if (purchased.isEmpty) return;
    for (var item in purchased) {
      await DatabaseHelper.instance.deleteItem(item.id);
      _items.removeWhere((i) => i.id == item.id);
    }
    _notifications.insert(0, "Cleared ${purchased.length} items.");
    NotificationService.scheduleReminders(_items);
    notifyListeners();
  }

  Future<void> uncheckAllItems() async {
    final purchased = filteredItems.where((i) => i.isPurchased).toList();
    if (purchased.isEmpty) return;
    for (var item in purchased) {
      final updated = item.copyWith(isPurchased: false);
      await DatabaseHelper.instance.updateItem(updated);
      int index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) _items[index] = updated;
    }
    notifyListeners();
  }

  void togglePin(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      final updated = _items[index].copyWith(isPinned: !_items[index].isPinned);
      await DatabaseHelper.instance.updateItem(updated);
      _items[index] = updated;
      notifyListeners();
    }
  }

  void addItem(ShoppingItem item) async {
    try {
      await DatabaseHelper.instance.insertItem(item);
      _items.add(item);
      _notifications.insert(0, "Added '${item.name}'");
      _topPicks = await DatabaseHelper.instance.getTopFrequentItems();
      NotificationService.scheduleReminders(_items);
      notifyListeners();
    } catch (e) {
      _notifications.insert(0, "Error adding item.");
      notifyListeners();
    }
  }

  void updateItem(ShoppingItem item) async {
    await DatabaseHelper.instance.updateItem(item);
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) { _items[index] = item; notifyListeners(); }
  }

  void togglePurchased(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      ShoppingItem item = _items[index];
      if (!item.isPurchased && item.repeat != 'None') {
        DateTime nextDate = item.scheduledDate;
        if (item.repeat == 'Daily') nextDate = nextDate.add(const Duration(days: 1));
        if (item.repeat == 'Weekly') nextDate = nextDate.add(const Duration(days: 7));
        if (item.repeat == 'Monthly') nextDate = nextDate.add(const Duration(days: 30));
        
        final nextItem = ShoppingItem(id: DateTime.now().toString(), name: item.name, category: item.category, quantity: item.quantity, unit: item.unit, repeat: item.repeat, price: item.price, priority: item.priority, scheduledDate: nextDate);
        await DatabaseHelper.instance.insertItem(nextItem);
        _items.add(nextItem);
        _notifications.insert(0, "Recurring: Added ${item.name}");
      }
      final updated = item.copyWith(isPurchased: !item.isPurchased);
      await DatabaseHelper.instance.updateItem(updated);
      _items[index] = updated;
      notifyListeners();
    }
  }

  void deleteItem(String id) async {
    await DatabaseHelper.instance.deleteItem(id);
    _items.removeWhere((i) => i.id == id);
    _notifications.insert(0, "Item deleted.");
    NotificationService.scheduleReminders(_items);
    notifyListeners();
  }

  void restoreItem(ShoppingItem item) async {
    await DatabaseHelper.instance.insertItem(item);
    _items.add(item);
    notifyListeners();
  }

  void addRegularItem(String name, double price) async {
    await DatabaseHelper.instance.insertRegularItem(name, price);
    _regularItems = await DatabaseHelper.instance.getRegularItems();
    notifyListeners();
  }

  void deleteRegularItem(String id) async {
    await DatabaseHelper.instance.deleteRegularItem(id);
    _regularItems = await DatabaseHelper.instance.getRegularItems();
    notifyListeners();
  }
}