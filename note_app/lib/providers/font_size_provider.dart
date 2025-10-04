import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) => FontSizeNotifier());

class FontSizeNotifier extends StateNotifier<double> {
  static const _key = 'font_size';
  static const double _defaultSize = 16.0;

  FontSizeNotifier() : super(_defaultSize) {
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_key) ?? _defaultSize;
  }

  Future<void> setFontSize(double size) async {
    state = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, size);
  }
}
