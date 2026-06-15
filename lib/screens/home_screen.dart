import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import 'itp/project_list_screen.dart';
import 'messages/message_channels_screen.dart';
import 'notifications/notifications_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().loadUnreadCount();
    });
  }

  List<_NavItem> _buildNavItems(bool isAdmin) {
    if (isAdmin) {
      return [
        _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', screen: const AdminDashboardScreen()),
        _NavItem(icon: Icons.chat_bubble_outline, label: 'Pesan', screen: const MessageChannelsScreen()),
        _NavItem(icon: Icons.notifications_outlined, label: 'Notifikasi', screen: const NotificationsScreen()),
        _NavItem(icon: Icons.person_outline, label: 'Profil', screen: const ProfileScreen()),
      ];
    }
    return [
      _NavItem(icon: Icons.assignment_outlined, label: 'Proyek', screen: const ProjectListScreen()),
      _NavItem(icon: Icons.chat_bubble_outline, label: 'Pesan', screen: const MessageChannelsScreen()),
      _NavItem(icon: Icons.notifications_outlined, label: 'Notifikasi', screen: const NotificationsScreen()),
      _NavItem(icon: Icons.person_outline, label: 'Profil', screen: const ProfileScreen()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final msgProvider = context.watch<MessageProvider>();
    final navItems = _buildNavItems(auth.isAdmin);

    if (_selectedIndex >= navItems.length) _selectedIndex = 0;

    return Scaffold(
      body: navItems[_selectedIndex].screen,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          setState(() => _selectedIndex = i);
          // Jaga badge notifikasi tetap segar setiap pindah tab.
          context.read<MessageProvider>().loadUnreadCount();
        },
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFDC2626).withAlpha(20),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: navItems.map((item) {
          if (item.label == 'Notifikasi' && msgProvider.unreadNotifications > 0) {
            return NavigationDestination(
              icon: Badge(
                label: Text('${msgProvider.unreadNotifications}'),
                child: Icon(item.icon),
              ),
              selectedIcon: Icon(item.icon, color: const Color(0xFFDC2626)),
              label: item.label,
            );
          }
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.icon, color: const Color(0xFFDC2626)),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget screen;

  const _NavItem({required this.icon, required this.label, required this.screen});
}
