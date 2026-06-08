import 'user_model.dart';
import 'project_model.dart';

class ActivityItemModel {
  final int id;
  final String status;
  final String? keterangan;
  final String? rejectionNote;
  final String? createdAt;
  final String? updatedAt;
  final String userName;
  final String userRole;
  final String kodeProject;
  final String itpCode;

  const ActivityItemModel({
    required this.id,
    required this.status,
    this.keterangan,
    this.rejectionNote,
    this.createdAt,
    this.updatedAt,
    required this.userName,
    required this.userRole,
    required this.kodeProject,
    required this.itpCode,
  });

  factory ActivityItemModel.fromJson(Map<String, dynamic> json) => ActivityItemModel(
        id: json['id'] as int,
        status: json['status'] as String? ?? '-',
        keterangan: json['keterangan'] as String?,
        rejectionNote: json['rejection_note'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        userName: json['user_name'] as String? ?? '-',
        userRole: json['user_role'] as String? ?? '-',
        kodeProject: json['kode_project'] as String? ?? '-',
        itpCode: json['itp_code'] as String? ?? '-',
      );
}

class DashboardStatsModel {
  final int totalUsers;
  final int totalProjects;
  final int totalModuls;
  final int totalItps;
  final List<ProjectModel> projects;
  final List<UserModel> users;
  final List<ActivityItemModel> recentActivity;

  const DashboardStatsModel({
    required this.totalUsers,
    required this.totalProjects,
    required this.totalModuls,
    required this.totalItps,
    required this.projects,
    required this.users,
    required this.recentActivity,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) => DashboardStatsModel(
        totalUsers: json['total_users'] as int? ?? 0,
        totalProjects: json['total_projects'] as int? ?? 0,
        totalModuls: json['total_moduls'] as int? ?? 0,
        totalItps: json['total_itps'] as int? ?? 0,
        projects: (json['projects'] as List? ?? [])
            .map((p) => ProjectModel.fromJson(p as Map<String, dynamic>))
            .toList(),
        users: (json['users'] as List? ?? [])
            .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
            .toList(),
        recentActivity: (json['recent_activity'] as List? ?? [])
            .map((a) => ActivityItemModel.fromJson(a as Map<String, dynamic>))
            .toList(),
      );
}

class ProjectTemplateModel {
  final int id;
  final String name;
  final String? description;

  const ProjectTemplateModel({required this.id, required this.name, this.description});

  factory ProjectTemplateModel.fromJson(Map<String, dynamic> json) => ProjectTemplateModel(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
      );
}

// ─── Project Structure Models ────────────────────────────────

class ItpStructureModel {
  final int id;
  final int subBlokId;
  final String assemblyCode;
  final String? assemblyDescription;
  final String code;
  final String item;
  final String yardVal;
  final String classVal;
  final String osVal;
  final String statVal;

  const ItpStructureModel({
    required this.id,
    required this.subBlokId,
    required this.assemblyCode,
    this.assemblyDescription,
    required this.code,
    required this.item,
    required this.yardVal,
    required this.classVal,
    required this.osVal,
    required this.statVal,
  });

  factory ItpStructureModel.fromJson(Map<String, dynamic> json) => ItpStructureModel(
        id: json['id'] as int,
        subBlokId: json['sub_blok_id'] as int,
        assemblyCode: json['assembly_code'] as String? ?? '',
        assemblyDescription: json['assembly_description'] as String?,
        code: json['code'] as String? ?? '',
        item: json['item'] as String? ?? '',
        yardVal: json['yard_val'] as String? ?? '-',
        classVal: json['class_val'] as String? ?? '-',
        osVal: json['os_val'] as String? ?? '-',
        statVal: json['stat_val'] as String? ?? '-',
      );
}

class SubBlokStructureModel {
  final int id;
  final int blokId;
  final String namaSubBlok;
  final List<ItpStructureModel> itps;

  const SubBlokStructureModel({
    required this.id,
    required this.blokId,
    required this.namaSubBlok,
    required this.itps,
  });

  factory SubBlokStructureModel.fromJson(Map<String, dynamic> json) => SubBlokStructureModel(
        id: json['id'] as int,
        blokId: json['blok_id'] as int,
        namaSubBlok: json['nama_sub_blok'] as String? ?? '',
        itps: (json['itps'] as List? ?? [])
            .map((i) => ItpStructureModel.fromJson(i as Map<String, dynamic>))
            .toList(),
      );
}

class BlokStructureModel {
  final int id;
  final int modulId;
  final String namaBlok;
  final List<SubBlokStructureModel> subBloks;

  const BlokStructureModel({
    required this.id,
    required this.modulId,
    required this.namaBlok,
    required this.subBloks,
  });

  factory BlokStructureModel.fromJson(Map<String, dynamic> json) => BlokStructureModel(
        id: json['id'] as int,
        modulId: json['modul_id'] as int,
        namaBlok: json['nama_blok'] as String? ?? '',
        subBloks: (json['sub_bloks'] as List? ?? [])
            .map((s) => SubBlokStructureModel.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class ModulStructureModel {
  final int id;
  final int projectId;
  final String namaModul;
  final String? deskripsi;
  final int? startDay;
  final int? durationDays;
  final List<BlokStructureModel> bloks;

  const ModulStructureModel({
    required this.id,
    required this.projectId,
    required this.namaModul,
    this.deskripsi,
    this.startDay,
    this.durationDays,
    required this.bloks,
  });

  factory ModulStructureModel.fromJson(Map<String, dynamic> json) => ModulStructureModel(
        id: json['id'] as int,
        projectId: json['project_id'] as int,
        namaModul: json['nama_modul'] as String? ?? '',
        deskripsi: json['deskripsi'] as String?,
        startDay: json['start_day'] as int?,
        durationDays: json['duration_days'] as int?,
        bloks: (json['bloks'] as List? ?? [])
            .map((b) => BlokStructureModel.fromJson(b as Map<String, dynamic>))
            .toList(),
      );
}

class ProjectStructureModel {
  final Map<String, dynamic> project;
  final List<ModulStructureModel> moduls;

  const ProjectStructureModel({required this.project, required this.moduls});

  factory ProjectStructureModel.fromJson(Map<String, dynamic> json) => ProjectStructureModel(
        project: json['project'] as Map<String, dynamic>,
        moduls: (json['moduls'] as List? ?? [])
            .map((m) => ModulStructureModel.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}

// ─── Activity Log Model ──────────────────────────────────────

class ActivityLogModel {
  final int id;
  final String status;
  final String? keterangan;
  final String? rejectionNote;
  final String? createdAt;
  final String? updatedAt;
  final String userName;
  final String userRole;
  final String kodeProject;
  final String namaProject;
  final String itpCode;
  final String namaModul;

  const ActivityLogModel({
    required this.id,
    required this.status,
    this.keterangan,
    this.rejectionNote,
    this.createdAt,
    this.updatedAt,
    required this.userName,
    required this.userRole,
    required this.kodeProject,
    required this.namaProject,
    required this.itpCode,
    required this.namaModul,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) => ActivityLogModel(
        id: json['id'] as int,
        status: json['status'] as String? ?? '-',
        keterangan: json['keterangan'] as String?,
        rejectionNote: json['rejection_note'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        userName: json['user_name'] as String? ?? '-',
        userRole: json['user_role'] as String? ?? '-',
        kodeProject: json['kode_project'] as String? ?? '-',
        namaProject: json['nama_project'] as String? ?? '-',
        itpCode: json['itp_code'] as String? ?? '-',
        namaModul: json['nama_modul'] as String? ?? '-',
      );
}
