import 'package:flutter_test/flutter_test.dart';
import 'package:network_console_app/core/update_checker.dart';

void main() {
  group('compareVersions', () {
    test('reads a newer release as newer, with or without the v', () {
      expect(UpdateChecker.compareVersions('v2.7.9', '2.7.8'), greaterThan(0));
      expect(UpdateChecker.compareVersions('2.8.0', '2.7.9'), greaterThan(0));
      expect(UpdateChecker.compareVersions('3.0.0', '2.9.9'), greaterThan(0));
    });

    test('the same version is not an update', () {
      expect(UpdateChecker.compareVersions('v2.7.8', '2.7.8'), 0);
      expect(UpdateChecker.isNewer('v2.7.8', '2.7.8'), isFalse);
    });

    test('an older release never wins', () {
      expect(UpdateChecker.compareVersions('2.7.7', '2.7.8'), lessThan(0));
      expect(UpdateChecker.compareVersions('1.5.0', '2.0.0'), lessThan(0));
    });

    test('numbers compare numerically, not as text', () {
      expect(UpdateChecker.compareVersions('2.7.10', '2.7.9'), greaterThan(0));
    });

    test('short and malformed tags cannot be read as newer', () {
      expect(UpdateChecker.compareVersions('2.8', '2.7.9'), greaterThan(0));
      expect(UpdateChecker.compareVersions('vNext', '2.7.8'), lessThan(0));
      expect(UpdateChecker.compareVersions('2.7.8-beta.1', '2.7.8'), 0);
    });
  });

  group('plainNotes', () {
    UpdateInfo withNotes(String notes) => UpdateInfo(
          version: '2.7.9',
          releaseUrl: 'https://example.invalid',
          notes: notes,
          assetName: null,
          assetUrl: null,
          assetSize: 0,
          checksumsUrl: null,
          method: null,
        );

    test('strips Markdown and stops at the manual install sections', () {
      final info = withNotes('''
## What's changed since v2.7.8
- **Fixed** the `title bar` on macOS
- Added in-app updates

## macOS
Drag the app into Applications.
''');
      expect(info.plainNotes, contains('• Fixed the title bar on macOS'));
      expect(info.plainNotes, isNot(contains('Drag the app')));
      expect(info.plainNotes, isNot(contains('**')));
    });
  });

  group('sizeLabel', () {
    test('is empty when the release did not say how big the build is', () {
      final info = UpdateInfo(
        version: '2.7.9',
        releaseUrl: 'https://example.invalid',
        notes: '',
        assetName: 'x.zip',
        assetUrl: 'https://example.invalid/x.zip',
        assetSize: 0,
        checksumsUrl: null,
        method: null,
      );
      expect(info.sizeLabel, '');
      expect(info.canSelfInstall, isFalse);
    });

    test('reports megabytes', () {
      final info = UpdateInfo(
        version: '2.7.9',
        releaseUrl: 'https://example.invalid',
        notes: '',
        assetName: 'x.zip',
        assetUrl: 'https://example.invalid/x.zip',
        assetSize: 26974603,
        checksumsUrl: null,
        method: UpdateMethod.macApp,
      );
      expect(info.sizeLabel, '25.7 MB');
      expect(info.canSelfInstall, isTrue);
    });
  });
}
