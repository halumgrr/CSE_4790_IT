import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/font_size_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final fontSize = ref.watch(fontSizeProvider);
    final fontSizeNotifier = ref.read(fontSizeProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontSize: fontSize)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dark Theme', style: TextStyle(fontSize: fontSize)),
                Switch(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (val) {
                    themeNotifier.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ],
            ),
            SizedBox(height: fontSize),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Font Size', style: TextStyle(fontSize: fontSize)),
                Expanded(
                  child: Slider(
                    min: 12,
                    max: 32,
                    value: fontSize,
                    onChanged: (val) {
                      fontSizeNotifier.setFontSize(val);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
