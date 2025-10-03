import 'dart:async';
import 'package:fiverr/features/auth/presentation/widgets/login_form.dart';
import 'package:fiverr/features/categories/presentation/screens/categories_page.dart';
import 'package:fiverr/features/job_detail/presentation/screens/job_detail_screen.dart';
import 'package:fiverr/features/profile/presentation/screens/profile_screen.dart';
import 'package:fiverr/shared/avatar_store.dart';
import 'package:flutter/material.dart';

import '../../../home/data/job_repository.dart';
import '../../../home/domain/popular_models.dart';
import '../widgets/search_field.dart';
import '../widgets/popular_card.dart';
import '../widgets/job_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomePage> {
  final _repo = JobRepository();

  // Search state
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isLoading = false;
  List<dynamic> _jobs = [];

  // Popular Services
  final List<PopularKeyword> _popularKeywords = const [
    PopularKeyword(label: 'Logo Design', keyword: 'logo'),
    PopularKeyword(label: 'AI Artists', keyword: 'ai'),
    PopularKeyword(label: 'Web Design', keyword: 'web design'),
    PopularKeyword(label: 'SEO', keyword: 'seo'),
    PopularKeyword(label: 'Mobile App', keyword: 'mobile'),
    PopularKeyword(label: 'Illustration', keyword: 'illustration'),
  ];

  final List<PopularItem> _popularItems = [];
  bool _popularLoading = true;

  @override
  void initState() {
    super.initState();
    AvatarStore.load();
    _loadPopular();
    WidgetsBinding.instance.addPostFrameCallback((_) => hideKeyboard());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Search handlers
  Future<void> _searchJobs(String keyword) async {
    if (!mounted) return;
    if (keyword.trim().isEmpty) {
      setState(() => _jobs = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final results = await _repo.searchJobs(keyword.trim());
      if (!mounted) return;
      setState(() => _jobs = results);
    } catch (_) {
      if (!mounted) return;
      setState(() => _jobs = []);
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchJobs(_searchController.text);
    });
  }

  String _randomImageFor(String seed, {int w = 400, int h = 250}) {
    // seed giúp ảnh ổn định theo nhãn/id (mỗi seed 1 ảnh), đổi seed sẽ đổi ảnh
    final s = Uri.encodeComponent(
      seed.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : seed,
    );
    return "https://picsum.photos/seed/$s/$w/$h";
  }

  // Popular loaders
  Future<void> _loadPopular() async {
    setState(() {
      _popularLoading = true;
      _popularItems.clear();
    });

    try {
      for (final k in _popularKeywords) {
        final list = await _repo.searchJobs(k.keyword);
        if (list.isNotEmpty) {
          final jobWrap = list.first as Map<String, dynamic>;
          final cv = jobWrap["congViec"] as Map<String, dynamic>? ?? {};
          final raw = (cv["hinhAnh"] ?? "").toString();

          // ảnh cuối cùng dùng để hiển thị
          final finalImg = (raw.startsWith("http") && raw.isNotEmpty)
              ? raw
              : _randomImageFor(k.label, w: 240, h: 160);

          _popularItems.add(
            PopularItem(
              label: k.label,
              keyword: k.keyword,
              imageUrl: finalImg,
              jobWrap: jobWrap,
            ),
          );
        } else {
          _popularItems.add(
            PopularItem(
              label: k.label,
              keyword: k.keyword,
              imageUrl: _randomImageFor(
                k.label,
                w: 240,
                h: 160,
              ), // 🔁 fallback random
              jobWrap: null,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Load popular error: $e");
    } finally {
      if (!mounted) return;
      setState(() => _popularLoading = false);
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "fiverr",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: showSearchDialog,
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<String?>(
            valueListenable: AvatarStore.avatar,
            builder: (context, url, _) {
              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border:
                        Border.all(color: const Color(0xFFE0E0E0), width: 1),
                  ),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: (url != null && url.isNotEmpty)
                        ? NetworkImage(url)
                        : null,
                    child: (url == null || url.isEmpty)
                        ? const Icon(Icons.person,
                            size: 18, color: Colors.black54)
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        // ✅ Gradient giống login/signup
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
            onRefresh: () async {
              await _loadPopular();
              if (_searchController.text.trim().isNotEmpty) {
                await _searchJobs(_searchController.text);
              }
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: SearchField(
                      controller: _searchController,
                      autoFocus: false, // 👈 phòng hờ
                      onChanged: null, // không cần debounce ở đây
                      onSubmitted: null,
                    ),
                  ),
                ),

                // Popular header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                    child: Row(
                      children: [
                        Text(
                          "Popular Services",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CategoriesPage(),
                              ),
                            );
                          },
                          child: const Text("See All"),
                        ),
                      ],
                    ),
                  ),
                ),

                // Popular list
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 110,
                    child: _popularLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            scrollDirection: Axis.horizontal,
                            itemCount: _popularItems.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, i) {
                              final item = _popularItems[i];
                              return PopularCard(
                                label: item.label,
                                imageUrl: item.imageUrl,
                                onTap: () {
                                  _searchController.text = item.keyword;
                                  _onSearchChanged();
                                },
                              );
                            },
                          ),
                  ),
                ),

                // Explore / Results
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      _searchController.text.trim().isEmpty
                          ? "Explore beautiful work,"
                          : "Search results",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),

                if (_isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_jobs.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ảnh random đẹp + bo góc + shadow
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              "https://picsum.photos/400/250?random",
                              width: 260,
                              height: 180,
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, progress) =>
                                  progress == null
                                      ? child
                                      : const SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                              errorBuilder: (_, __, ___) => Container(
                                width: 260,
                                height: 180,
                                color: Colors.grey[300],
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "No results found.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Try a different keyword or explore categories",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final wrap = _jobs[index];
                        final job = wrap["congViec"] ?? {};
                        return JobTile(
                          image: job["hinhAnh"] ?? "",
                          title: job["tenCongViec"] ?? "Không có tiêu đề",
                          price: job["giaTien"],
                          rating: job["saoCongViec"],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    JobDetailScreen(maCongViec: job["id"]),
                              ),
                            );
                          },
                        );
                      }, childCount: _jobs.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 240,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tìm công việc"),
          content: SearchField(
            controller: _searchController,
            hintText: "Nhập từ khoá…",
            autoFocus: false,
            onChanged: (_) => _onSearchChanged(),
            onSubmitted: (v) {
              Navigator.pop(context);
              _searchJobs(v);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Đóng"),
            ),
          ],
        );
      },
    );
  }
}
