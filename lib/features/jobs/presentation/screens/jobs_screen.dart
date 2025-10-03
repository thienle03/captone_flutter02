import 'package:fiverr/features/notifications/data/notification_service.dart';
import 'package:flutter/material.dart';
import '../../data/job_hire_repository.dart';
import '../../domain/job_hire_group.dart';
import '../widgets/section_title.dart';
import '../widgets/job_hire_card.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key, int? userId});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _repo = JobHireRepository();

  bool _loading = true;
  String? _error;
  List<dynamic> _raw = [];
  List<JobHireGroup> _inProgress = [];
  List<JobHireGroup> _completed = [];

  @override
  void initState() {
    super.initState();
    _fetchMyHires();
  }

  Future<void> _fetchMyHires() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      _raw = await _repo.fetchMyHires();
      _inProgress = JobHireUtils.groupByJob(
        _raw.where((e) => e["hoanThanh"] == false),
        done: false,
      );
      _completed = JobHireUtils.groupByJob(
        _raw.where((e) => e["hoanThanh"] == true),
        done: true,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _completeOne(int hireId) async {
    try {
      await _repo.completeOne(hireId);
      // lấy thông tin job từ nhóm gần nhất để có tên hiển thị
      final g = _inProgress.firstWhere(
        (e) => e.hireIds.contains(hireId),
        orElse: () => JobHireGroup(
            job: const {},
            hireIds: const [],
            done: false,
            count: 0,
            imageUrl: ""),
      );
      final jobName = (g.job["tenCongViec"] ?? "Công việc").toString();

      await NotificationService.add(
        type: "done",
        title: "Đã hoàn thành công việc",
        body: jobName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Đã hoàn thành 1 lần thuê")),
      );
      await _fetchMyHires();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Lỗi: $e")));
    }
  }

  Future<void> _deleteGroup(List<int> hireIds) async {
    try {
      for (final id in hireIds) {
        await _repo.deleteOne(id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑️ Đã xóa nhóm công việc")),
      );
      await _fetchMyHires();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Lỗi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Lỗi: $_error"),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _fetchMyHires,
                      child: const Text("Thử lại"),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetchMyHires,
                child: ListView(
                  children: [
                    SectionTitle(
                      title: "Đang làm",
                      count: _inProgress.fold(0, (s, e) => s + e.count),
                    ),
                    if (_inProgress.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "Không có công việc đang làm",
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    else
                      ..._inProgress.map(
                        (g) => JobHireCard(
                          group: g,
                          onCompleteOne: g.hireIds.isNotEmpty
                              ? () => _completeOne(g.hireIds.last)
                              : null,
                        ),
                      ),
                    SectionTitle(
                      title: "Đã hoàn thành",
                      count: _completed.fold(0, (s, e) => s + e.count),
                    ),
                    if (_completed.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "Chưa có công việc hoàn thành",
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    else
                      ..._completed.map(
                        (g) => JobHireCard(
                          group: g,
                          onDeleteGroup: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Xóa nhóm công việc"),
                                content: Text(
                                  "Xóa tất cả ${g.count} lần thuê của công việc này?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Hủy"),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Xóa"),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) _deleteGroup(g.hireIds);
                          },
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Thuê công việc của tôi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          // 👈 đổi màu cho nổi
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
            color: Colors.black), // 👈 nút back/menu cũng đổi màu
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
        child: SafeArea(child: body), // 👈 tránh title dính vào notch
      ),
    );
  }
}
