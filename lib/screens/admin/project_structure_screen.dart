import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/admin_model.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/confirm_dialog.dart';

class ProjectStructureScreen extends StatefulWidget {
  final int projectId;
  const ProjectStructureScreen({required this.projectId, super.key});

  @override
  State<ProjectStructureScreen> createState() => _ProjectStructureScreenState();
}

class _ProjectStructureScreenState extends State<ProjectStructureScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadStructure(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Kelola Struktur Proyek'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AdminProvider>().loadStructure(widget.projectId),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.structureLoading && provider.structure == null) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)));
          }
          if (provider.structure == null) {
            return ErrorView(
              message: provider.error ?? 'Gagal memuat struktur',
              onRetry: () => provider.loadStructure(widget.projectId),
            );
          }
          final structure = provider.structure!;
          final projectName = structure.project['nama_project'] as String? ?? '';
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Project header
              _SectionHeader(
                icon: Icons.folder_outlined,
                title: projectName,
                color: const Color(0xFF0F172A),
                onAdd: () => _showAddModulDialog(context, provider),
                addLabel: 'Tambah Modul',
              ),
              const SizedBox(height: 8),
              if (structure.moduls.isEmpty)
                _EmptyItem(label: 'Belum ada modul. Tambah modul terlebih dahulu.')
              else
                ...structure.moduls.map((m) => _ModulTile(
                      modul: m,
                      projectId: widget.projectId,
                      provider: provider,
                    )),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _showAddModulDialog(BuildContext context, AdminProvider provider) {
    showDialog(
      context: context,
      builder: (_) => _SimpleInputDialog(
        title: 'Tambah Modul',
        label: 'Nama Modul',
        icon: Icons.view_module_outlined,
        color: const Color(0xFF3B82F6),
        onSubmit: (value) => provider.addModul(
          widget.projectId,
          value,
          onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Modul Tile
// ──────────────────────────────────────────────────────────────

class _ModulTile extends StatefulWidget {
  final ModulStructureModel modul;
  final int projectId;
  final AdminProvider provider;
  const _ModulTile({required this.modul, required this.projectId, required this.provider});

  @override
  State<_ModulTile> createState() => _ModulTileState();
}

class _ModulTileState extends State<_ModulTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasSchedule = widget.modul.startDay != null && widget.modul.durationDays != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Modul header
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.view_module_outlined, color: Color(0xFF3B82F6), size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.modul.namaModul,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        if (hasSchedule)
                          Text(
                            'Hari ${widget.modul.startDay} – ${widget.modul.startDay! + widget.modul.durationDays! - 1} (${widget.modul.durationDays} hari)',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          const Text('Jadwal belum diatur',
                              style: TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                        Text(
                          '${widget.modul.bloks.length} blok',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                  // Schedule button
                  IconButton(
                    icon: const Icon(Icons.schedule, size: 18, color: Color(0xFFF59E0B)),
                    tooltip: 'Atur Jadwal',
                    onPressed: () => _showScheduleDialog(context),
                  ),
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                    onPressed: () => _deleteModul(context),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          if (_expanded) ...[
            const Divider(height: 1, indent: 14, endIndent: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('BLOK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                      letterSpacing: 0.8, color: Color(0xFF94A3B8))),
                  TextButton.icon(
                    onPressed: () => _showAddBlokDialog(context),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Tambah Blok', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                  ),
                ],
              ),
            ),
            if (widget.modul.bloks.isEmpty)
              _EmptyItem(label: 'Belum ada blok')
            else
              ...widget.modul.bloks.map((b) => _BlokTile(
                    blok: b,
                    projectId: widget.projectId,
                    provider: widget.provider,
                  )),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Future<void> _deleteModul(BuildContext context) async {
    final confirmed = await showConfirmDialog(context,
        title: 'Hapus Modul', content: 'Hapus "${widget.modul.namaModul}" dan semua isinya?');
    if (confirmed && context.mounted) {
      widget.provider.removeModul(widget.modul.id, widget.projectId,
          onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red)));
    }
  }

  void _showScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _ScheduleDialog(
        modul: widget.modul,
        onSubmit: (start, duration) => widget.provider.setModulSchedule(
          widget.modul.id, widget.projectId, start, duration,
          onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red)),
        ),
      ),
    );
  }

  void _showAddBlokDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _SimpleInputDialog(
        title: 'Tambah Blok',
        label: 'Nama Blok',
        icon: Icons.layers_outlined,
        color: const Color(0xFF10B981),
        onSubmit: (value) => widget.provider.addBlok(
          widget.modul.id, widget.projectId, value,
          onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red)),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Blok Tile
// ──────────────────────────────────────────────────────────────

class _BlokTile extends StatefulWidget {
  final BlokStructureModel blok;
  final int projectId;
  final AdminProvider provider;
  const _BlokTile({required this.blok, required this.projectId, required this.provider});

  @override
  State<_BlokTile> createState() => _BlokTileState();
}

class _BlokTileState extends State<_BlokTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Row(
                  children: [
                    const Icon(Icons.layers_outlined, color: Color(0xFF10B981), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.blok.namaBlok,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('${widget.blok.subBloks.length} sub-blok',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC2626)),
                      onPressed: () => _deleteBlok(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xFF94A3B8), size: 18),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              const Divider(height: 1, indent: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SUB-BLOK', style: TextStyle(fontSize: 10,
                        fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF94A3B8))),
                    TextButton.icon(
                      onPressed: () => _showAddSubBlokDialog(context),
                      icon: const Icon(Icons.add, size: 13),
                      label: const Text('Tambah Sub-Blok', style: TextStyle(fontSize: 11)),
                      style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2)),
                    ),
                  ],
                ),
              ),
              if (widget.blok.subBloks.isEmpty)
                _EmptyItem(label: 'Belum ada sub-blok')
              else
                ...widget.blok.subBloks.map((s) => _SubBlokTile(
                      subBlok: s,
                      projectId: widget.projectId,
                      provider: widget.provider,
                    )),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _deleteBlok(BuildContext context) async {
    final confirmed = await showConfirmDialog(context,
        title: 'Hapus Blok', content: 'Hapus "${widget.blok.namaBlok}" dan semua isinya?');
    if (confirmed && context.mounted) {
      widget.provider.removeBlok(widget.blok.id, widget.projectId,
          onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red)));
    }
  }

  void _showAddSubBlokDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _SimpleInputDialog(
        title: 'Tambah Sub-Blok',
        label: 'Nama Sub-Blok',
        icon: Icons.view_agenda_outlined,
        color: const Color(0xFF8B5CF6),
        onSubmit: (value) => widget.provider.addSubBlok(
          widget.blok.id, widget.projectId, value,
          onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red)),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Sub-Blok Tile
// ──────────────────────────────────────────────────────────────

class _SubBlokTile extends StatefulWidget {
  final SubBlokStructureModel subBlok;
  final int projectId;
  final AdminProvider provider;
  const _SubBlokTile({required this.subBlok, required this.projectId, required this.provider});

  @override
  State<_SubBlokTile> createState() => _SubBlokTileState();
}

class _SubBlokTileState extends State<_SubBlokTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                child: Row(
                  children: [
                    const Icon(Icons.view_agenda_outlined, color: Color(0xFF8B5CF6), size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.subBlok.namaSubBlok,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          Text('${widget.subBlok.itps.length} kode inspeksi',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 14, color: Color(0xFFDC2626)),
                      onPressed: () => _deleteSubBlok(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                    Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xFF94A3B8), size: 16),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              const Divider(height: 1, indent: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('KODE INSPEKSI', style: TextStyle(fontSize: 9,
                        fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF94A3B8))),
                    TextButton.icon(
                      onPressed: () => _showAddItpDialog(context),
                      icon: const Icon(Icons.add, size: 12),
                      label: const Text('Tambah ITP', style: TextStyle(fontSize: 10)),
                      style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2)),
                    ),
                  ],
                ),
              ),
              if (widget.subBlok.itps.isEmpty)
                _EmptyItem(label: 'Belum ada kode inspeksi')
              else
                ...widget.subBlok.itps.map((itp) => _ItpRow(
                      itp: itp,
                      projectId: widget.projectId,
                      provider: widget.provider,
                    )),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSubBlok(BuildContext context) async {
    final confirmed = await showConfirmDialog(context,
        title: 'Hapus Sub-Blok', content: 'Hapus "${widget.subBlok.namaSubBlok}" dan semua isinya?');
    if (confirmed && context.mounted) {
      widget.provider.removeSubBlok(widget.subBlok.id, widget.projectId,
          onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red)));
    }
  }

  void _showAddItpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _AddItpDialog(
        subBlokId: widget.subBlok.id,
        projectId: widget.projectId,
        provider: widget.provider,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// ITP Row
// ──────────────────────────────────────────────────────────────

class _ItpRow extends StatelessWidget {
  final ItpStructureModel itp;
  final int projectId;
  final AdminProvider provider;
  const _ItpRow({required this.itp, required this.projectId, required this.provider});

  Color _valColor(String val) {
    switch (val.toUpperCase()) {
      case 'W': return const Color(0xFFF59E0B);
      case 'RV': return const Color(0xFF3B82F6);
      case 'NA': return const Color(0xFF94A3B8);
      default: return const Color(0xFFE2E8F0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        flex: 0,
                        child: Text(itp.code,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: Color(0xFFDC2626)),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withAlpha(10),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(itp.assemblyCode,
                              style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                  Text(itp.item,
                      style: const TextStyle(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _ValChip('Y', itp.yardVal),
                      const SizedBox(width: 3),
                      _ValChip('C', itp.classVal),
                      const SizedBox(width: 3),
                      _ValChip('O', itp.osVal),
                      const SizedBox(width: 3),
                      _ValChip('S', itp.statVal),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 14, color: Color(0xFFDC2626)),
              onPressed: () async {
                final confirmed = await showConfirmDialog(context,
                    title: 'Hapus Kode ITP', content: 'Hapus kode "${itp.code}"?');
                if (confirmed && context.mounted) {
                  provider.removeItp(itp.id, projectId,
                      onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msg), backgroundColor: Colors.red)));
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _ValChip(String role, String val) {
    final color = _valColor(val);
    final textColor = val == '-' ? const Color(0xFF94A3B8) : Colors.white;
    final bg = val == '-' ? const Color(0xFFE2E8F0) : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text('$role:$val', style: TextStyle(fontSize: 8, color: textColor, fontWeight: FontWeight.w700)),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Shared helper widgets
// ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onAdd;
  final String addLabel;
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
    required this.onAdd,
    required this.addLabel,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                overflow: TextOverflow.ellipsis),
          ),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 15),
            label: Text(addLabel, style: const TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
          ),
        ],
      );
}

class _EmptyItem extends StatelessWidget {
  final String label;
  const _EmptyItem({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8),
                fontStyle: FontStyle.italic)),
      );
}

// ──────────────────────────────────────────────────────────────
// Dialogs
// ──────────────────────────────────────────────────────────────

class _SimpleInputDialog extends StatefulWidget {
  final String title;
  final String label;
  final IconData icon;
  final Color color;
  final Future<bool> Function(String) onSubmit;
  const _SimpleInputDialog({
    required this.title,
    required this.label,
    required this.icon,
    required this.color,
    required this.onSubmit,
  });

  @override
  State<_SimpleInputDialog> createState() => _SimpleInputDialogState();
}

class _SimpleInputDialogState extends State<_SimpleInputDialog> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.icon, color: widget.color, size: 20),
          const SizedBox(width: 8),
          Text(widget.title, style: const TextStyle(fontSize: 16)),
        ],
      ),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: InputDecoration(labelText: widget.label, border: const OutlineInputBorder()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: widget.color, foregroundColor: Colors.white),
          onPressed: _loading
              ? null
              : () async {
                  if (_ctrl.text.trim().isEmpty) return;
                  setState(() => _loading = true);
                  final nav = Navigator.of(context);
                  final ok = await widget.onSubmit(_ctrl.text.trim());
                  if (ok && mounted) nav.pop();
                  if (mounted) setState(() => _loading = false);
                },
          child: _loading
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Simpan'),
        ),
      ],
    );
  }
}

class _ScheduleDialog extends StatefulWidget {
  final ModulStructureModel modul;
  final Future<bool> Function(int, int) onSubmit;
  const _ScheduleDialog({required this.modul, required this.onSubmit});

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  late final TextEditingController _startCtrl;
  late final TextEditingController _durationCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _startCtrl = TextEditingController(
        text: widget.modul.startDay?.toString() ?? '');
    _durationCtrl = TextEditingController(
        text: widget.modul.durationDays?.toString() ?? '');
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.schedule, color: Color(0xFFF59E0B), size: 20),
          SizedBox(width: 8),
          Text('Atur Jadwal Modul', style: TextStyle(fontSize: 15)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.modul.namaModul,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: _startCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Mulai Hari ke-',
              border: OutlineInputBorder(),
              helperText: 'Dihitung dari tanggal mulai proyek',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _durationCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Durasi (hari)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
          onPressed: _loading
              ? null
              : () async {
                  final start = int.tryParse(_startCtrl.text.trim());
                  final duration = int.tryParse(_durationCtrl.text.trim());
                  if (start == null || duration == null || start < 1 || duration < 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Masukkan angka valid (min 1)')));
                    return;
                  }
                  setState(() => _loading = true);
                  final nav = Navigator.of(context);
                  final ok = await widget.onSubmit(start, duration);
                  if (ok && mounted) nav.pop();
                  if (mounted) setState(() => _loading = false);
                },
          child: _loading
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Simpan'),
        ),
      ],
    );
  }
}

class _AddItpDialog extends StatefulWidget {
  final int subBlokId;
  final int projectId;
  final AdminProvider provider;
  const _AddItpDialog({required this.subBlokId, required this.projectId, required this.provider});

  @override
  State<_AddItpDialog> createState() => _AddItpDialogState();
}

class _AddItpDialogState extends State<_AddItpDialog> {
  final _formKey = GlobalKey<FormState>();
  final _assemblyCodeCtrl = TextEditingController();
  final _assemblyDescCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _itemCtrl = TextEditingController();
  String _yardVal = '-';
  String _classVal = '-';
  String _osVal = '-';
  String _statVal = '-';
  bool _loading = false;

  static const _valOptions = ['W', 'RV', '-', 'NA'];

  @override
  void dispose() {
    _assemblyCodeCtrl.dispose();
    _assemblyDescCtrl.dispose();
    _codeCtrl.dispose();
    _itemCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.assignment_outlined, color: Color(0xFFDC2626), size: 20),
          SizedBox(width: 8),
          Text('Tambah Kode ITP', style: TextStyle(fontSize: 15)),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _assemblyCodeCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Assembly Code', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _codeCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Kode ITP', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _assemblyDescCtrl,
                decoration: const InputDecoration(
                    labelText: 'Deskripsi Assembly', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _itemCtrl,
                decoration: const InputDecoration(
                    labelText: 'Item/Deskripsi Pekerjaan', border: OutlineInputBorder()),
                maxLines: 2,
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib' : null,
              ),
              const SizedBox(height: 12),
              const Text('NILAI PARTISIPASI',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                      letterSpacing: 0.8, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              _valRow('Yard', _yardVal, (v) => setState(() => _yardVal = v)),
              _valRow('Class', _classVal, (v) => setState(() => _classVal = v)),
              _valRow('OS', _osVal, (v) => setState(() => _osVal = v)),
              _valRow('Stat', _statVal, (v) => setState(() => _statVal = v)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
          onPressed: _loading
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _loading = true);
                  final nav = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await widget.provider.addItp(
                    widget.projectId,
                    subBlokId: widget.subBlokId,
                    assemblyCode: _assemblyCodeCtrl.text.trim(),
                    assemblyDescription: _assemblyDescCtrl.text.trim().isEmpty
                        ? null
                        : _assemblyDescCtrl.text.trim(),
                    code: _codeCtrl.text.trim(),
                    item: _itemCtrl.text.trim(),
                    yardVal: _yardVal,
                    classVal: _classVal,
                    osVal: _osVal,
                    statVal: _statVal,
                    onError: (msg) => messenger.showSnackBar(
                        SnackBar(content: Text(msg), backgroundColor: Colors.red)),
                  );
                  if (ok && mounted) nav.pop();
                  if (mounted) setState(() => _loading = false);
                },
          child: _loading
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Simpan'),
        ),
      ],
    );
  }

  Widget _valRow(String role, String currentVal, void Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(role,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          ..._valOptions.map((v) {
            final selected = currentVal == v;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(v),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? _valBg(v) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: selected ? _valBg(v) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      v,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _valBg(String v) {
    switch (v) {
      case 'W': return const Color(0xFFF59E0B);
      case 'RV': return const Color(0xFF3B82F6);
      case 'NA': return const Color(0xFF94A3B8);
      default: return const Color(0xFFCBD5E1);
    }
  }
}
