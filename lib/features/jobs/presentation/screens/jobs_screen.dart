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
      final jobName = (g.job["tenCongViec"] ?? "job").toString();

      await NotificationService.add(
        type: "done",
        title: "The work has been completed.",
        body: jobName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ The work has been completed.")),
      );
      await _fetchMyHires();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  Future<void> _deleteGroup(List<int> hireIds) async {
    try {
      for (final id in hireIds) {
        await _repo.deleteOne(id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑️ The job group has been deleted.")),
      );
      await _fetchMyHires();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
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
                    Text("Error: $_error"),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _fetchMyHires,
                      child: const Text("Try again."),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetchMyHires,
                child: ListView(
                  children: [
                    SectionTitle(
                      title: "Currently working.",
                      count: _inProgress.fold(0, (s, e) => s + e.count),
                    ),
                    if (_inProgress.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "No ongoing jobs",
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
                      title: "The work has been completed.",
                      count: _completed.fold(0, (s, e) => s + e.count),
                    ),
                    if (_completed.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "No completed jobs",
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
                                title: const Text("Delete job group"),
                                content: Text(
                                  "Delete all ${g.count} hires for this job?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Delete"),
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
          "My Job Hires",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
        child: SafeArea(child: body),
      ),
    );
  }
}
