import 'package:fiverr/services/job_detail_service.dart';

class JobDetailRepository {
  final JobDetailService _service;

  JobDetailRepository({JobDetailService? service})
      : _service = service ?? JobDetailService();

  Future<Map<String, dynamic>?> getJobDetail(int maCongViec) {
    return _service.fetchJobDetail(maCongViec);
  }

  Future<List<dynamic>> getComments(int maCongViec) {
    return _service.fetchComments(maCongViec);
  }

  Future<({String message, bool ok})> addComment({
    required int maCongViec,
    required String content,
    int saoBinhLuan = 5,
  }) {
    return _service.postComment(
      maCongViec: maCongViec,
      content: content,
      saoBinhLuan: saoBinhLuan,
    );
  }

  Future<bool> hireJob(int maCongViec) {
    return _service.hireJob(maCongViec);
  }
}
