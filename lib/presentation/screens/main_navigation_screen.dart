import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../themes/romantic_themes.dart';
import '../../business_logic/providers/theme_provider.dart';
import 'home_screen.dart';
import 'todo_list_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TodoListScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: '记录',
    ),
    NavigationItem(
      icon: Icons.checklist_outlined,
      selectedIcon: Icons.checklist,
      label: '待办',
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: '分析',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: '设置',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          selectedItemColor: romanticTheme.primary,
          unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items: _navigationItems.map((item) {
            final isSelected = _navigationItems.indexOf(item) == _selectedIndex;
            return BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  size: 24,
                ),
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}