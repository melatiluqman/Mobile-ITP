import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../core/api_client.dart';
import '../core/exceptions.dart';
import '../models/project_model.dart';
import '../models/modul_model.dart';
import '../models/blok_model.dart';
import '../models/subblok_model.dart';
import '../models/itp_model.dart';

class ItpService {
  Future<List<ProjectModel>> getProjects() async {
    try {
      final res = await ApiClient.instance.get('/projects');
      return (res.data as List)
          .map((p) => ProjectModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> getModuls(int projectId) async {
    try {
      final res = await ApiClient.instance.get('/projects/$projectId/moduls');
      final data = res.data as Map<String, dynamic>;
      return {
        'project': ProjectModel.fromJson(data['project'] as Map<String, dynamic>),
        'day_n': data['day_n'],
        'moduls': (data['moduls'] as List)
            .map((m) => ModulModel.fromJson(m as Map<String, dynamic>))
            .toList(),
      };
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> getBloks(int modulId) async {
    try {
      final res = await ApiClient.instance.get('/moduls/$modulId/bloks');
      final data = res.data as Map<String, dynamic>;
      return {
        'modul': data['modul'],
        'project': data['project'],
        'bloks': (data['bloks'] as List)
            .map((b) => BlokModel.fromJson(b as Map<String, dynamic>))
            .toList(),
      };
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> getSubBloks(int blokId) async {
    try {
      final res = await ApiClient.instance.get('/bloks/$blokId/subbloks');
      final data = res.data as Map<String, dynamic>;
      return {
        'blok': data['blok'],
        'subbloks': (data['subbloks'] as List)
            .map((s) => SubBlokModel.fromJson(s as Map<String, dynamic>))
            .toList(),
      };
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> getAssembly(int subblokId) async {
    try {
      final res = await ApiClient.instance.get('/subbloks/$subblokId/assembly');
      final data = res.data as Map<String, dynamic>;
      return {
        'subblok': data['subblok'],
        'blok': data['blok'],
        'role': data['role'],
        'assemblies': (data['assemblies'] as List)
            .map((a) => AssemblyGroupModel.fromJson(a as Map<String, dynamic>))
            .toList(),
      };
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> getItpDetail(int itpId) async {
    try {
      final res = await ApiClient.instance.get('/itp-data/$itpId');
      final data = res.data as Map<String, dynamic>;
      return {
        'itp': data['itp'],
        'my_data': data['my_data'] != null
            ? ItpDataModel.fromJson(data['my_data'] as Map<String, dynamic>)
            : null,
        'all_data': (data['all_data'] as List)
            .map((d) => ItpDataModel.fromJson(d as Map<String, dynamic>))
            .toList(),
        'role': data['role'],
        'can_submit': data['can_submit'],
        'photo_required': data['photo_required'],
        'val': data['val'],
        'can_acc_role': data['can_acc_role'],
        'all_vals': data['all_vals'],
      };
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<String> storeItpData({
    required int itpId,
    String? keterangan,
    XFile? photo,
  }) async {
    try {
      final map = <String, dynamic>{'itp_id': itpId};
      if (keterangan != null) map['keterangan'] = keterangan;
      if (photo != null) {
        map['photo'] = await MultipartFile.fromFile(photo.path, filename: photo.name);
      }
      final formData = FormData.fromMap(map);
      final res = await ApiClient.instance.post('/itp-data', data: formData);
      return res.data['message'] as String? ?? 'Berhasil disimpan';
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<String> approveItpData(int id) async {
    try {
      final res = await ApiClient.instance.post('/itp-data/$id/approve');
      return res.data['message'] as String? ?? 'Data di-ACC';
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<String> rejectItpData(int id, String note) async {
    try {
      final res = await ApiClient.instance.post('/itp-data/$id/reject', data: {'note': note});
      return res.data['message'] as String? ?? 'Data ditolak';
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
