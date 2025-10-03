import 'dart:io';

import 'package:fiverr/features/notifications/data/notification_service.dart';
import 'package:fiverr/services/profile_service.dart';
import 'package:fiverr/shared/avatar_store.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👈 thêm
import 'package:fiverr/features/profile/data/profile_service.dart';
import 'package:fiverr/features/profile/presentation/widgets/profile_header.dart';
import 'package:fiverr/features/profile/presentation/widgets/section_card.dart';
import 'package:fiverr/features/profile/presentation/widgets/bullet_list.dart';
import 'package:fiverr/features/profile/presentation/widgets/edit_description_sheet.dart';
import 'package:fiverr/features/profile/presentation/widgets/edit_skills_sheet.dart';
import 'package:fiverr/features/profile/presentation/widgets/edit_string_list_sheet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.userId});
  final int? userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _repo = ProfileRepository();
  int? _uid;
  int _unread = 0;
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _user = {};

  @override
  void initState() {
    super.initState();
    _initUserId();
    _loadUnread();
  }

  Future<void> _loadUnread() async {
    try {
      final n = await NotificationService.unreadCount();
      if (mounted) setState(() => _unread = n);
    } catch (_) {
      if (mounted) setState(() => _unread = 0);
    }
  }

  Widget _bellButton() {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationService.unread,
      builder: (_, unread, __) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: "Thông báo",
              icon: const Icon(Icons.notifications_none),
              onPressed: () async {
                await Navigator.pushNamed(context, '/notifications');
                // Refresh lại khi quay về
                await NotificationService.refreshUnread();
              },
            ),
            if (unread > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unread > 99 ? "99+" : "$unread",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _initUserId() async {
    _uid = await _repo.getUserId(widget.userId);
    if (_uid == null) {
      setState(() {
        _loading = false;
        _error = "Chưa đăng nhập (không có userId).";
      });
      return;
    }
    await _fetchUser();
  }

  bool _uploadingAvatar = false;

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery, // ✅ chỉ thư viện
      imageQuality: 90,
      maxWidth: 1500,
    );
    if (picked == null) return;

    if (mounted) setState(() => _uploadingAvatar = true);
    try {
      await ProfileService.uploadAvatar(File(picked.path));
      await _fetchUser(); // reload profile để thấy avatar mới
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Cập nhật avatar thành công")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Upload avatar thất bại: $e")));
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _fetchUser() async {
    if (_uid == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _user = await _repo.fetchUser(_uid!) ?? {};
      await AvatarStore.set(_user["avatar"]?.toString());
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ====== LOGOUT ======
  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc muốn đăng xuất khỏi ứng dụng?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final prefs = await SharedPreferences.getInstance();
    // Xóa các key bạn đang dùng
    await prefs.remove("userId");
    await prefs.remove("email");
    await prefs.remove("name");
    await prefs.remove("jwt"); // nếu có lưu JWT

    if (!mounted) return;
    // Quay về màn login và xóa history
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Đã đăng xuất")));
  }

  void _openEditDescription() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => EditDescriptionSheet(
        user: _user,
        onSave: (patch) async =>
            await ProfileService.updateUser(_uid!, patch, _user),
      ),
    );
  }

  void _openEditSkills() async {
    try {
      final allSkills = await _repo.fetchSkills(); // sẽ >0
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => EditSkillsSheet(
          allSkills: allSkills,
          current: Set<String>.from(
            (_user["skill"] as List?)?.map((e) => e.toString()) ??
                const <String>[],
          ),
          onSave: (skills) async {
            final ok = await _repo.updateUser(
              _uid!,
              {"skill": skills},
              _user,
            );
            if (ok) await _fetchUser();
            return ok;
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi load skill: $e")),
      );
    }
  }

  void _openEditCertifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => EditStringListSheet(
        fieldLabel: "Certification",
        current: List<String>.from(_user["certification"] ?? []),
        onSave: (list) async => await _repo.updateUser(
            _uid!,
            {
              "certification": list,
            },
            _user),
      ),
    );
  }

  // =================== UI ===================
  @override
  Widget build(BuildContext context) {
    final name = (_user["name"] ?? "Profile").toString();
    final rawName = name.trim();
    final displayName =
        (rawName.isEmpty || rawName.length < 2) ? "Profile" : rawName;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          displayName,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          _bellButton(),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchUser),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Đăng xuất",
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
                // 👈 tránh tràn dưới status bar
                child: _error != null
                    ? Center(child: Text("Lỗi: $_error"))
                    : RefreshIndicator(
                        onRefresh: _fetchUser,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(), // 👈
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                          children: [
                            ProfileHeader(
                              name: _user["name"] ?? "",
                              email: _user["email"] ?? "",
                              onEdit: _openEditDescription,
                              avatarUrl: _user["avatar"]?.toString(),
                              onEditAvatar: _pickAndUploadAvatar,
                              uploadingAvatar: _uploadingAvatar,
                            ),
                            SectionCard(
                              title: "Description",
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _kv("Name", _user["name"] ?? ""),
                                  _kv("Email", _user["email"] ?? ""),
                                  _kv("Phone", _user["phone"] ?? ""),
                                ],
                              ),
                            ),
                            SectionCard(
                              title: "Skills",
                              onEdit: _openEditSkills,
                              child: BulletList(
                                items: _stringListOf(_user["skill"]),
                              ),
                            ),
                            SectionCard(
                              title: "Certification",
                              onEdit: _openEditCertifications,
                              child: BulletList(
                                items: _stringListOf(_user["certification"]),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              onPressed: _logout,
                              icon: const Icon(Icons.logout),
                              label: const Text("Đăng xuất"),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(k, style: const TextStyle(color: Colors.black54)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(v.isEmpty ? "-" : v)),
          ],
        ),
      );

  List<String> _stringListOf(dynamic any) {
    if (any == null) return [];
    if (any is List) {
      return any
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    return any
        .toString()
        .split(RegExp(r'[,\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
