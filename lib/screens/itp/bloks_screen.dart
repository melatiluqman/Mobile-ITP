import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/itp_provider.dart';
import '../../models/blok_model.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_view.dart';
import '../../widgets/common/loading_overlay.dart';

class BloksScreen extends StatefulWidget {
  final int modulId;
  const BloksScreen({required this.modulId, super.key});

  @override
  State<BloksScreen> createState() => _BloksScreenState();
}

class _BloksScreenState extends State<BloksScreen> {
  List<BlokModel> _bloks = [];
  String _modulName = '';
  String _projectId = '';
  bool _loading = true;
  String? _error;

  static const _primary = Color(0xFFDC2626);
  static const _navy = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final result = await context.read<ItpProvider>().getBloks(widget.modulId);
    if (mounted) {
      setState(() {
        _loading = false;
        if (result != null) {
          _bloks = result['bloks'] as List<BlokModel>;
          final m = result['modul'];
          _modulName = m is Map ? m['nama_modul'] as String? ?? '' : '';
          final p = result['project'];
          _projectId = p is Map ? p['id']?.toString() ?? '' : '';
        } else {
          _error = context.read<ItpProvider>().error;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modulName.isEmpty ? 'Blok' : _modulName),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _bloks.isEmpty
                  ? const EmptyView(message: 'Tidak ada blok')
                  : RefreshIndicator(
                      color: _primary,
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
                        itemCount: _bloks.length,
                        itemBuilder: (context, i) => _BlokCard(
                          blok: _bloks[i],
                          modulId: widget.modulId,
                          projectId: _projectId,
                        ),
                      ),
                    ),
    );
  }
}

class _BlokCard extends StatelessWidget {
  final BlokModel blok;
  final int modulId;
  final String projectId;
  const _BlokCard({required this.blok, required this.modulId, required this.projectId});

  static const _primary = Color(0xFFDC2626);
  static const _success = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final percent = blok.progress.percent;
    final progressColor = percent == 100 ? _success : _primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go(
          '/home/projects/$projectId/moduls/$modulId/bloks/${blok.id}/subbloks',
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _primary.withAlpha(18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.view_module_outlined, color: _primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      blok.namaBlok,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${blok.progress.done}/${blok.progress.total} item',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
