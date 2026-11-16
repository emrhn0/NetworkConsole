import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_console_app/core/app_state.dart';
import 'package:network_console_app/screens/settings_screen.dart';
import 'package:network_console_app/theme/app_theme.dart';
import 'package:network_console_app/theme/theme_presets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<AppState> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final state = AppState();
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: state,
      child: Consumer<AppState>(
        builder: (_, s, _) => MaterialApp(
          theme: AppTheme(s.themeId).themeData,
          home: const Scaffold(body: SettingsScreen()),
        ),
      ),
    ));
    return state;
  }

  testWidgets('every settings page renders', (tester) async {
    await pump(tester);
    for (final name in ['general', 'theme', 'virustotal', 'agent', 'updates', 'about']) {
      await tester.tap(find.byKey(ValueKey('settings-nav-$name')));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: name);
    }
  });

  testWidgets('every theme can be picked and renders', (tester) async {
    final state = await pump(tester);
    await tester.tap(find.byKey(const ValueKey('settings-nav-theme')));
    await tester.pump();
    for (final p in builtInThemes) {
      final card = find.byKey(ValueKey('theme-${p.id}'));
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pump();
      expect(state.themeId, p.id);
      expect(state.isDark, p.dark);
      expect(tester.takeException(), isNull, reason: p.id);
    }
  });
}
