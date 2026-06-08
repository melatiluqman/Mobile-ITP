import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/itp/project_list_screen.dart';
import '../screens/itp/moduls_screen.dart';
import '../screens/itp/bloks_screen.dart';
import '../screens/itp/subbloks_screen.dart';
import '../screens/itp/assembly_screen.dart';
import '../screens/itp/itp_detail_screen.dart';
import '../screens/messages/message_channels_screen.dart';
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
          routes: [
            GoRoute(
              path: 'projects',
              builder: (context, state) => const ProjectListScreen(),
              routes: [
                GoRoute(
                  path: ':projectId/moduls',
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
              ],
            ),
            GoRoute(
              path: 'messages',
              builder: (context, state) => const MessageChannelsScreen(),
              routes: [
                GoRoute(
                  path: ':projectId/chat',
                  builder: (context, state) => ChatScreen(
                    projectId: int.parse(state.pathParameters['projectId']!),
                    projectName: state.uri.queryParameters['name'] ?? 'Chat',
                  ),
                ),
              ],
            ),
            GoRoute(
              path: 'notifications',
              builder: (context, state) => const NotificationsScreen(),
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
