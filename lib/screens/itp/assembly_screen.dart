import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/itp_provider.dart';
import '../../models/itp_model.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_view.dart';
import '../../widgets/common/loading_overlay.dart';

class AssemblyScreen extends StatefulWidget {
  final int subblokId;
  const AssemblyScreen({required this.subblokId, super.key});

  @override
  State<AssemblyScreen> createState() => _AssemblyScreenState();
}

class _AssemblyScreenState extends State<AssemblyScreen> {
  List<AssemblyGroupModel> _assemblies = [];
  String _subblokName = '';
  bool _loading = true;
  String? _error;
  String _searchQuery = '';

  static const _primary = Color(0xFFDC2626);
  static const _primaryDark = Color(0xFF991B1B);
  static const _navy = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final result = await context.read<ItpProvider>().getAssembly(widget.subblokId);
    if (mounted) {
      setState(() {
        _loading = false;
        if (result != null) {
          _assemblies = result['assemblies'] as List<AssemblyGroupModel>;
          final s = result['subblok'];
          _subblokName = s is Map ? s['nama_sub_blok'] as String? ?? '' : '';
        } else {
          _error = context.read<ItpProvider>().error;
        }
      });
    }
  }

  List<AssemblyGroupModel> get _filtered {
    if (_searchQuery.isEmpty) return _assemblies;
    final q = _searchQuery.toLowerCase();
    return _assemblies.where((group) {
      if (group.assemblyCode.toLowerCase().contains(q)) return true;
      return group.inspections.any(
        (itp) => itp.code.toLowerCase().contains(q) || itp.item.toLowerCase().contains(q),
      );
    }).toList();
  }

  int get _totalItp => _assemblies.fold(0, (sum, g) => sum + g.inspections.length);
  int get _approvedItp => _assemblies.fold(
        0,
        (sum, g) => sum + g.inspections.where((i) => i.myData?.status == 'approved').length,
      );

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final basePath = currentPath.contains('/assembly')
        ? currentPath.split('/assembly').first
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(_subblokName.isEmpty ? 'Assembly' : _subblokName),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  color: _primary,
                  onRefresh: _load,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader()),
                      SliverToBoxAdapter(child: _buildSummary()),
                      SliverToBoxAdapter(child: _buildQuickInfo()),
                      SliverToBoxAdapter(child: _buildSearch()),
                      if (_filtered.isEmpty)
                        const SliverFillRemaining(
                          child: EmptyView(message: 'Tidak ada kode inspeksi tersedia'),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => _AssemblyCard(
                                group: _filtered[i],
                                basePath: basePath,
                              ),
                              childCount: _filtered.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(25),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(Icons.layers, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _subblokName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const Text(
                        'Kelola dan pantau status inspeksi ITP',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final percent = _totalItp > 0 ? ((_approvedItp / _totalItp) * 100).round() : 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _SummaryItem(value: '$_totalItp', label: 'Total ITP', color: const Color(0xFF1E293B)),
              Container(width: 1, height: 36, color: const Color(0xFFE2E8F0), margin: const EdgeInsets.symmetric(horizontal: 20)),
              _SummaryItem(value: '$_approvedItp', label: 'Approved', color: _primary),
              const Spacer(),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: percent == 100 ? const Color(0xFF10B981) : _primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Keseluruhan Progres ACC', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: _totalItp > 0 ? _approvedItp / _totalItp : 0,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                percent == 100 ? const Color(0xFF10B981) : _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _primary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.info_outline, color: _primary, size: 16),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Klik baris ITP untuk upload data.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
                ),
                SizedBox(height: 2),
                Text(
                  'Status ACC berarti telah disetujui Class/Owner.',
                  style: TextStyle(fontSize: 11, color: Color(0xFFB91C1C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Cari kode assembly atau item inspeksi...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _SummaryItem({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
      ],
    );
  }
}

class _AssemblyCard extends StatefulWidget {
  final AssemblyGroupModel group;
  final String basePath;
  const _AssemblyCard({required this.group, required this.basePath});

  @override
  State<_AssemblyCard> createState() => _AssemblyCardState();
}

class _AssemblyCardState extends State<_AssemblyCard> {
  bool _expanded = false;

  static const _primary = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final count = widget.group.inspections.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(14),
              bottom: _expanded ? Radius.zero : const Radius.circular(14),
            ),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.memory, color: Color(0xFFDC2626), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.group.assemblyCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count Kode',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8), size: 20),
                  ),
                ],
              ),
            ),
          ),

          // Expanded: work steps + inspection rows
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                // Work steps if any
                if (widget.group.assemblyDescription != null &&
                    widget.group.assemblyDescription!.isNotEmpty)
                  _WorkStepsSection(description: widget.group.assemblyDescription!),
                // Inspection rows
                ...widget.group.inspections.map((itp) => _InspectionRow(
                      itp: itp,
                      basePath: widget.basePath,
                    )),
              ],
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _WorkStepsSection extends StatelessWidget {
  final String description;
  const _WorkStepsSection({required this.description});

  @override
  Widget build(BuildContext context) {
    final steps = description.split(RegExp(r'\r\n|\r|\n')).where((s) => s.trim().isNotEmpty).toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCFC),
        border: Border(bottom: BorderSide(color: Color(0xFFFEE2E2))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withAlpha(18),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.checklist, size: 11, color: Color(0xFFDC2626)),
                SizedBox(width: 4),
                Text(
                  'WORK STEPS / ITEMS TO CHECK',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFDC2626),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...steps.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${e.key + 1}.',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        e.value.trim(),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _InspectionRow extends StatelessWidget {
  final InspectionModel itp;
  final String basePath;
  const _InspectionRow({required this.itp, required this.basePath});

  Color get _statusColor {
    if (itp.myData == null) return const Color(0xFFE2E8F0);
    switch (itp.myData!.status) {
      case 'approved': return const Color(0xFFDC2626);
      case 'done': return const Color(0xFF10B981);
      case 'needs_revision': return const Color(0xFFF59E0B);
      default: return const Color(0xFFE2E8F0);
    }
  }

  String get _statusLabel {
    if (!itp.canSubmit) return 'Status';
    if (itp.myData == null) return 'ITP Data';
    switch (itp.myData!.status) {
      case 'approved': return 'ACC';
      case 'done': return 'Selesai';
      case 'needs_revision': return 'Revisi';
      default: return 'ITP Data';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('$basePath/assembly/${itp.id}/detail'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itp.code,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFDC2626),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    itp.item,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _RoleDots(itp: itp),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // My role val badge
                _ValBadge(value: itp.myVal ?? '-'),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(itp.canSubmit ? 230 : 30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: itp.canSubmit ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _RoleDots extends StatelessWidget {
  final InspectionModel itp;
  const _RoleDots({required this.itp});

  @override
  Widget build(BuildContext context) {
    final roles = [
      ('Y', itp.yardVal),
      ('C', itp.classVal),
      ('O', itp.osVal),
      ('S', itp.statVal),
    ];
    return Row(
      children: roles.map((r) {
        final label = r.$1;
        final val = r.$2;
        if (val == null || val.isEmpty || val == '-') return const SizedBox.shrink();
        return _ValChip(label: label, value: val);
      }).toList(),
    );
  }
}

class _ValChip extends StatelessWidget {
  final String label;
  final String? value;
  const _ValChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    final val = value!.toUpperCase();
    Color bg, textColor;
    if (val == 'W') {
      bg = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF92400E);
    } else if (val == 'RV') {
      bg = const Color(0xFFDBEAFE);
      textColor = const Color(0xFF1E40AF);
    } else if (val == 'NA') {
      bg = const Color(0xFFFEE2E2);
      textColor = const Color(0xFF991B1B);
    } else {
      bg = const Color(0xFFF1F5F9);
      textColor = const Color(0xFF94A3B8);
    }
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        '$label:$val',
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: textColor),
      ),
    );
  }
}

class _ValBadge extends StatelessWidget {
  final String value;
  const _ValBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    final val = value.toUpperCase();
    Color bg, textColor;
    if (val == 'W') {
      bg = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF92400E);
    } else if (val == 'RV') {
      bg = const Color(0xFFDBEAFE);
      textColor = const Color(0xFF1E40AF);
    } else if (val == 'NA') {
      bg = const Color(0xFFFEE2E2);
      textColor = const Color(0xFF991B1B);
    } else {
      bg = const Color(0xFFF1F5F9);
      textColor = const Color(0xFF94A3B8);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(val, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: textColor)),
    );
  }
}
