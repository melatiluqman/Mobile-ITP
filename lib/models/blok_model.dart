import 'project_model.dart';

class BlokModel {
  final int id;
  final String namaBlok;
  final ProgressModel progress;

  const BlokModel({
    required this.id,
    required this.namaBlok,
    required this.progress,
  });

  factory BlokModel.fromJson(Map<String, dynamic> json) => BlokModel(
        id: json['id'] as int,
        namaBlok: json['nama_blok'] as String,
        progress: ProgressModel.fromJson(json['progress'] as Map<String, dynamic>),
      );
}
