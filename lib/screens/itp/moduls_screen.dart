import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/itp_provider.dart';
import '../../models/modul_model.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_view.dart';
import '../../widgets/common/loading_overlay.dart';

class ModulsScreen extends StatefulWidget {
  final int projectId;
  const ModulsScreen({required this.projectId, super.key});

  @override
  State<ModulsScreen> createState() => _ModulsScreenState();
}

class _ModulsScreenState extends State<ModulsScreen> {
  List<ModulModel> _moduls = [];
  Map<String, dynamic>? _project;
  int? _dayN;
  bool _loading = true;
  String? _error;

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
    final result = await context.read<ItpProvider>().getModuls(widget.projectId);
    if (mounted) {
      setState(() {
        _loading = false;
        if (result != null) {
          _moduls = result['moduls'] as List<ModulModel>;
          final p = result['project'];
          _project = p is Map ? p.cast<String, dynamic>() : null;
          _dayN = result['day_n'] is int ? result['day_n'] as int : int.tryParse('${result['day_n']}');
        } else {
          _error = context.read<ItpProvider>().error;
        }
      });
    }
  }

  String get _projectName => _project?['nama_project'] as String? ?? '';
  String get _projectCode => _project?['kode_project'] as String? ?? '';
  String? get _deadline => _project?['deadline'] as String?;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_projectName.isEmpty ? 'Modul' : _projectName),
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
                      SliverToBoxAdapter(child: _buildHeaderCard()),
                      if (_moduls.isEmpty)
                        const SliverFillRemaining(
                          child: EmptyView(message: 'Belum ada modul di project ini'),
                        )
                      else
                        ..._buildPhaseSlivers(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeaderCard() {
    final deadlineText = _formatDeadline(_deadline);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primary.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(25),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_boat, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _projectName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Kode: $_projectCode${deadlineText != null ? '  •  Deadline: $deadlineText' : ''}',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                if (_dayN != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withAlpha(70)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.today_outlined, size: 13, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          'Hari ke-$_dayN',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeaderChip(
                      label: '${_moduls.length} Modul',
                      icon: Icons.layers_outlined,
                    ),
                    _HeaderChip(
                      label: '${_moduls.where((m) => m.isActive).length} Aktif',
                      icon: Icons.bolt,
                    ),
                    _HeaderChip(
                      label: '${_moduls.where((m) => m.isCompleted).length} Selesai',
                      icon: Icons.check_circle_outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Group moduls into phases by start_day (§3.2), preserving order.
  List<Widget> _buildPhaseSlivers() {
    final phaseKeys = <int?>[];
    final phases = <int?, List<ModulModel>>{};
    for (final m in _moduls) {
      if (!phases.containsKey(m.startDay)) {
        phaseKeys.add(m.startDay);
        phases[m.startDay] = [];
      }
      phases[m.startDay]!.add(m);
    }
    // Sort phases by start day; unscheduled (null) goes last.
    phaseKeys.sort((a, b) {
      if (a == null) return 1;
      if (b == null) return -1;
      return a.compareTo(b);
    });

    final slivers = <Widget>[];
    for (var p = 0; p < phaseKeys.length; p++) {
      final key = phaseKeys[p];
      final items = phases[key]!;
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'FASE ${p + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                key != null ? 'Mulai hari ke-$key' : 'Belum dijadwalkan',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ));
      slivers.add(SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 242,
          ),
          itemCount: items.length,
          itemBuilder: (context, i) => _ModulCard(
            modul: items[i],
            projectId: widget.projectId,
            index: _moduls.indexOf(items[i]),
          ),
        ),
      ));
    }
    return slivers;
  }

  String? _formatDeadline(String? dateStr) {
    if (dateStr == null) return null;
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _HeaderChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModulCard extends StatelessWidget {
  final ModulModel modul;
  final int projectId;
  final int index;

  const _ModulCard({
    required this.modul,
    required this.projectId,
    required this.index,
  });

  static const _primary = Color(0xFFDC2626);
  static const _success = Color(0xFF10B981);
  static const _textMain = Color(0xFF1E293B);
  static const _textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final percent = modul.progress.percent;

    Color accentColor;
    IconData stateIcon;
    String badgeLabel;
    Color badgeBg, badgeText, badgeBorder;

    if (modul.isLocked) {
      accentColor = const Color(0xFF9CA3AF);
      stateIcon = Icons.lock_outline;
      badgeLabel = 'Terkunci';
      badgeBg = const Color(0xFFF9FAFB);
      badgeText = const Color(0xFF9CA3AF);
      badgeBorder = const Color(0xFFE5E7EB);
    } else if (modul.isCompleted) {
      accentColor = _success;
      stateIcon = Icons.check_circle_outline;
      badgeLabel = 'Selesai';
      badgeBg = const Color(0xFFF0FDF4);
      badgeText = const Color(0xFF059669);
      badgeBorder = const Color(0xFFBBF7D0);
    } else {
      accentColor = _primary;
      stateIcon = Icons.bolt;
      final daysLeft = modul.lockInfo?.daysRemaining;
      badgeLabel = daysLeft != null ? '$daysLeft hari tersisa' : 'Sedang Berjalan';
      badgeBg = const Color(0xFFFEF2F2);
      badgeText = _primary;
      badgeBorder = const Color(0xFFFECACA);
    }

    // Extract modul number from name
    final numMatch = RegExp(r'Modul\s*(\d+)', caseSensitive: false).firstMatch(modul.namaModul);
    final modulNum = numMatch?.group(1) ?? '${index + 1}';

    return GestureDetector(
      onTap: modul.isLocked
          ? null
          : () => context.go('/home/projects/$projectId/moduls/${modul.id}/bloks'),
      child: Opacity(
        opacity: modul.isLocked ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: modul.isActive
                  ? _primary.withAlpha(60)
                  : modul.isCompleted
                      ? _success.withAlpha(50)
                      : const Color(0xFFE2E8F0),
              width: modul.isActive ? 1.5 : 1,
            ),
            boxShadow: modul.isActive
                ? [
                    BoxShadow(
                      color: _primary.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    )
                  ],
          ),
          child: Column(
            children: [
              // Top accent bar
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accentColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(stateIcon, color: accentColor, size: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'MODUL $modulNum',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: _textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        modul.namaModul,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textMain,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: badgeBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(stateIcon, size: 9, color: badgeText),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                badgeLabel,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: badgeText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (modul.isActive && modul.lockInfo?.timePercent != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hari ${modul.lockInfo!.daysElapsed ?? 0}',
                              style: const TextStyle(fontSize: 8, color: _textMuted),
                            ),
                            Text(
                              '${modul.lockInfo!.timePercent}%',
                              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: _textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: (modul.lockInfo!.timePercent ?? 0) / 100,
                            minHeight: 4,
                            backgroundColor: _primary.withAlpha(20),
                            valueColor: const AlwaysStoppedAnimation(_primary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Footer progress
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFBFC),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                  border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${modul.progress.done}/${modul.progress.total}',
                          style: const TextStyle(fontSize: 9, color: _textMuted),
                        ),
                        Text(
                          '$percent%',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: percent == 100 ? _success : accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percent == 100 ? _success : accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
