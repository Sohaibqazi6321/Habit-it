import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_it/features/habits/presentation/habits_screen.dart';
import 'package:habit_it/features/focus/presentation/focus_screen.dart';
import 'package:habit_it/features/stats/presentation/stats_screen.dart';
import 'package:habit_it/features/settings/presentation/settings_screen.dart';
import 'package:habit_it/features/habits/presentation/add_habit_screen.dart';
import 'package:habit_it/features/billing/presentation/paywall_screen.dart';
import 'package:habit_it/features/shared/presentation/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/habits',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/habits',
            builder: (context, state) => const HabitsScreen(),
          ),
          GoRoute(
            path: '/focus',
            builder: (context, state) => const FocusScreen(),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/add-habit',
        builder: (context, state) => const AddHabitScreen(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
    ],
  );
});
