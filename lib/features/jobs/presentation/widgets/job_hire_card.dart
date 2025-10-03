import 'package:fiverr/features/job_detail/presentation/screens/job_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../domain/job_hire_group.dart';

class JobHireCard extends StatelessWidget {
  final JobHireGroup group;
  final VoidCallback? onCompleteOne;
  final VoidCallback? onDeleteGroup;

  const JobHireCard({
    super.key,
    required this.group,
    this.onCompleteOne,
    this.onDeleteGroup,
  });

  @override
  Widget build(BuildContext context) {
    final job = group.job;
    final int jobId = job["id"];
    final int count = group.count;
    final String imageUrl = group.imageUrl ?? "";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobDetailScreen(maCongViec: jobId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HÀNG TRÊN: Ảnh + tên
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.work, size: 40),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor:
                              group.done ? Colors.green : Colors.orange,
                          child: Icon(
                            group.done ? Icons.check : Icons.timelapse,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      job["tenCongViec"] ?? "Không tên",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Giá + số lần thuê
              Text(
                "Giá: \$${job["giaTien"] ?? 0} • x$count lần",
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 12),

              // HÀNG DƯỚI: Các nút
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (group.done) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobDetailScreen(maCongViec: jobId),
                          ),
                        );
                      },
                      child: const Text("Thuê lại"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: onDeleteGroup,
                      child: const Text("Xóa"),
                    ),
                  ] else ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: onCompleteOne,
                      child: const Text("Hoàn thành"),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
