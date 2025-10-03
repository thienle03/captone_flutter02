import 'package:fiverr/services/job_service.dart';

class JobHireRepository {
  Future<List<dynamic>> fetchMyHires() {
    return JobsService.fetchMyHires();
  }

  Future<void> completeOne(int hireId) {
    return JobsService.completeOne(hireId);
  }

  Future<void> deleteOne(int hireId) {
    return JobsService.deleteOne(hireId);
  }
}
