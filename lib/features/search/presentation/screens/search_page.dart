import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fiverr/features/categories/presentation/screens/categories_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/search_repository.dart';
import '../widgets/filter_pill.dart';
import '../widgets/job_list_tile.dart';

class SearchPage extends StatefulWidget {
  final String initialKeyword;
  const SearchPage({super.key, required this.initialKeyword});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _repo = SearchRepository();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  bool _isLoading = false;
  List<dynamic> _jobs = [];
  List<dynamic> _menuLoai = [];
  List<String> _suggestTags = [];
  final Set<int> _favIds = {};
  List<Map<String, dynamic>> _favJobs = [];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialKeyword;
    _loadFavs();
    _fetchLoaiCongViec();
    if (widget.initialKeyword.trim().isNotEmpty) {
      _searchJobs(widget.initialKeyword);
    }
  }

  Future<void> _loadFavs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('fav_jobs');
    if (raw != null) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _favJobs = list;
      _favIds
        ..clear()
        ..addAll(list.map((e) => (e['id'] as num).toInt()));
      if (mounted) setState(() {});
    }
  }

  Future<void> _saveFavs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fav_jobs', jsonEncode(_favJobs));
  }

  void _toggleFav(Map<String, dynamic> job) {
    final id = (job['id'] as num?)?.toInt();
    if (id == null) return;
    final idx = _favJobs.indexWhere((e) => (e['id'] as num?)?.toInt() == id);
    if (idx >= 0) {
      _favJobs.removeAt(idx);
      _favIds.remove(id);
    } else {
      _favJobs.add(job);
      _favIds.add(id);
    }
    _saveFavs();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchLoaiCongViec() async {
    try {
      final menu = await _repo.fetchLoaiCongViec();
      if (!mounted) return;
      setState(() {
        _menuLoai = menu;
        _suggestTags = _buildSuggestTags(menu);
      });
    } catch (e) {
      debugPrint("Fetch menu error: $e");
    }
  }

  List<String> _buildSuggestTags(List<dynamic> menu) {
    final set = <String>{};
    for (final loai in menu) {
      final tenLoai = (loai?["tenLoaiCongViec"] ?? "").toString().trim();
      if (tenLoai.isNotEmpty) set.add(tenLoai);
      final dsNhom = (loai?["dsNhomChiTietLoai"] ?? []) as List<dynamic>;
      for (final nhom in dsNhom) {
        final tenNhom = (nhom?["tenNhom"] ?? "").toString().trim();
        if (tenNhom.isNotEmpty) set.add(tenNhom);
        final dsCT = (nhom?["dsChiTietLoai"] ?? []) as List<dynamic>;
        for (final ct in dsCT) {
          final name = (ct?["tenChiTiet"] ?? "")
              .toString()
              .replaceAll("\r", "")
              .replaceAll("\n", "")
              .trim();
          if (name.isNotEmpty) set.add(name);
          if (set.length >= 30) break;
        }
        if (set.length >= 30) break;
      }
      if (set.length >= 30) break;
    }
    if (set.isEmpty) {
      set.addAll(
          ["Graphic Design", "Website Design", "Logo", "SEO", "App Design"]);
    }
    return set.toList();
  }

  Future<void> _searchJobs(String keyword) async {
    final k = keyword.trim();
    if (k.isEmpty) {
      setState(() => _jobs = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final list = await _repo.searchJobs(k);
      if (!mounted) return;
      setState(() => _jobs = list);
    } catch (e) {
      debugPrint("Search error: $e");
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
      _searchJobs(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: const BackButton(),
          title: TextField(
            controller: _controller,
            autofocus: widget.initialKeyword.isEmpty, // chỉ auto nếu trống
            decoration: const InputDecoration(
              hintText: " Search job...",
              border: InputBorder.none,
            ),
            onChanged: (_) => _onSearchChanged(),
            onSubmitted: (v) => _searchJobs(v),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                _searchJobs("");
                FocusScope.of(context).unfocus();
              },
            ),
          ],
        ),
        body: Container(
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
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (_suggestTags.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _suggestTags.map((t) {
                              final selected =
                                  _controller.text.trim().toLowerCase() ==
                                      t.toLowerCase();
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(t),
                                  selected: selected,
                                  onSelected: (_) {
                                    _controller.text = t;
                                    _searchJobs(t);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Row(
                        children: [
                          Text(
                            "Shop by",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  FilterPill(
                                    label: "Categories",
                                    selected: true,
                                    onTap: () => _openCategoriesSheet(context),
                                  ),
                                  const SizedBox(width: 8),
                                  const FilterPill(label: "Style"),
                                  const SizedBox(width: 8),
                                  const FilterPill(label: "Service"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: Divider(height: 1)),
                  if (_isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_jobs.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyView(),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final wrap =
                              _jobs[index] as Map<String, dynamic>? ?? {};
                          final job = (wrap["congViec"] ?? wrap)
                              as Map<String, dynamic>;
                          final id = (job['id'] as num?)?.toInt();

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            child: Stack(
                              children: [
                                JobListTile(job: job),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Material(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: const CircleBorder(),
                                    child: IconButton(
                                      iconSize: 22,
                                      onPressed: () => _toggleFav(job),
                                      icon: Icon(
                                        _favIds.contains(id)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: _favIds.contains(id)
                                            ? Colors.red
                                            : Colors.black26,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: _jobs.length,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openCategoriesSheet(BuildContext context) {
    if (_menuLoai.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SafeArea(
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.7,
              child: ListView.separated(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _menuLoai.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final loai = _menuLoai[i] as Map<String, dynamic>;
                  final tenLoai = (loai["tenLoaiCongViec"] ?? "").toString();
                  final dsNhom =
                      (loai["dsNhomChiTietLoai"] ?? []) as List<dynamic>;
                  return ListTile(
                    title: Text(
                      tenLoai,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CategoriesPage(),
                          settings: RouteSettings(arguments: {
                            "tenLoaiCongViec": tenLoai,
                            "dsNhomChiTietLoai": dsNhom,
                          }),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            "Try a different keyword or explore categories",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
