import 'package:flutter/material.dart';

class CommentsPreview extends StatelessWidget {
  final List<dynamic> comments;
  final VoidCallback? onSeeAll;

  const CommentsPreview({super.key, required this.comments, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 4),
            // Sao trung bình sẽ truyền từ ngoài vào nếu cần hiển thị
            Text(
              "${comments.length} reviews",
              style: const TextStyle(color: Colors.grey),
            ),
            const Spacer(),
            if (comments.isNotEmpty)
              TextButton(onPressed: onSeeAll, child: const Text("See All")),
          ],
        ),
        const SizedBox(height: 8),
        comments.isEmpty
            ? const Align(
                alignment: Alignment.centerLeft,
                child: Text("Chưa có bình luận"),
              )
            : Column(
                children: comments.take(3).map((c) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
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
                        c['tenNguoiBinhLuan']?.toString() ?? "Ẩn danh",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(c['noiDung']?.toString() ?? ""),
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
                }).toList(),
              ),
      ],
    );
  }
}
