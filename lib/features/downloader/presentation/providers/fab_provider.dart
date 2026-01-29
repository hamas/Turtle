import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FABState {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final String? tooltip;
  final Key? key;

  const FABState({
    required this.icon,
    this.onPressed,
    this.isEnabled = true,
    this.tooltip,
    this.key,
  });

  const FABState.empty()
    : icon = Icons.add,
      onPressed = null,
      isEnabled = false,
      tooltip = null,
      key = null;
}

class FABNotifier extends Notifier<FABState?> {
  @override
  FABState? build() => null;

  void set(FABState? value) => state = value;
}

final fabProvider = NotifierProvider<FABNotifier, FABState?>(FABNotifier.new);
