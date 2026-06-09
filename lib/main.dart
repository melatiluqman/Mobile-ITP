import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/router.dart' show createRouter;
import 'providers/auth_provider.dart';
import 'providers/itp_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/message_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ItpProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return MaterialApp.router(
          title: 'ITP System',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFDC2626),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F172A),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
            ),
            cardTheme: CardThemeData(
              elevation: 1,
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                elevation: 0,
              ),
            ),
          ),
          routerConfig: _router,
          builder: (context, child) {
            // Keep layouts consistent across devices: respect the user's font
            // size setting but cap it so larger system fonts don't overflow
            // fixed-height cards/rows.
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(
                textScaler: mq.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.1),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
