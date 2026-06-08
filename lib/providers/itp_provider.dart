import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/project_model.dart';
import '../services/itp_service.dart';
import '../core/exceptions.dart';

class ItpProvider extends ChangeNotifier {
  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  Future<void> loadProjects() async {
    _setLoading(true);
    _error = null;
    try {
      _projects = await ItpService().getProjects();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getModuls(int projectId) async {
    try {
      return await ItpService().getModuls(projectId);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBloks(int modulId) async {
    try {
      return await ItpService().getBloks(modulId);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSubBloks(int blokId) async {
    try {
      return await ItpService().getSubBloks(blokId);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAssembly(int subblokId) async {
    try {
      return await ItpService().getAssembly(subblokId);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> getItpDetail(int itpId) async {
    try {
      return await ItpService().getItpDetail(itpId);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> submitItpData({
    required int itpId,
    String? keterangan,
    XFile? photo,
    required void Function(String msg) onSuccess,
    required void Function(String msg) onError,
  }) async {
    _setLoading(true);
    try {
      final msg = await ItpService().storeItpData(
        itpId: itpId,
        keterangan: keterangan,
        photo: photo,
      );
      onSuccess(msg);
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> approveItpData(int id, {
    required void Function(String) onSuccess,
    required void Function(String) onError,
  }) async {
    _setLoading(true);
    try {
      final msg = await ItpService().approveItpData(id);
      onSuccess(msg);
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> rejectItpData(int id, String note, {
    required void Function(String) onSuccess,
    required void Function(String) onError,
  }) async {
    _setLoading(true);
    try {
      final msg = await ItpService().rejectItpData(id, note);
      onSuccess(msg);
      return true;
    } on ApiException catch (e) {
      onError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
