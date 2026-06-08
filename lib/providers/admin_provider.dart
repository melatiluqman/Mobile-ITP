import 'package:flutter/foundation.dart';
import '../models/admin_model.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';
import '../core/exceptions.dart';

class AdminProvider extends ChangeNotifier {
  DashboardStatsModel? _dashboard;
  List<UserModel> _users = [];
  List<ProjectTemplateModel> _templates = [];
  bool _isLoading = false;
  String? _error;

  DashboardStatsModel? get dashboard => _dashboard;
  List<UserModel> get users => _users;
  List<ProjectTemplateModel> get templates => _templates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    _setLoading(true);
    _error = null;
    try {
      _dashboard = await AdminService().getDashboard();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUsers() async {
    _setLoading(true);
    _error = null;
    try {
      _users = await AdminService().getUsers();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTemplates() async {
    try {
      _templates = await AdminService().getTemplates();
      notifyListeners();
    } on ApiException catch (_) {}
  }

  Future<bool> createUser({
    required String name,
    required String username,
    required String password,
    required String role,
    required void Function(String) onError,
  }) async {
    _setLoading(true);
    try {
      final user = await AdminService().storeUser(
        name: name,
        username: username,
        password: password,
        role: role,
      );
      _users.insert(0, user);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUser(int id, {required void Function(String) onError}) async {
    try {
      await AdminService().deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    }
  }

  Future<bool> createProject({
    required String namaProject,
    required String kodeProject,
    String? deskripsi,
    String? tanggalKontrak,
    String? tanggalMulai,
    String? deadline,
    int? templateId,
    required void Function(String) onError,
  }) async {
    _setLoading(true);
    try {
      final project = await AdminService().storeProject(
        namaProject: namaProject,
        kodeProject: kodeProject,
        deskripsi: deskripsi,
        tanggalKontrak: tanggalKontrak,
        tanggalMulai: tanggalMulai,
        deadline: deadline,
        templateId: templateId,
      );
      _dashboard?.projects.insert(0, project);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleProjectStatus(int id) async {
    try {
      await AdminService().toggleProjectStatus(id);
      await loadDashboard();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<bool> assignUser(int projectId, int userId, {required void Function(String) onError}) async {
    try {
      await AdminService().assignUser(projectId, userId);
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    }
  }

  Future<bool> unassignUser(int projectId, int userId, {required void Function(String) onError}) async {
    try {
      await AdminService().unassignUser(projectId, userId);
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    }
  }

  // ─── Project Structure ───────────────────────────────────────

  ProjectStructureModel? _structure;
  bool _structureLoading = false;

  ProjectStructureModel? get structure => _structure;
  bool get structureLoading => _structureLoading;

  Future<void> loadStructure(int projectId) async {
    _structure = null;
    _structureLoading = true;
    _error = null;
    notifyListeners();
    try {
      _structure = await AdminService().getProjectStructure(projectId);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _structureLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addModul(int projectId, String namaModul, {String? deskripsi, required void Function(String) onError}) async {
    try {
      await AdminService().storeModul(projectId: projectId, namaModul: namaModul, deskripsi: deskripsi);
      await loadStructure(projectId);
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    }
  }

  Future<bool> removeModul(int modulId, int projectId, {required void Function(String) onError}) async {
    try {
      await AdminService().deleteModul(modulId);
      await loadStructure(projectId);
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    }
  }

  Future<bool> setModulSchedule(int modulId, int projectId, int startDay, int durationDays, {required void Function(String) onError}) async {
    try {
      await AdminService().scheduleModul(modulId, startDay: startDay, durationDays: durationDays);
      await loadStructure(projectId);
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    }
  }

  Future<bool> addBlok(int modulId, int projectId, String namaBlok, {required void Function(String) onError}) async {
    try {
      await AdminService().storeBlok(modulId: modulId, namaBlok: namaBlok);
      await loadStructure(projectId);
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    }
  }

  Future<bool> removeBlok(int blokId, int projectId, {required void Function(String) onError}) async {
    try {
      await AdminService().deleteBlok(blokId);
      await loadStructure(projectId);
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    }
  }

  Future<bool> addSubBlok(int blokId, int projectId, String namaSubBlok, {required void Function(String) onError}) async {
    try {
      await AdminService().storeSubBlok(blokId: blokId, namaSubBlok: namaSubBlok);
      await loadStructure(projectId);
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    }
  }

  Future<bool> removeSubBlok(int subBlokId, int projectId, {required void Function(String) onError}) async {
    try {
      await AdminService().deleteSubBlok(subBlokId);
      await loadStructure(projectId);
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    }
  }

  Future<bool> addItp(int projectId, {
    required int subBlokId,
    required String assemblyCode,
    String? assemblyDescription,
    required String code,
    required String item,
    required String yardVal,
    required String classVal,
    required String osVal,
    required String statVal,
    required void Function(String) onError,
  }) async {
    try {
      await AdminService().storeItp(
        subBlokId: subBlokId,
        assemblyCode: assemblyCode,
        assemblyDescription: assemblyDescription,
        code: code,
        item: item,
        yardVal: yardVal,
        classVal: classVal,
        osVal: osVal,
        statVal: statVal,
      );
      await loadStructure(projectId);
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    }
  }

  Future<bool> removeItp(int itpId, int projectId, {required void Function(String) onError}) async {
    try {
      await AdminService().deleteItp(itpId);
      await loadStructure(projectId);
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    }
  }

  // ─── Activity Logs ───────────────────────────────────────────

  List<ActivityLogModel> _activityLogs = [];
  bool _logsLoading = false;

  List<ActivityLogModel> get activityLogs => _activityLogs;
  bool get logsLoading => _logsLoading;

  Future<void> loadActivityLogs() async {
    _logsLoading = true;
    _error = null;
    notifyListeners();
    try {
      _activityLogs = await AdminService().getActivityLogs();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _logsLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
