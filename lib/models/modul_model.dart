import 'project_model.dart';

class LockInfo {
  final String? unlockDate;
  final int? daysUntilUnlock;
  final int? daysSinceCompleted;
  final int? daysRemaining;
  final int? daysElapsed;
  final int? timePercent;

  const LockInfo({
    this.unlockDate,
    this.daysUntilUnlock,
    this.daysSinceCompleted,
    this.daysRemaining,
    this.daysElapsed,
    this.timePercent,
  });

  factory LockInfo.fromJson(Map<String, dynamic> json) => LockInfo(
        unlockDate: json['unlock_date'] as String?,
        daysUntilUnlock: json['days_until_unlock'] as int?,
        daysSinceCompleted: json['days_since_completed'] as int?,
        daysRemaining: json['days_remaining'] as int?,
        daysElapsed: json['days_elapsed'] as int?,
        timePercent: json['time_percent'] as int?,
      );
}

class ModulModel {
  final int id;
  final String namaModul;
  final String? deskripsi;
  final int? startDay;
  final int? durationDays;
  final ProgressModel progress;
  final String lockState;
  final LockInfo? lockInfo;

  const ModulModel({
    required this.id,
    required this.namaModul,
    this.deskripsi,
    this.startDay,
    this.durationDays,
    required this.progress,
    required this.lockState,
    this.lockInfo,
  });

  factory ModulModel.fromJson(Map<String, dynamic> json) => ModulModel(
        id: json['id'] as int,
        namaModul: json['nama_modul'] as String,
        deskripsi: json['deskripsi'] as String?,
        startDay: json['start_day'] as int?,
        durationDays: json['duration_days'] as int?,
        progress: ProgressModel.fromJson(json['progress'] as Map<String, dynamic>),
        lockState: json['lock_state'] as String? ?? 'active',
        lockInfo: json['lock_info'] != null && (json['lock_info'] as Map).isNotEmpty
            ? LockInfo.fromJson(json['lock_info'] as Map<String, dynamic>)
            : null,
      );

  bool get isLocked => lockState == 'locked';
  bool get isCompleted => lockState == 'completed';
  bool get isActive => lockState == 'active';
}
