import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/exceptions.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/admin_model.dart';

class AdminService {
  Future<DashboardStatsModel> getDashboard() async {
    try {
      final res = await ApiClient.instance.get('/admin/dashboard');
      return DashboardStatsModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final res = await ApiClient.instance.get('/admin/users');
      return (res.data as List)
          .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<UserModel> storeUser({
    required String name,
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      final res = await ApiClient.instance.post('/admin/users', data: {
        'name': name,
        'username': username,
        'password': password,
        'role': role,
      });
      return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await ApiClient.instance.delete('/admin/users/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ProjectModel> storeProject({
    required String namaProject,
    required String kodeProject,
    String? deskripsi,
    String? tanggalKontrak,
    String? tanggalMulai,
    String? deadline,
    int? templateId,
  }) async {
    try {
      final data = <String, dynamic>{
        'nama_project': namaProject,
        'kode_project': kodeProject,
      };
      if (deskripsi != null) data['deskripsi'] = deskripsi;
      if (tanggalKontrak != null) data['tanggal_kontrak'] = tanggalKontrak;
      if (tanggalMulai != null) data['tanggal_mulai'] = tanggalMulai;
      if (deadline != null) data['deadline'] = deadline;
      if (templateId != null) data['template_id'] = templateId;

      final res = await ApiClient.instance.post('/admin/projects', data: data);
      return ProjectModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<String> toggleProjectStatus(int id) async {
    try {
      final res = await ApiClient.instance.post('/admin/projects/$id/toggle-status');
      return res.data['status'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> assignUser(int projectId, int userId) async {
    try {
      await ApiClient.instance.post('/admin/projects/assign-user', data: {
        'project_id': projectId,
        'user_id': userId,
      });
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> unassignUser(int projectId, int userId) async {
    try {
      await ApiClient.instance.delete('/admin/projects/$projectId/users/$userId');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<ProjectTemplateModel>> getTemplates() async {
    try {
      final res = await ApiClient.instance.get('/admin/templates');
      return (res.data as List)
          .map((t) => ProjectTemplateModel.fromJson(t as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ─── Project Structure ───────────────────────────────────────

  Future<ProjectStructureModel> getProjectStructure(int projectId) async {
    try {
      final res = await ApiClient.instance.get('/admin/projects/$projectId/structure');
      return ProjectStructureModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ModulStructureModel> storeModul({required int projectId, required String namaModul, String? deskripsi}) async {
    try {
      final data = <String, dynamic>{'project_id': projectId, 'nama_modul': namaModul};
      if (deskripsi != null) data['deskripsi'] = deskripsi;
      final res = await ApiClient.instance.post('/admin/moduls', data: data);
      return ModulStructureModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteModul(int id) async {
    try {
      await ApiClient.instance.delete('/admin/moduls/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> scheduleModul(int id, {required int startDay, required int durationDays}) async {
    try {
      await ApiClient.instance.post('/admin/moduls/$id/schedule', data: {
        'start_day': startDay,
        'duration_days': durationDays,
      });
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<BlokStructureModel> storeBlok({required int modulId, required String namaBlok}) async {
    try {
      final res = await ApiClient.instance.post('/admin/bloks', data: {
        'modul_id': modulId,
        'nama_blok': namaBlok,
      });
      return BlokStructureModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteBlok(int id) async {
    try {
      await ApiClient.instance.delete('/admin/bloks/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<SubBlokStructureModel> storeSubBlok({required int blokId, required String namaSubBlok}) async {
    try {
      final res = await ApiClient.instance.post('/admin/sub-bloks', data: {
        'blok_id': blokId,
        'nama_sub_blok': namaSubBlok,
      });
      return SubBlokStructureModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteSubBlok(int id) async {
    try {
      await ApiClient.instance.delete('/admin/sub-bloks/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ItpStructureModel> storeItp({
    required int subBlokId,
    required String assemblyCode,
    String? assemblyDescription,
    required String code,
    required String item,
    required String yardVal,
    required String classVal,
    required String osVal,
    required String statVal,
  }) async {
    try {
      final data = <String, dynamic>{
        'sub_blok_id': subBlokId,
        'assembly_code': assemblyCode,
        'code': code,
        'item': item,
        'yard_val': yardVal,
        'class_val': classVal,
        'os_val': osVal,
        'stat_val': statVal,
      };
      if (assemblyDescription != null) data['assembly_description'] = assemblyDescription;
      final res = await ApiClient.instance.post('/admin/itps', data: data);
      return ItpStructureModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteItp(int id) async {
    try {
      await ApiClient.instance.delete('/admin/itps/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ─── Activity Logs ───────────────────────────────────────────

  Future<List<ActivityLogModel>> getActivityLogs() async {
    try {
      final res = await ApiClient.instance.get('/admin/logs');
      return (res.data as List)
          .map((l) => ActivityLogModel.fromJson(l as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
