import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

/// Modern bottom-sheet form to create a new project (optionally from a template).
/// Open with [showModalBottomSheet] (isScrollControlled: true, useSafeArea: true).
class CreateProjectSheet extends StatefulWidget {
  const CreateProjectSheet({super.key});

  @override
  State<CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends State<CreateProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _kodeCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _deadlineCtrl = TextEditingController();
  int? _selectedTemplateId;
  bool _loading = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _kodeCtrl.dispose();
    _deskripsiCtrl.dispose();
    _startCtrl.dispose();
    _deadlineCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) {
      setState(() => ctrl.text = picked.toIso8601String().split('T').first);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<AdminProvider>().createProject(
      namaProject: _namaCtrl.text.trim(),
      kodeProject: _kodeCtrl.text.trim(),
      deskripsi: _deskripsiCtrl.text.trim().isEmpty ? null : _deskripsiCtrl.text.trim(),
      tanggalMulai: _startCtrl.text.isEmpty ? null : _startCtrl.text,
      deadline: _deadlineCtrl.text.isEmpty ? null : _deadlineCtrl.text,
      templateId: _selectedTemplateId,
      onError: (msg) => messenger.showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      ),
    );
    if (mounted) setState(() => _loading = false);
    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Proyek berhasil dibuat'), backgroundColor: Color(0xFF10B981)),
      );
      nav.pop();
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        suffixIcon: suffix,
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
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final templates = context.watch<AdminProvider>().templates;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.create_new_folder_outlined,
                      color: Color(0xFFDC2626), size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Buat Proyek',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Tambahkan proyek baru',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade100),
          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _namaCtrl,
                      decoration: _inputDecoration('Nama Proyek', Icons.folder_outlined),
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _kodeCtrl,
                      decoration: _inputDecoration('Kode Proyek', Icons.tag),
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _deskripsiCtrl,
                      decoration: _inputDecoration('Deskripsi (opsional)', Icons.notes_outlined),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    // Date row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startCtrl,
                            readOnly: true,
                            onTap: () => _pickDate(_startCtrl),
                            decoration: _inputDecoration(
                              'Tanggal Mulai',
                              Icons.play_circle_outline,
                              suffix: const Icon(Icons.calendar_today,
                                  size: 16, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _deadlineCtrl,
                            readOnly: true,
                            onTap: () => _pickDate(_deadlineCtrl),
                            decoration: _inputDecoration(
                              'Deadline',
                              Icons.flag_outlined,
                              suffix: const Icon(Icons.calendar_today,
                                  size: 16, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (templates.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedTemplateId,
                        decoration: _inputDecoration('Template (opsional)', Icons.copy_outlined),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Tanpa Template')),
                          ...templates.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))),
                        ],
                        onChanged: (v) => setState(() => _selectedTemplateId = v),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Text('Buat Proyek',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
