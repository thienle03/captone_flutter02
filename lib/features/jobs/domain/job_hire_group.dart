class JobHireGroup {
  final Map<String, dynamic> job;
  final int count;
  final List<int> hireIds;
  final String imageUrl;
  final bool done;

  JobHireGroup({
    required this.job,
    required this.count,
    required this.hireIds,
    required this.imageUrl,
    required this.done,
  });
}

class JobHireUtils {
  static List<JobHireGroup> groupByJob(
    Iterable<dynamic> items, {
    required bool done,
  }) {
    final Map<int, JobHireGroup> grouped = {};

    for (final e in items) {
      if (e is! Map) continue;
      final job = e["congViec"] ?? {};
      final int? jobId = job["id"];
      if (jobId == null) continue;
      final hireId = e["id"] as int;

      if (grouped.containsKey(jobId)) {
        final old = grouped[jobId]!;
        grouped[jobId] = JobHireGroup(
          job: old.job,
          count: old.count + 1,
          hireIds: [...old.hireIds, hireId],
          imageUrl: old.imageUrl,
          done: done,
        );
      } else {
        grouped[jobId] = JobHireGroup(
          job: job,
          count: 1,
          hireIds: [hireId],
          imageUrl: job["hinhAnh"]?.toString() ?? "",
          done: done,
        );
      }
    }

    return grouped.values.toList()..sort((a, b) => b.count.compareTo(a.count));
  }
}
