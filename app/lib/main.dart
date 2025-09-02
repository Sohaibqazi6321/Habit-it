import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_it/core/router/app_router.dart';
import 'package:habit_it/core/theme/app_theme.dart';
import 'package:habit_it/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseService.initialize();
  
  runApp(
    const ProviderScope(
      child: HabitItApp(),
    ),
  );
}

class HabitItApp extends ConsumerWidget {
  const HabitItApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Habit It',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
