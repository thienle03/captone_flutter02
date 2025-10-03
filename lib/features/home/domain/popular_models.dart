class PopularKeyword {
  final String label;
  final String keyword;
  const PopularKeyword({required this.label, required this.keyword});
}

class PopularItem {
  final String label;
  final String keyword;
  final String imageUrl;
  final dynamic jobWrap; // có thể null nếu không tìm thấy

  const PopularItem({
    required this.label,
    required this.keyword,
    required this.imageUrl,
    required this.jobWrap,
  });
}
