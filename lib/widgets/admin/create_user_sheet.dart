import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/constants.dart';

const kRoleColors = {
  'admin': Color(0xFFDC2626),
  'admin_galangan': Color(0xFFEF4444),
  'yard': Color(0xFF3B82F6),
  'class': Color(0xFF10B981),
  'os': Color(0xFFF59E0B),
  'stat': Color(0xFF8B5CF6),
};

/// Modern bottom-sheet form to create a new user account.
/// Open with [showModalBottomSheet] (isScrollControlled: true, useSafeArea: true).
class CreateUserSheet extends StatefulWidget {
  const CreateUserSheet({super.key});

  @override
  State<CreateUserSheet> createState() => _CreateUserSheetState();
}

class _CreateUserSheetState extends State<CreateUserSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _selectedRole = 'yard';
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<AdminProvider>().createUser(
      name: _nameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: _selectedRole,
      onError: (msg) => messenger.showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      ),
    );
    if (mounted) setState(() => _loading = false);
    if (ok) {
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Akun berhasil dibuat'),
            backgroundColor: Color(0xFF10B981)),
      );
      nav.pop();
    }
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
                  child: const Icon(Icons.person_add_outlined,
                      color: Color(0xFFDC2626), size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tambah Akun',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Buat akun pengguna baru',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF64748B))),
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
                    _inputField(
                      controller: _nameCtrl,
                      label: 'Nama Lengkap',
                      icon: Icons.badge_outlined,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),
                    _inputField(
                      controller: _usernameCtrl,
                      label: 'Username',
                      icon: Icons.alternate_email,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Username wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: const Color(0xFF94A3B8),
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.length < 4) ? 'Min 4 karakter' : null,
                    ),
                    const SizedBox(height: 20),
                    const Text('Pilih Role',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151))),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.roles.map((role) {
                        final selected = _selectedRole == role;
                        final color =
                            kRoleColors[role] ?? const Color(0xFF64748B);
                        final label =
                            AppConstants.roleLabels[role] ?? role;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedRole = role),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: selected ? color : color.withAlpha(12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? color
                                    : color.withAlpha(50),
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color:
                                    selected ? Colors.white : color,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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
                            : const Text('Buat Akun',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
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

  InputDecoration _inputDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
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

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        decoration: _inputDecoration(label, icon),
        validator: validator,
      );
}
