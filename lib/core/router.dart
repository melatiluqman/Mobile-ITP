import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/itp/moduls_screen.dart';
import '../screens/itp/bloks_screen.dart';
import '../screens/itp/subbloks_screen.dart';
import '../screens/itp/assembly_screen.dart';
import '../screens/itp/itp_detail_screen.dart';
import '../screens/messages/chat_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/users_screen.dart';
import '../screens/admin/projects_manage_screen.dart';
import '../screens/admin/project_structure_screen.dart';
import '../screens/admin/activity_logs_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider auth) => GoRouter(
      navigatorKey: _rootKey,
      initialLocation: '/home',
      redirect: (context, state) {
        final loggedIn = auth.isLoggedIn;
        final isLogin = state.matchedLocation == '/login';
        if (!loggedIn && !isLogin) return '/login';
        if (loggedIn && isLogin) return '/home';
        if (state.matchedLocation.startsWith('/admin') && !auth.isAdmin) {
          return '/home';
        }
        return null;
      },
      refreshListenable: auth,
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
          // Catatan: daftar Proyek & Pesan dirender sebagai TAB di dalam HomeScreen,
          // jadi tidak perlu route standalone perantara. Drill-down langsung jadi
          // anak '/home' agar 1x back kembali ke HomeScreen (bottom nav tetap ada).
          routes: [
            GoRoute(
              path: 'projects/:projectId/moduls',
              builder: (context, state) => ModulsScreen(
                projectId: int.parse(state.pathParameters['projectId']!),
              ),
              routes: [
                GoRoute(
                  path: ':modulId/bloks',
                  builder: (context, state) => BloksScreen(
                    modulId: int.parse(state.pathParameters['modulId']!),
                  ),
                  routes: [
                    GoRoute(
                      path: ':blokId/subbloks',
                      builder: (context, state) => SubBloksScreen(
                        blokId: int.parse(state.pathParameters['blokId']!),
                      ),
                      routes: [
                        GoRoute(
                          path: ':subblokId/assembly',
                          builder: (context, state) => AssemblyScreen(
                            subblokId: int.parse(state.pathParameters['subblokId']!),
                          ),
                          routes: [
                            GoRoute(
                              path: ':itpId/detail',
                              builder: (context, state) => ItpDetailScreen(
                                itpId: int.parse(state.pathParameters['itpId']!),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: 'messages/:projectId/chat',
              builder: (context, state) => ChatScreen(
                projectId: int.parse(state.pathParameters['projectId']!),
                projectName: state.uri.queryParameters['name'] ?? 'Chat',
              ),
            ),
            GoRoute(
              path: 'notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
            // Deep-link langsung ke detail ITP (dipakai dari notifikasi).
            // ItpDetailScreen self-contained: cukup itpId, memuat datanya sendiri.
            GoRoute(
              path: 'itp/:itpId',
              builder: (context, state) => ItpDetailScreen(
                itpId: int.parse(state.pathParameters['itpId']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
          routes: [
            GoRoute(path: 'users', builder: (context, state) => const UsersScreen()),
            GoRoute(path: 'projects', builder: (context, state) => const ProjectsManageScreen()),
            GoRoute(
              path: 'projects/:projectId/structure',
              builder: (context, state) => ProjectStructureScreen(
                projectId: int.parse(state.pathParameters['projectId']!),
              ),
            ),
            GoRoute(path: 'logs', builder: (context, state) => const ActivityLogsScreen()),
          ],
        ),
      ],
    );
