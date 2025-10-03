import 'package:fiverr/features/job_detail/data/job_detail_service.dart';
import 'package:fiverr/features/job_detail/presentation/widgets/faq_section.dart';
import 'package:fiverr/features/job_detail/presentation/widgets/package_card.dart';
import 'package:fiverr/features/job_detail/presentation/widgets/reviews_section.dart';
import 'package:fiverr/features/notifications/data/notification_service.dart';
import 'package:flutter/material.dart';

class JobDetailScreen extends StatefulWidget {
  final int maCongViec;
  const JobDetailScreen({super.key, required this.maCongViec});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final repo = JobDetailRepository();

  Map<String, dynamic>? jobDetail;
  List<dynamic> comments = [];
  bool isLoading = true;
  bool _hiring = false;

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([_fetchJobDetail(), _fetchComments()]);
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _fetchJobDetail() async {
    final data = await repo.getJobDetail(widget.maCongViec);
    if (mounted) setState(() => jobDetail = data);
  }

  Future<void> _fetchComments() async {
    final list = await repo.getComments(widget.maCongViec);
    if (mounted) setState(() => comments = list);
  }

  Future<void> _hireJob() async {
    if (_hiring) return;
    setState(() => _hiring = true);

    final ok = await repo.hireJob(widget.maCongViec);
    if (!mounted) return;

    if (ok) {
      final title = "Thuê công việc thành công";
      final name = (jobDetail?['tenCongViec'] ?? "Công việc").toString();
      final price = jobDetail?['giaTien'];
      final body = "Bạn đã thuê: $name${price != null ? " · \$${price}" : ""}";

      // 👉 thêm thông báo
      await NotificationService.add(type: "order", title: title, body: body);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Thuê công việc thành công")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("❌ Vui lòng đăng nhập trước khi thuê hoặc có lỗi xảy ra"),
        ),
      );
    }

    setState(() => _hiring = false);
  }

  Future<void> _openAllComments() async {
    final ctl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 8,
          ),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "All reviews",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: comments.isEmpty
                      ? const Center(child: Text("Chưa có bình luận"))
                      : ListView.separated(
                          itemCount: comments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final c = comments[i] as Map;
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: (c['avatar'] != null &&
                                          c['avatar'].toString().isNotEmpty)
                                      ? NetworkImage(c['avatar'])
                                      : const AssetImage(
                                          "assets/default_avatar.png",
                                        ) as ImageProvider,
                                ),
                                title: Text(
                                  c['tenNguoiBinhLuan']?.toString() ??
                                      "Ẩn danh",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  c['noiDung']?.toString() ?? "",
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    Text("${c['saoBinhLuan'] ?? 0}"),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ctl,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: "Viết bình luận...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        final text = ctl.text.trim();
                        if (text.isEmpty) return;

                        // ✅ SỬA: dùng result thay vì ok, và đọc result.ok/result.message
                        final result = await repo.addComment(
                          maCongViec: widget.maCongViec,
                          content: text,
                        );
                        if (!mounted) return;

                        if (result.ok) {
                          ctl.clear();
                          await _fetchComments();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("✅ ${result.message}")),
                          );
                          setState(() {});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "❌ Lỗi khi thêm bình luận: ${result.message}",
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text("Send"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendCommentInline() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final result = await repo.addComment(
      maCongViec: widget.maCongViec,
      content: text,
    );

    if (!mounted) return;
    if (result.ok) {
      _commentController.clear();
      await _fetchComments();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ ${result.message}")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Thêm bình luận thất bại: ${result.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết công việc"),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        jobDetail?['hinhAnh'] ?? "",
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Avatar + creator name + rating
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            (jobDetail?['avatar'] != null &&
                                    (jobDetail?['avatar'] as String).isNotEmpty)
                                ? jobDetail!['avatar']
                                : "https://cdn-icons-png.flaticon.com/512/149/149071.png",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                jobDetail?['tenNguoiTao'] ?? "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text("${jobDetail?['saoCongViec'] ?? 0}"),
                                  const SizedBox(width: 4),
                                  Text(
                                    "(${jobDetail?['danhGia'] ?? 0} reviews)",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    JobPackageCard(
                      jobDetail: jobDetail,
                      hiring: _hiring,
                      onHire: _hireJob,
                    ),
                    const SizedBox(height: 20),

                    const FAQSection(),
                    const SizedBox(height: 20),

                    CommentsPreview(
                      comments: comments,
                      onSeeAll: _openAllComments,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            minLines: 1,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "Viết bình luận...",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: _sendCommentInline,
                          child: const Text("Send"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}
