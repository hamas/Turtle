import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turtle/features/home/presentation/pages/home_page.dart';
import 'package:turtle/features/settings/presentation/pages/settings_page.dart';
import 'package:turtle/features/history/presentation/pages/history_page.dart';
import 'package:turtle/core/services/clipboard_service.dart';

class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  @override
  set state(int value) => super.state = value;
}

final navigationIndexProvider = NotifierProvider<NavigationIndexNotifier, int>(
  NavigationIndexNotifier.new,
);

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clipboardServiceProvider).checkClipboard(ref, context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(clipboardServiceProvider).checkClipboard(ref, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    // Defined Pages: 0: Home, 1: Settings, 2: History
    final pages = [const HomePage(), const SettingsPage(), const HistoryPage()];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Ensure index is valid
          pages[selectedIndex < pages.length ? selectedIndex : 0],
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Center(
              child: _buildFloatingToolbar(context, ref, selectedIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingToolbar(
    BuildContext context,
    WidgetRef ref,
    int selectedIndex,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // Common styling
    const double height = 64;
    const double iconSize = 20;
    const double gap = 2;
    const Radius outerRadius = Radius.circular(32);
    const Radius innerRadius = Radius.circular(4);
    const double buttonElevation = 6.0;

    // Static color for all buttons
    final Color baseColor = colorScheme.primaryContainer;

    // Selected color: Base color + 20% Black Overlay
    final Color selectedColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.2),
      baseColor,
    );

    // Content is always onPrimaryContainer
    final Color contentColor = colorScheme.onPrimaryContainer;

    Color getBackgroundColor(bool isSelected) {
      return isSelected ? selectedColor : baseColor;
    }

    // Helper for dynamic radius
    BorderRadius getRadius(
      bool isSelected, {
      bool isLeft = false,
      bool isRight = false,
    }) {
      if (isSelected) {
        return BorderRadius.circular(100);
      }
      if (isLeft) {
        return const BorderRadius.horizontal(
          left: outerRadius,
          right: innerRadius,
        );
      }
      if (isRight) {
        return const BorderRadius.horizontal(
          left: innerRadius,
          right: outerRadius,
        );
      }
      // Center default
      return const BorderRadius.all(innerRadius);
    }

    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Settings Segment (Index 1)
          Material(
            elevation: buttonElevation,
            shadowColor: Colors.black26,
            color: getBackgroundColor(selectedIndex == 1),
            borderRadius: getRadius(selectedIndex == 1, isLeft: true),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => ref.read(navigationIndexProvider.notifier).state = 1,
              child: Container(
                height: height,
                width: 64, // Square-ish
                alignment: Alignment.center,
                child: Icon(
                  selectedIndex == 1
                      ? Icons.settings_rounded
                      : Icons.settings_outlined,
                  color: contentColor,
                  size: iconSize,
                ),
              ),
            ),
          ),

          const SizedBox(width: gap),

          // 2. Home Segment (Index 0)
          Material(
            elevation: buttonElevation,
            shadowColor: Colors.black26,
            color: getBackgroundColor(selectedIndex == 0),
            borderRadius: getRadius(selectedIndex == 0), // Center
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => ref.read(navigationIndexProvider.notifier).state = 0,
              child: Container(
                height: height,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                ), // WIDE padding
                child: Icon(
                  selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
                  color: contentColor,
                  size: iconSize,
                ),
              ),
            ),
          ),

          const SizedBox(width: gap),

          // 3. History Segment (Index 2)
          Material(
            elevation: buttonElevation,
            shadowColor: Colors.black26,
            color: getBackgroundColor(selectedIndex == 2),
            borderRadius: getRadius(selectedIndex == 2, isRight: true),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => ref.read(navigationIndexProvider.notifier).state = 2,
              child: Container(
                height: height,
                width: 64, // Square-ish
                alignment: Alignment.center,
                child: Icon(
                  selectedIndex == 2
                      ? Icons
                            .history_rounded // Filled/Rounded same? No, typically exists
                      : Icons.history_outlined, // Outlined variant
                  color: contentColor,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
