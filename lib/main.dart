import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'list_provider.dart';
import 'item_model.dart';
import 'notification_service.dart';
import 'regular_items_screen.dart';

const Map<String, String> magicEmojis = {
  'milk': '🥛',
  'bread': '🍞',
  'egg': '🥚',
  'banana': '🍌',
  'apple': '🍎',
  'carrot': '🥕',
  'pizza': '🍕',
  'burger': '🍔',
  'chicken': '🍗',
  'fish': '🐟',
  'meat': '🥩',
  'cheese': '🧀',
  'rice': '🍚',
  'pasta': '🍝',
  'oil': '🛢️',
  'soap': '🧼',
  'shampoo': '🧴',
  'brush': '🪥',
  'paper': '🧻',
  'water': '💧',
  'coffee': '☕',
  'tea': '🫖',
  'juice': '🧃',
  'soda': '🥤',
  'beer': '🍺',
  'wine': '🍷',
  'cake': '🍰',
  'cookie': '🍪',
  'chocolate': '🍫',
  'ice cream': '🍦',
  'tomato': '🍅',
  'potato': '🥔',
  'onion': '🧅',
  'garlic': '🧄',
  'salt': '🧂',
  'pepper': '🌶️',
  'sugar': '🍚',
  'honey': '🍯',
  'yogurt': '🥣',
  'fruit': '🍇',
  'dog': '🐶',
  'cat': '🐱',
  'baby': '👶',
  'diaper': '👶',
  'book': '📚',
  'pen': '🖊️',
  'phone': '📱',
  'charger': '🔌',
  'battery': '🔋',
  'light': '💡',
};

String getEmoji(String name) {
  String lower = name.toLowerCase();
  for (var key in magicEmojis.keys) {
    if (lower.contains(key)) return magicEmojis[key]!;
  }
  return '🛒';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ListProvider(),
      child: const ShoppingApp(),
    ),
  );
}

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final listProvider = Provider.of<ListProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: listProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // FIXED: Removed cardTheme entirely to prevent type error
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: listProvider.themeColor,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: listProvider.themeColor,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const ShoppingListScreen(),
    const ExpensesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<ListProvider>(context);
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.list),
            label: lp.t('shop'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.pie_chart),
            label: lp.t('expenses'),
          ),
        ],
      ),
    );
  }
}

// ------------------- TAB 1: SHOPPING LIST -------------------
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});
  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  String searchQuery = "";
  late Timer _clockTimer;
  String _currentTime = "";

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted)
        setState(
          () => _currentTime = DateFormat(
            'EEE, MMM d • hh:mm a',
          ).format(DateTime.now()),
        );
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  bool _isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(date.year, date.month, date.day).isAfter(today);
  }

  void _showNotifs(BuildContext context) {
    final logs = Provider.of<ListProvider>(
      context,
      listen: false,
    ).notifications;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Notifications"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: logs.length,
            itemBuilder: (c, i) => ListTile(title: Text(logs[i])),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _copyList(ListProvider provider) {
    Clipboard.setData(ClipboardData(text: provider.getShareText()));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("${provider.t('share')} copied!")));
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final lp = Provider.of<ListProvider>(context);
        final budgetCtrl = TextEditingController(
          text: lp.dailyBudget.toString(),
        );
        final taxCtrl = TextEditingController(
          text: (lp.taxRate * 100).toString(),
        );

        return AlertDialog(
          title: Text(lp.t('settings')),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ExpansionTile(
                  title: Text("${lp.t('language')} & ${lp.t('currency')}"),
                  leading: const Icon(Icons.language),
                  children: [
                    ListTile(
                      title: Text(lp.t('language')),
                      trailing: DropdownButton<String>(
                        value: lp.languageCode,
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text("English")),
                          DropdownMenuItem(value: 'hi', child: Text("हिन्दी")),
                          DropdownMenuItem(value: 'es', child: Text("Español")),
                        ],
                        onChanged: (v) {
                          lp.setLanguage(v!);
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(lp.t('currency')),
                      trailing: DropdownButton<String>(
                        value: lp.currencySymbol,
                        items: const [
                          DropdownMenuItem(
                            value: '\$',
                            child: Text("USD (\$)"),
                          ),
                          DropdownMenuItem(value: '₹', child: Text("INR (₹)")),
                          DropdownMenuItem(value: '€', child: Text("EUR (€)")),
                        ],
                        onChanged: (v) {
                          double rate = 1.0;
                          if (v == '₹') {
                            rate = 83.0;
                          } else if (v == '€') {
                            rate = 0.92;
                          }
                          lp.setCurrency(v!, rate);
                        },
                      ),
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Text("${lp.t('budget')} & ${lp.t('tax_rate')}"),
                  leading: const Icon(Icons.attach_money),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: budgetCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: lp.t('budget'),
                          prefixText: "${lp.currencySymbol} ",
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (v) {
                          if (double.tryParse(v) != null) {
                            lp.setDailyBudget(double.parse(v));
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: taxCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: lp.t('tax_rate'),
                          suffixText: "%",
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (v) {
                          if (double.tryParse(v) != null) {
                            lp.setTaxRate((double.parse(v)) / 100);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  title: Text(lp.t('enable_aisle')),
                  secondary: const Icon(Icons.shelves),
                  value: lp.isGroupedByCategory,
                  onChanged: (_) => lp.toggleGrouping(),
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: Text(lp.t('change_theme')),
                  onTap: () => _showThemePicker(context),
                ),
                SwitchListTile(
                  title: Text(lp.t('market_mode')),
                  subtitle: Text(
                    lp.isMarketMode ? "On (${lp.marketInterval} min)" : "Off",
                  ),
                  secondary: const Icon(Icons.shopping_bag_outlined),
                  value: lp.isMarketMode,
                  onChanged: (val) => lp.toggleMarketMode(val),
                ),
                if (lp.isMarketMode)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text("Interval: "),
                        Expanded(
                          child: Slider(
                            value: lp.marketInterval.toDouble(),
                            min: 1,
                            max: 60,
                            divisions: 59,
                            label: "${lp.marketInterval} min",
                            onChanged: (val) =>
                                lp.setMarketInterval(val.toInt()),
                          ),
                        ),
                        Text("${lp.marketInterval}m"),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }

  void _showThemePicker(BuildContext context) {
    final colors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Choose Theme"),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colors
              .map(
                (c) => GestureDetector(
                  onTap: () {
                    Provider.of<ListProvider>(
                      context,
                      listen: false,
                    ).setThemeColor(c);
                    Navigator.pop(ctx);
                  },
                  child: CircleAvatar(backgroundColor: c, radius: 20),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showPriceComparator(BuildContext context) {
    final p1 = TextEditingController();
    final q1 = TextEditingController();
    final p2 = TextEditingController();
    final q2 = TextEditingController();
    String result = "";
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Price Compare"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: p1,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Price A"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: q1,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Qty A"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: p2,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Price B"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: q2,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Qty B"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    double pr1 = double.tryParse(p1.text) ?? 0;
                    double qt1 = double.tryParse(q1.text) ?? 0;
                    double pr2 = double.tryParse(p2.text) ?? 0;
                    double qt2 = double.tryParse(q2.text) ?? 0;
                    if (qt1 > 0 && qt2 > 0) {
                      double u1 = pr1 / qt1;
                      double u2 = pr2 / qt2;
                      setState(
                        () => result = u1 < u2
                            ? "A is cheaper!"
                            : u2 < u1
                            ? "B is cheaper!"
                            : "Same Value",
                      );
                    }
                  },
                  child: const Text("Compare"),
                ),
                const SizedBox(height: 10),
                Text(
                  result,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<ListProvider>(context);
    final isDark = lp.isDarkMode;
    final displayItems = lp.filteredItems
        .where((i) => i.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    final regularItems = lp.regularItems;

    double spent = lp.spentTotal;
    double budget = lp.dailyBudget;
    double estimated = lp.estimatedTotal;
    double progress = (budget > 0) ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    Color progressColor = spent > budget ? Colors.red : Colors.green;
    // FIXED: Used colorScheme.primaryContainer correctly
    Color headerColor = estimated > budget
        ? Colors.red.withValues(alpha: 0.1)
        : Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    String taxLabel = lp.taxRate > 0
        ? " (+${(lp.taxRate * 100).toInt()}% Tax)"
        : "";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              lp.t('app_title'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _copyList(lp),
              ),
              IconButton(
                icon: const Icon(Icons.visibility),
                tooltip: lp.t('shopping_mode'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShoppingModeScreen()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_active),
                onPressed: () => _showNotifs(context),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showSettingsDialog(context),
              ),

              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (val) {
                  if (val == 'Copy') _copyList(lp);
                  if (val == 'Move') lp.movePendingToNextDay();
                  if (val == 'Clear') lp.deletePurchasedItems();
                  if (val == 'Uncheck') lp.uncheckAllItems();
                  if (val == 'Compare') _showPriceComparator(context);
                  if (val == 'Priority')
                    lp.setSortMethod(SortMethod.byPriority);
                  if (val == 'Price') lp.setSortMethod(SortMethod.byPrice);
                  if (val == 'Default')
                    lp.setSortMethod(SortMethod.defaultSort);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'Copy', child: Text(lp.t('copy'))),
                  PopupMenuItem(value: 'Clear', child: Text(lp.t('clear'))),
                  PopupMenuItem(
                    value: 'Uncheck',
                    child: const Text("Reset List"),
                  ),
                  PopupMenuItem(value: 'Move', child: Text(lp.t('move'))),
                  const PopupMenuItem(
                    value: 'Compare',
                    child: Text("Price Compare"),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'Default',
                    child: Text("Sort: Default"),
                  ),
                  const PopupMenuItem(
                    value: 'Priority',
                    child: Text("Sort: Priority"),
                  ),
                  const PopupMenuItem(
                    value: 'Price',
                    child: Text("Sort: Price"),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => lp.toggleTheme(),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () async {
                  DateTime? p = await showDatePicker(
                    context: context,
                    initialDate: lp.selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (p != null) {
                    lp.setDate(p);
                  }
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currentTime,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${lp.t('spent')}: ${lp.currencySymbol}${spent.toStringAsFixed(0)} / ${lp.currencySymbol}${budget.toStringAsFixed(0)}$taxLabel",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: estimated > budget ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    color: progressColor,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  if (estimated > budget)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "⚠️ Over budget by ${lp.currencySymbol}${(estimated - budget).toStringAsFixed(2)}!",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 60,
                itemBuilder: (context, index) {
                  DateTime date = DateTime.now().add(Duration(days: index - 5));
                  bool isSelected = DateUtils.isSameDay(date, lp.selectedDate);
                  return GestureDetector(
                    onTap: () => lp.setDate(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 60,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : lp.getDateStatusColor(date, isDark),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${date.day}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            DateFormat('E').format(date),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchBar(
                    elevation: const WidgetStatePropertyAll(1),
                    hintText: lp.t('search'),
                    leading: const Icon(Icons.search),
                    onChanged: (v) => setState(() => searchQuery = v),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children:
                        [
                          'All',
                          'Grocery',
                          'Electronics',
                          'Personal',
                          'Home',
                          'Pharmacy',
                        ].map((cat) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat),
                              selected: lp.selectedCategoryFilter == cat,
                              onSelected: (_) => lp.setCategoryFilter(cat),
                              selectedColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),

          if (regularItems.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 0, 8),
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: regularItems.length,
                    itemBuilder: (context, index) {
                      final r = regularItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: Text(getEmoji(r['name'])),
                          label: Text("${r['name']}"),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            lp.addItem(
                              ShoppingItem(
                                id: DateTime.now().toString(),
                                name: r['name'],
                                category: "Grocery",
                                price: (r['price'] as num).toDouble(),
                                scheduledDate: lp.selectedDate,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= displayItems.length) {
                return null;
              }
              final item = displayItems[index];
              bool isFuture = _isFutureDate(item.scheduledDate);

              bool showHeader = false;
              if (lp.isGroupedByCategory) {
                if (index == 0 ||
                    item.category != displayItems[index - 1].category) {
                  showHeader = true;
                }
              }

              String emoji = getEmoji(item.name);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 0, 4),
                      child: Text(
                        item.category.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  Dismissible(
                    key: Key(item.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      lp.deleteItem(item.id);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${item.name} deleted"),
                          action: SnackBarAction(
                            label: "UNDO",
                            onPressed: () => lp.restoreItem(item),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: item.isPurchased
                          ? (isDark ? Colors.white10 : Colors.grey.shade100)
                          : null,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            decoration: item.isPurchased
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "${lp.currencySymbol}${item.price} • ${item.category}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.repeat != 'None')
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.repeat,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                              ),
                            IconButton(
                              icon: Icon(
                                item.isPinned
                                    ? Icons.push_pin
                                    : Icons.push_pin_outlined,
                                color: item.isPinned ? Colors.red : Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => lp.togglePin(item.id),
                            ),
                            Checkbox(
                              value: item.isPurchased,
                              onChanged: (v) {
                                if (isFuture) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Cannot mark future items!",
                                      ),
                                    ),
                                  );
                                } else {
                                  HapticFeedback.lightImpact();
                                  lp.togglePurchased(item.id);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_note),
                              onPressed: () =>
                                  _showSheet(context, existingItem: item),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }, childCount: displayItems.length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSheet(context),
        label: Text(lp.t('add_item')),
        icon: const Icon(Icons.add_shopping_cart),
      ),
    );
  }

  void _showSheet(BuildContext context, {ShoppingItem? existingItem}) {
    final nameC = TextEditingController(text: existingItem?.name ?? "");
    final noteC = TextEditingController(text: existingItem?.notes ?? "");
    final priceC = TextEditingController(
      text: existingItem?.price.toString() ?? "",
    );
    String cat = existingItem?.category ?? 'Grocery';
    Priority pri = existingItem?.priority ?? Priority.medium;
    double qty = existingItem?.quantity ?? 1;
    String unit = existingItem?.unit ?? 'pcs';
    String repeat = existingItem?.repeat ?? 'None';
    DateTime date =
        existingItem?.scheduledDate ??
        Provider.of<ListProvider>(context, listen: false).selectedDate;
    final regulars = Provider.of<ListProvider>(
      context,
      listen: false,
    ).regularItems;
    final topPicks = Provider.of<ListProvider>(context, listen: false).topPicks;
    final lp = Provider.of<ListProvider>(context, listen: false);

    nameC.addListener(() async {
      if (nameC.text.length > 2 && existingItem == null) {
        final prediction = await lp.predictPrice(nameC.text);
        if (prediction != null && priceC.text.isEmpty) {
          priceC.text = prediction['price'].toString();
        }
      }
    });

    String title = existingItem == null ? lp.t('add_item') : lp.t('edit_item');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (existingItem == null) ...[
                const SizedBox(height: 12),
                if (topPicks.isNotEmpty) ...[
                  Text(
                    "${lp.t('top_picks')}:",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: topPicks
                          .map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                avatar: Text(getEmoji(r['name'])),
                                label: Text("${r['name']}"),
                                onPressed: () {
                                  nameC.text = r['name'];
                                  if (r['price'] != null) {
                                    priceC.text = r['price'].toString();
                                  }
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  "${lp.t('quick_add')}:",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: regulars
                        .map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              avatar: Text(getEmoji(r['name'])),
                              label: Text("${r['name']} (\$${r['price']})"),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                lp.addItem(
                                  ShoppingItem(
                                    id: DateTime.now().toString(),
                                    name: r['name'],
                                    category: "Grocery",
                                    price: (r['price'] as num).toDouble(),
                                    scheduledDate: date,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Divider(),
              ],
              TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: priceC,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Price",
                  prefixText: "${lp.currencySymbol} ",
                ),
              ),
              TextField(
                controller: noteC,
                decoration: const InputDecoration(labelText: "Notes"),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () =>
                            setState(() => qty > 0.5 ? qty -= 0.5 : null),
                      ),
                      Text(
                        qty % 1 == 0 ? qty.toInt().toString() : qty.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => qty += 0.5),
                      ),
                    ],
                  ),
                  DropdownButton<String>(
                    value: unit,
                    items: ['pcs', 'kg', 'g', 'L', 'mL', 'pkt', 'box']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (val) => setState(() => unit = val!),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Repeat:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: repeat,
                    items: ['None', 'Daily', 'Weekly', 'Monthly']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (val) => setState(() => repeat = val!),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: Priority.values
                      .map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(p.name),
                            selected: pri == p,
                            onSelected: (_) => setState(() => pri = p),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      ['Grocery', 'Electronics', 'Personal', 'Home', 'Pharmacy']
                          .map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(c),
                                selected: cat == c,
                                onSelected: (_) => setState(() => cat = c),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameC.text.isNotEmpty) {
                      final item = ShoppingItem(
                        id: existingItem?.id ?? DateTime.now().toString(),
                        name: nameC.text,
                        category: cat,
                        quantity: qty,
                        unit: unit,
                        repeat: repeat,
                        notes: noteC.text,
                        price: double.tryParse(priceC.text) ?? 0,
                        priority: pri,
                        scheduledDate: date,
                        isPurchased: existingItem?.isPurchased ?? false,
                      );
                      existingItem == null
                          ? lp.addItem(item)
                          : lp.updateItem(item);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(lp.t('save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------- SHOPPING MODE SCREEN -------------------
class ShoppingModeScreen extends StatefulWidget {
  const ShoppingModeScreen({super.key});
  @override
  State<ShoppingModeScreen> createState() => _ShoppingModeScreenState();
}

class _ShoppingModeScreenState extends State<ShoppingModeScreen> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final d = _stopwatch.elapsed;
    return "${d.inMinutes.toString().padLeft(2, "0")}:${d.inSeconds.remainder(60).toString().padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<ListProvider>(context);
    final items = lp.filteredItems.where((i) => !i.isPurchased).toList();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(lp.t('shopping_mode')),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, size: 16),
                  const SizedBox(width: 4),
                  Text(_formattedTime),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                "All items purchased!",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${item.quantity} ${item.unit} • ${item.category}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    value: item.isPurchased,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      lp.togglePurchased(item.id);
                    },
                    secondary: Text(
                      getEmoji(item.name),
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ------------------- TAB 2: EXPENSES -------------------
class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<ListProvider>(context);
    final stats = lp.categoryExpenses;
    final weeklyData = lp.last7DaysSpending;
    double maxSpend = weeklyData.reduce(
      (curr, next) => curr > next ? curr : next,
    );
    if (maxSpend == 0) {
      maxSpend = 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(lp.t('expenses')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegularItemsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(lp.t('total')),
                  Text(
                    "${lp.currencySymbol}${lp.totalLifetimeExpense.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Last 7 Days",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // FIX: REDUCED HEIGHT MULTIPLIER TO 80 TO PREVENT OVERFLOW
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weeklyData.asMap().entries.map((e) {
                double height = (e.value / maxSpend) * 80;
                String dayLabel = DateFormat(
                  'E',
                ).format(DateTime.now().subtract(Duration(days: 6 - e.key)));
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "${e.value.toInt()}",
                      style: const TextStyle(fontSize: 10),
                    ),
                    Container(
                      width: 20,
                      height: height < 5 ? 5 : height,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(dayLabel, style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            lp.t('spending_category'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...stats.entries.map(
            (e) => Column(
              children: [
                ListTile(
                  title: Text(e.key),
                  trailing: Text(
                    "${lp.currencySymbol}${e.value.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  leading: Icon(
                    Icons.pie_chart,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Divider(height: 1),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            lp.t('history'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...lp.purchasedItems.map(
            (i) => Card(
              child: ListTile(
                leading: const Icon(Icons.receipt, color: Colors.green),
                title: Text(i.name),
                subtitle: Text(DateFormat('MM/dd').format(i.scheduledDate)),
                trailing: Text(
                  "${lp.currencySymbol}${(i.price * i.quantity).toStringAsFixed(2)}",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
