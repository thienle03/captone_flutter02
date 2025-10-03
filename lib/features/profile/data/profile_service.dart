import 'dart:io';
import 'package:fiverr/services/profile_service.dart';

class ProfileRepository {
  /// Lấy userId từ local
  Future<int?> getUserId([int? fromWidget]) {
    return ProfileService.getUserId(fromWidget);
  }

  Future<Map<String, dynamic>?> fetchUser(int uid) {
    return ProfileService.fetchUser(uid);
  }

  /// Lấy thông tin user
  Future<Map<String, dynamic>?> getUser(int uid) {
    return ProfileService.fetchUser(uid);
  }

  /// Update user và trả về true/false
  Future<bool> updateUser(
    int uid,
    Map<String, dynamic> patch,
    Map<String, dynamic> currentUser,
  ) {
    return ProfileService.updateUser(uid, patch, currentUser);
  }

  /// Upload avatar và trả về URL
  Future<String?> uploadAvatar(File file) {
    return ProfileService.uploadAvatar(file);
  }

  Future<List<String>> fetchSkills() {
    return ProfileService.fetchSkills();
  }

  /// Lấy danh sách skill
  Future<List<String>> getSkills({String? q}) {
    return ProfileService.fetchSkills();
  }

  /// Update user rồi fetch lại (tiện cho UI)
  Future<Map<String, dynamic>?> updateAndGetUser(
    int uid,
    Map<String, dynamic> patch,
    Map<String, dynamic> currentUser,
  ) async {
    final ok = await updateUser(uid, patch, currentUser);
    if (ok) return getUser(uid);
    return null;
  }
}
