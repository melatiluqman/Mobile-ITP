import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/itp_provider.dart';
import '../../models/itp_model.dart';
import '../../core/constants.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/error_view.dart';

class ItpDetailScreen extends StatefulWidget {
  final int itpId;
  const ItpDetailScreen({required this.itpId, super.key});

  @override
  State<ItpDetailScreen> createState() => _ItpDetailScreenState();
}

class _ItpDetailScreenState extends State<ItpDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  final _keteranganController = TextEditingController();
  XFile? _pickedPhoto;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final result = await context.read<ItpProvider>().getItpDetail(widget.itpId);
    if (mounted) {
      setState(() {
        _loading = false;
        if (result != null) {
          _data = result;
          final myData = result['my_data'] as ItpDataModel?;
          _keteranganController.text = myData?.keterangan ?? '';
        } else {
          _error = context.read<ItpProvider>().error;
        }
      });
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (photo != null) setState(() => _pickedPhoto = photo);
  }

  Future<void> _submit() async {
    final canSubmit = _data?['can_submit'] as bool? ?? false;
    if (!canSubmit) return;
    final photoRequired = _data?['photo_required'] as bool? ?? false;
    if (photoRequired && _pickedPhoto == null && (_data?['my_data'] as ItpDataModel?)?.photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto wajib untuk kode W')),
      );
      return;
    }
    await context.read<ItpProvider>().submitItpData(
      itpId: widget.itpId,
      keterangan: _keteranganController.text.trim().isEmpty ? null : _keteranganController.text.trim(),
      photo: _pickedPhoto,
      onSuccess: (msg) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        _pickedPhoto = null;
        _load();
      },
      onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      ),
    );
  }

  Future<void> _approve(int dataId) async {
    await context.read<ItpProvider>().approveItpData(
      dataId,
      onSuccess: (msg) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        _load();
      },
      onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      ),
    );
  }

  Future<void> _reject(int dataId) async {
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: MediaQuery.of(ctx).viewInsets,
        child: const _RejectSheet(),
      ),
    );
    if (note == null || !mounted) return;
    await context.read<ItpProvider>().rejectItpData(
      dataId,
      note,
      onSuccess: (msg) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        _load();
      },
      onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
        body: ErrorView(message: _error!, onRetry: _load),
      );
    }

    final itp = _data!['itp'] as Map<String, dynamic>;
    final myData = _data!['my_data'] as ItpDataModel?;
    final allData = _data!['all_data'] as List<ItpDataModel>;
    final canSubmit = _data!['can_submit'] as bool? ?? false;
    final photoRequired = _data!['photo_required'] as bool? ?? false;
    final myVal = _data!['val'] as String? ?? '-';
    final myRole = _data!['role'] as String? ?? '';

    return Consumer<ItpProvider>(
      builder: (context, provider, child) => LoadingOverlay(
        isLoading: provider.isLoading,
        child: Scaffold(
          appBar: AppBar(
            title: Text(itp['code'] as String? ?? 'Detail ITP'),
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
            children: [
              // Item info card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(itp['item'] as String? ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _InfoRow('Kode', itp['code'] as String? ?? '-'),
                      _InfoRow('Val Saya', myVal),
                      Row(children: [
                        _ValBadge('Y', itp['yard_val'] as String?),
                        const SizedBox(width: 6),
                        _ValBadge('C', itp['class_val'] as String?),
                        const SizedBox(width: 6),
                        _ValBadge('O', itp['os_val'] as String?),
                        const SizedBox(width: 6),
                        _ValBadge('S', itp['stat_val'] as String?),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Status grid for all 4 roles
              _RoleStatusGrid(itp: itp, allData: allData, myRole: myRole),
              const SizedBox(height: 12),

              // Submit form
              if (canSubmit) ...[
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            myData?.status == 'needs_revision'
                                ? 'Resubmit Data ITP'
                                : myData != null
                                    ? 'Perbarui Data'
                                    : 'Submit Data',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _keteranganController,
                          decoration: const InputDecoration(
                            labelText: 'Keterangan',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        if (photoRequired || myData?.photo != null) ...[
                          Row(
                            children: [
                              const Text('Foto', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(width: 6),
                              Text(
                                photoRequired ? 'WAJIB (Witness)' : 'Opsional',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: photoRequired ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (myData?.photo != null && _pickedPhoto == null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                '${AppConstants.storageBaseUrl}${myData!.photo}',
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) =>
                                    const Icon(Icons.broken_image, size: 60),
                              ),
                            ),
                          if (_pickedPhoto != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(_pickedPhoto!.path), height: 150, fit: BoxFit.cover),
                            ),
                          ],
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _pickPhoto,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: Text(photoRequired ? 'Ambil Foto (Wajib)' : 'Ambil Foto'),
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: Text(
                              myData?.status == 'needs_revision'
                                  ? 'Resubmit Data ITP'
                                  : myData != null
                                      ? 'Update Data ITP'
                                      : 'Simpan Data ITP',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Status my data
              if (myData != null) ...[
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: _statusBgColor(myData.status),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_statusIcon(myData.status), color: _statusColor(myData.status)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                myData.status == 'approved' ? 'Data Anda sudah di-ACC' : myData.statusLabel,
                                style: TextStyle(color: _statusColor(myData.status), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        if (myData.status == 'approved' && myData.approvedAt != null) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: Text('Disetujui: ${myData.approvedAt}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF166534))),
                          ),
                        ],
                        if (myData.status == 'needs_revision' && myData.rejectionNote != null) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: Text('Catatan: ${myData.rejectionNote}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B))),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Review subordinate / all parties' data
              if (allData.isNotEmpty) ...[
                Row(
                  children: [
                    const Text('Review Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(width: 6),
                    if (allData.any((d) => d.canAcc || d.canReject))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Menunggu Review',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF92400E))),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ...allData.map((d) => _DataCard(data: d, onApprove: _approve, onReject: _reject)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'approved': return Colors.green.shade50;
      case 'done': return Colors.blue.shade50;
      case 'needs_revision': return Colors.orange.shade50;
      default: return Colors.grey.shade50;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'done': return Colors.blue;
      case 'needs_revision': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.check_circle;
      case 'done': return Icons.check_circle_outline;
      case 'needs_revision': return Icons.refresh;
      default: return Icons.radio_button_unchecked;
    }
  }
}

class _DataCard extends StatelessWidget {
  final ItpDataModel data;
  final Future<void> Function(int) onApprove;
  final Future<void> Function(int) onReject;
  const _DataCard({required this.data, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(data.role?.toUpperCase() ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 6),
                Text(data.name ?? '-', style: const TextStyle(fontSize: 13)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor(data.status).withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(data.statusLabel,
                      style: TextStyle(fontSize: 11, color: _statusColor(data.status), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            if (data.keterangan != null && data.keterangan!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(data.keterangan!, style: const TextStyle(fontSize: 13)),
            ],
            if (data.photo != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  '${AppConstants.storageBaseUrl}${data.photo}',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image),
                ),
              ),
            ],
            if (data.canAcc || data.canReject) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (data.canAcc)
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => onApprove(data.id),
                        icon: const Icon(Icons.check, color: Colors.white, size: 16),
                        label: const Text('ACC', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  if (data.canAcc && data.canReject) const SizedBox(width: 8),
                  if (data.canReject)
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        onPressed: () => onReject(data.id),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Tolak'),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'done': return Colors.blue;
      case 'needs_revision': return Colors.orange;
      default: return Colors.grey;
    }
  }
}

// Status grid showing every role's val + ACC-chain status (§3.5.f.1)
class _RoleStatusGrid extends StatelessWidget {
  final Map<String, dynamic> itp;
  final List<ItpDataModel> allData;
  final String myRole;
  const _RoleStatusGrid({required this.itp, required this.allData, required this.myRole});

  static const _roles = [
    ('yard', 'Yard', 'yard_val'),
    ('os', 'OS', 'os_val'),
    ('class', 'Class', 'class_val'),
    ('stat', 'Stat', 'stat_val'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status Semua Pihak',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
          const SizedBox(height: 10),
          Row(
            children: _roles.map((r) {
              final isLast = r == _roles.last;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 8),
                  child: _RoleBox(
                    label: r.$2,
                    val: itp[r.$3] as String?,
                    status: _statusFor(r.$1),
                    isMe: r.$1 == myRole,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String? _statusFor(String roleKey) {
    for (final d in allData) {
      if (d.role == roleKey) return d.status;
    }
    return null;
  }
}

class _RoleBox extends StatelessWidget {
  final String label;
  final String? val;
  final String? status;
  final bool isMe;
  const _RoleBox({required this.label, required this.val, required this.status, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final v = (val ?? '-').toUpperCase();
    final involved = v == 'W' || v == 'RV';

    String statusLabel;
    Color statusColor;
    if (!involved) {
      statusLabel = '—';
      statusColor = const Color(0xFF94A3B8);
    } else {
      switch (status) {
        case 'approved':
          statusLabel = 'ACC';
          statusColor = const Color(0xFF2563EB);
          break;
        case 'done':
          statusLabel = 'Done';
          statusColor = const Color(0xFF10B981);
          break;
        case 'needs_revision':
          statusLabel = 'Revisi';
          statusColor = const Color(0xFFDC2626);
          break;
        default:
          statusLabel = 'Pending';
          statusColor = const Color(0xFFD97706);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFDC2626).withAlpha(12) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMe ? const Color(0xFFDC2626) : const Color(0xFFE2E8F0),
          width: isMe ? 1.4 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isMe ? const Color(0xFFDC2626) : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(v, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
          ),
          const SizedBox(height: 4),
          Text(
            statusLabel,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ),
            Text(': $value', style: const TextStyle(fontSize: 13)),
          ],
        ),
      );
}

class _ValBadge extends StatelessWidget {
  final String role;
  final String? value;
  const _ValBadge(this.role, this.value);

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text('$role: $value', style: const TextStyle(fontSize: 11)),
    );
  }
}

// Modern bottom sheet for entering a rejection reason (min 3 chars).
class _RejectSheet extends StatefulWidget {
  const _RejectSheet();

  @override
  State<_RejectSheet> createState() => _RejectSheetState();
}

class _RejectSheetState extends State<_RejectSheet> {
  static const _danger = Color(0xFFDC2626);
  final _ctrl = TextEditingController();
  String? _error;

  static const _quickReasons = [
    'Foto tidak jelas / kurang',
    'Data tidak sesuai',
    'Perlu pengukuran ulang',
    'Dokumentasi belum lengkap',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final note = _ctrl.text.trim();
    if (note.length < 3) {
      setState(() => _error = 'Alasan minimal 3 karakter');
      return;
    }
    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _danger.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.block_outlined, color: _danger, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tolak Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Beri alasan agar bisa diperbaiki',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade100),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alasan cepat',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickReasons.map((r) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _ctrl.text = r;
                            _ctrl.selection = TextSelection.fromPosition(
                                TextPosition(offset: _ctrl.text.length));
                            _error = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _danger.withAlpha(12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _danger.withAlpha(40)),
                          ),
                          child: Text(r,
                              style: const TextStyle(fontSize: 12, color: _danger, fontWeight: FontWeight.w500)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ctrl,
                    autofocus: true,
                    maxLines: 4,
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                    decoration: InputDecoration(
                      hintText: 'Tulis alasan penolakan...',
                      errorText: _error,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _danger, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF475569),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _danger,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            onPressed: _submit,
                            icon: const Icon(Icons.send_outlined, size: 18),
                            label: const Text('Kirim Penolakan',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
