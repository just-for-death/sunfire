import 'package:flutter/foundation.dart';

/// Service to manage global batch selection mode state.
///
/// This replaces the static [ValueNotifier] on [LibraryScreen] to avoid
/// memory leaks and provide a cleaner architecture for global UI state.
class BatchModeService extends ChangeNotifier {
  BatchModeService._();

  static final BatchModeService instance = BatchModeService._();

  final ValueNotifier<bool> _isBatchMode = ValueNotifier<bool>(false);

  ValueListenable<bool> get isBatchMode => _isBatchMode;

  bool get value => _isBatchMode.value;

  set value(bool v) {
    _isBatchMode.value = v;
  }

  void enable() {
    _isBatchMode.value = true;
  }

  void disable() {
    _isBatchMode.value = false;
  }

  void toggle() {
    _isBatchMode.value = !_isBatchMode.value;
  }

  @override
  void dispose() {
    _isBatchMode.dispose();
    super.dispose();
  }
}