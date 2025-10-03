import 'package:fiverr/features/categories/presentation/screens/categories_page.dart';
import 'package:fiverr/features/home/presentation/screens/home_page.dart';
import 'package:fiverr/features/jobs/presentation/screens/jobs_screen.dart';
import 'package:fiverr/features/profile/presentation/screens/profile_screen.dart';
import 'package:fiverr/features/search/presentation/screens/search_page.dart';
import 'package:fiverr/features/main/widgets/main_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int? _userId;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt("userId");
    });
  }

  void _onTabChanged(int index) {
    if (_selectedIndex == index) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomePage(),
      JobsScreen(),
      const SearchPage(initialKeyword: ''),
      const CategoriesPage(),
      ProfilePage(userId: _userId),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),

      // gọi widget điều hướng tách riêng
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FancySearchFab(
        selected: _selectedIndex == 2,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus(); // ⬅️ tắt bàn phím
          _onTabChanged(2);
        },
      ),
      bottomNavigationBar: FancyBottomBar(
        currentIndex: _selectedIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
