import 'package:flutter/material.dart';
import 'package:fiverr/features/job_detail/presentation/screens/job_detail_screen.dart';

class JobListTile extends StatelessWidget {
  final Map<String, dynamic> job;
  const JobListTile({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final title = (job["tenCongViec"] ?? "Không có tiêu đề").toString();
    final img = (job["hinhAnh"] ?? "").toString();
    final rating = (job["saoCongViec"] ?? "-").toString();
    final price = (job["giaTien"] ?? "-").toString();
    final id = job["id"];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (id != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => JobDetailScreen(maCongViec: id),
              ),
            );
          }
        },
        child: SizedBox(
          height: 96,
          child: Row(
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child:
                    img.isEmpty
                        ? Container(
                          color: const Color(0xFFEFEFEF),
                          child: const Icon(Icons.image_not_supported),
                        )
                        : Image.network(img, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(rating),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "From \$$price",
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
