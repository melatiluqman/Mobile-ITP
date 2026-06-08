import 'project_model.dart';

class SubBlokModel {
  final int id;
  final String namaSubBlok;
  final ProgressModel progress;

  const SubBlokModel({
    required this.id,
    required this.namaSubBlok,
    required this.progress,
  });

  factory SubBlokModel.fromJson(Map<String, dynamic> json) => SubBlokModel(
        id: json['id'] as int,
        namaSubBlok: json['nama_sub_blok'] as String,
        progress: ProgressModel.fromJson(json['progress'] as Map<String, dynamic>),
      );
}
