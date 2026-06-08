class ItpDataModel {
  final int id;
  final String? photo;
  final String? keterangan;
  final String status;
  final String? rejectionNote;
  final String? approvedAt;
  final String? role;
  final String? name;
  final String? updatedAt;
  final bool canAcc;
  final bool canReject;

  const ItpDataModel({
    required this.id,
    this.photo,
    this.keterangan,
    required this.status,
    this.rejectionNote,
    this.approvedAt,
    this.role,
    this.name,
    this.updatedAt,
    this.canAcc = false,
    this.canReject = false,
  });

  factory ItpDataModel.fromJson(Map<String, dynamic> json) => ItpDataModel(
        id: json['id'] as int,
        photo: json['photo'] as String?,
        keterangan: json['keterangan'] as String?,
        status: json['status'] as String? ?? 'done',
        rejectionNote: json['rejection_note'] as String?,
        approvedAt: json['approved_at'] as String?,
        role: json['role'] as String?,
        name: json['name'] as String?,
        updatedAt: json['updated_at'] as String?,
        canAcc: json['can_acc'] as bool? ?? false,
        canReject: json['can_reject'] as bool? ?? false,
      );

  String get statusLabel {
    switch (status) {
      case 'done':
        return 'Selesai';
      case 'approved':
        return 'Disetujui';
      case 'needs_revision':
        return 'Perlu Revisi';
      default:
        return status;
    }
  }
}

class InspectionModel {
  final int id;
  final String code;
  final String item;
  final String? assemblyDescription;
  final String? yardVal;
  final String? classVal;
  final String? osVal;
  final String? statVal;
  final String? myVal;
  final bool canSubmit;
  final bool photoRequired;
  final ItpDataModel? myData;
  final int allDataCount;

  const InspectionModel({
    required this.id,
    required this.code,
    required this.item,
    this.assemblyDescription,
    this.yardVal,
    this.classVal,
    this.osVal,
    this.statVal,
    this.myVal,
    required this.canSubmit,
    required this.photoRequired,
    this.myData,
    required this.allDataCount,
  });

  factory InspectionModel.fromJson(Map<String, dynamic> json) => InspectionModel(
        id: json['id'] as int,
        code: json['code'] as String,
        item: json['item'] as String,
        assemblyDescription: json['assembly_description'] as String?,
        yardVal: json['yard_val'] as String?,
        classVal: json['class_val'] as String?,
        osVal: json['os_val'] as String?,
        statVal: json['stat_val'] as String?,
        myVal: json['my_val'] as String?,
        canSubmit: json['can_submit'] as bool? ?? false,
        photoRequired: json['photo_required'] as bool? ?? false,
        myData: json['my_data'] != null
            ? ItpDataModel.fromJson(json['my_data'] as Map<String, dynamic>)
            : null,
        allDataCount: json['all_data_count'] as int? ?? 0,
      );
}

class AssemblyGroupModel {
  final String assemblyCode;
  final String? assemblyDescription;
  final List<InspectionModel> inspections;

  const AssemblyGroupModel({
    required this.assemblyCode,
    this.assemblyDescription,
    required this.inspections,
  });

  factory AssemblyGroupModel.fromJson(Map<String, dynamic> json) => AssemblyGroupModel(
        assemblyCode: json['assembly_code'] as String,
        assemblyDescription: json['assembly_description'] as String?,
        inspections: (json['inspections'] as List)
            .map((i) => InspectionModel.fromJson(i as Map<String, dynamic>))
            .toList(),
      );
}
