import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared mobile shell with a bottom navigation and centered start action.
class AppShellScreen extends StatelessWidget {
  /// Creates the shell screen.
  const AppShellScreen({
    required this.currentLocation,
    required this.child,
    super.key,
  });

  /// Current router location used for bottom-tab selection.
  final String currentLocation;

  /// Active branch content rendered above the bottom bar.
  final Widget child;

  bool get _isQuizBranch => currentLocation.startsWith('/quiz');
  bool get _isQuickQuizFlow => currentLocation.startsWith('/quiz/quick');

  @override
  Widget build(BuildContext context) {
    final isQuizBranch = _isQuizBranch;
    final isQuickQuizFlow = _isQuickQuizFlow;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isQuickQuizFlow
          ? null
          : FloatingActionButton.extended(
              key: const ValueKey('bottom-start-button'),
              tooltip: 'Start',
              onPressed: () => context.go('/quiz/types'),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start'),
            ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              Expanded(
                child: _BottomNavButton(
                  key: const ValueKey('bottom-nav-home'),
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  selected: !isQuizBranch,
                  selectedColor: colorScheme.primary,
                  onPressed: () => context.go('/'),
                ),
              ),
              const SizedBox(width: 76),
              Expanded(
                child: _BottomNavButton(
                  key: const ValueKey('bottom-nav-quiz'),
                  icon: Icons.quiz_outlined,
                  selectedIcon: Icons.quiz_rounded,
                  label: 'Quiz',
                  selected: isQuizBranch,
                  selectedColor: colorScheme.primary,
                  onPressed: () => context.go('/quiz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom navigation action used by the shell screen.
class _BottomNavButton extends StatelessWidget {
  /// Creates the bottom navigation action widget.
  const _BottomNavButton({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onPressed,
    super.key,
  });

  /// Icon used when the destination is not active.
  final IconData icon;

  /// Icon used when the destination is active.
  final IconData selectedIcon;

  /// Text label shown under the icon.
  final String label;

  /// Whether this destination is currently selected.
  final bool selected;

  /// Color used for the selected state.
  final Color selectedColor;

  /// Triggered when the action is tapped.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : Theme.of(context).hintColor;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        shape: const RoundedRectangleBorder(),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? selectedIcon : icon),
          const SizedBox(height: 2),
          Text(label),
        ],
      ),
    );
  }
}
