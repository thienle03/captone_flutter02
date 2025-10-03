import 'package:fiverr/features/categories/data/category_repository.dart';
import 'package:fiverr/features/categories/presentation/screens/interest_page.dart';
import 'package:fiverr/features/categories/presentation/widgets/category_list_title.dart';
import 'package:flutter/material.dart';
import 'package:fiverr/features/search/presentation/screens/search_page.dart';
import '../widgets/tab_header.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  bool _loading = true;
  String? _error;
  List<dynamic> _menuLoai = [];

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await CategoryRepository().fetchMenuLoai();
      if (mounted) setState(() => _menuLoai = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // 👈 cho nền lên full màn hình
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 👈 trong suốt để thấy gradient
        elevation: 0,
        title: const Text(
          "Categories",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchPage(initialKeyword: ''),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: TabHeader(
            onTapInterests: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InterestsPage()),
              );
            },
          ),
        ),
      ),
      body: Container(
        // ✅ Gradient nền
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 182, 235, 204),
              Color.fromARGB(255, 233, 241, 240),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchMenu,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(child: Text("Lỗi tải dữ liệu: $_error")),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: _fetchMenu,
                              child: const Text("Thử lại"),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        itemCount: _menuLoai.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 5), // khoảng cách
                        itemBuilder: (context, i) {
                          final loai =
                              (_menuLoai[i] ?? {}) as Map<String, dynamic>;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white, // 👈 nền trắng cho mỗi item
                              borderRadius:
                                  BorderRadius.circular(12), // 👈 bo góc
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(
                                  color: Colors.green.shade100,
                                  width: 1), // 👈 viền
                            ),
                            child: CategoryListTile(loai: loai, index: i),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}
