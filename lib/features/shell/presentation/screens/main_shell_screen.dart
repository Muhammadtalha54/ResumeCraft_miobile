import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/lang.dart';
import '../../../../core/extensions/size_extensions.dart';

/// Main Application Shell fulfilling Section 7.F & 11 of Master Prompt.
/// Implements persistent 4-tab bottom navigation via StatefulNavigationShell.
class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.exit_to_app_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Exit Resume Craft?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.mainText,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to exit the application?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.secondaryText,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // 1. If any nested page or modal can pop
        if (context.canPop()) {
          context.pop();
          return;
        }

        // 2. If user is in a tab other than Home, switch to Home first
        if (navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
          return;
        }

        // 3. If on Home tab and no route remains, confirm exit
        final shouldExit = await _showExitDialog(context);
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onItemTapped,
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.primaryLight,
              elevation: 0,
              height: context.screenHeight * 0.08,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined, color: AppColors.mutedText, size: context.screenWidth * 0.055),
                  selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary, size: context.screenWidth * 0.055),
                  label: Lang.tabHome,
                ),
                NavigationDestination(
                  icon: Icon(Icons.edit_document, color: AppColors.mutedText, size: context.screenWidth * 0.055),
                  selectedIcon: Icon(Icons.edit_document, color: AppColors.primary, size: context.screenWidth * 0.055),
                  label: Lang.tabCreateResume,
                ),
                NavigationDestination(
                  icon: Icon(Icons.work_outline_rounded, color: AppColors.mutedText, size: context.screenWidth * 0.055),
                  selectedIcon: Icon(Icons.work_rounded, color: AppColors.primary, size: context.screenWidth * 0.055),
                  label: Lang.tabSearchJobs,
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded, color: AppColors.mutedText, size: context.screenWidth * 0.055),
                  selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary, size: context.screenWidth * 0.055),
                  label: Lang.tabProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
