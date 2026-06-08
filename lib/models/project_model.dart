import 'user_model.dart';

class ProgressModel {
  final int total;
  final int done;
  final int percent;

  const ProgressModel({required this.total, required this.done, required this.percent});

  factory ProgressModel.fromJson(Map<String, dynamic> json) => ProgressModel(
        total: json['total'] as int? ?? 0,
        done: json['done'] as int? ?? 0,
        percent: json['percent'] as int? ?? 0,
      );
}

class ProjectModel {
  final int id;
  final String namaProject;
  final String kodeProject;
  final String? deskripsi;
  final String status;
  final String? tanggalKontrak;
  final String? tanggalMulai;
  final String? deadline;
  final ProgressModel? progress;
  final List<UserModel> assignedUsers;

  const ProjectModel({
    required this.id,
    required this.namaProject,
    required this.kodeProject,
    this.deskripsi,
    required this.status,
    this.tanggalKontrak,
    this.tanggalMulai,
    this.deadline,
    this.progress,
    this.assignedUsers = const [],
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id'] as int,
        namaProject: json['nama_project'] as String,
        kodeProject: json['kode_project'] as String,
        deskripsi: json['deskripsi'] as String?,
        status: json['status'] as String? ?? 'active',
        tanggalKontrak: json['tanggal_kontrak'] as String?,
        tanggalMulai: json['tanggal_mulai'] as String?,
        deadline: json['deadline'] as String?,
        assignedUsers: (json['users'] as List?)
                ?.map((u) => UserModel.fromJson(u as Map<String, dynamic>))
                .toList() ??
            [],
        progress: json['progress'] == null
            ? null
            : (json['progress'] is Map)
                ? ProgressModel.fromJson(json['progress'] as Map<String, dynamic>)
                // Admin dashboard returns progress as a plain integer (percentage)
                : ProgressModel(
                    total: 100,
                    done: (json['progress'] as num).toInt(),
                    percent: (json['progress'] as num).toInt(),
                  ),
      );
}
