import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_state.dart';
import '../core/constants.dart';
import '../core/errors.dart';
import '../core/i18n.dart';
import '../core/update_checker.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/update_dialog.dart';
import 'urlcheck_screen.dart' show kVtApiKeyUrl;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _key;
  StatusKind _testKind = StatusKind.idle;
  String _testText = '';

  @override
  void initState() {
    super.initState();
    final existing = context.read<AppState>().vtKey;
    _key = TextEditingController(text: existing);
    if (existing.isNotEmpty) _testKey(existing);
  }

  Future<void> _testKey(String value) async {
    final state = context.read<AppState>();
    setState(() { _testKind = StatusKind.busy; _testText = 'Checking key against VirusTotal…'; });
    final r = await state.agent.vtCheck('https://www.google.com', value);
    if (!mounted) return;
    setState(() {
      if (r['ok'] == true) {
        _testKind = StatusKind.ok;
        _testText = 'Key works';
      } else {
        _testKind = StatusKind.error;
        _testText = friendlyAgentError(r['error']?.toString());
      }
    });
  }

  /// Anahtari kaydettikten sonra gercekten calisip calismadigini test eder -
  /// kullaniciyi tahminde birakmak yerine "kontrol ediliyor" -> "calisiyor"
  /// veya "calismiyor, sebep su" seklinde surekli bilgilendirir.
  Future<void> _saveAndTest() async {
    final state = context.read<AppState>();
    final value = _key.text.trim();
    state.setVtKey(value);
    if (value.isEmpty) {
      setState(() { _testKind = StatusKind.idle; _testText = ''; });
      return;
    }
    await _testKey(value);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final c = AppTheme(state.isDark).c;
    final lang = state.lang;
    final health = state.agent.lastHealth;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(26),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionCard(
          c: c,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Caption(t(lang, 'settings.vtTitle'), c),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: LabeledField(label: '', controller: _key, c: c, obscure: true, hint: t(lang, 'settings.vtPlaceholder'))),
              const SizedBox(width: 10),
              GhostButton(label: t(lang, 'action.save'), c: c, onPressed: _saveAndTest),
              const SizedBox(width: 8),
              GhostButton(label: t(lang, 'action.remove'), c: c, onPressed: () {
                _key.clear();
                state.clearVtKey();
                setState(() { _testKind = StatusKind.idle; _testText = ''; });
              }),
              const SizedBox(width: 8),
              GhostButton(label: t(lang, 'action.goVt'), c: c, icon: Icon(Icons.north_east, size: 12, color: c.inkFaint), onPressed: () => launchUrl(Uri.parse(kVtApiKeyUrl))),
            ]),
            const SizedBox(height: 10),
            if (_testText.isNotEmpty)
              StatusLine(kind: _testKind, text: _testText, c: c)
            else
              Text(state.vtKey.isNotEmpty ? t(lang, 'settings.vtHave') : t(lang, 'settings.vtMissing'), style: TextStyle(color: c.inkFaint, fontSize: 11.5)),
            const SizedBox(height: 6),
            Text(t(lang, 'settings.vtSteps'), style: TextStyle(color: c.inkGhost, fontSize: 11, height: 1.5)),
          ]),
        ),
        const SizedBox(height: 14),
        SectionCard(
          c: c,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Caption(t(lang, 'settings.appearance'), c),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _pill(t(lang, 'settings.dark'), state.isDark, () => state.toggleDark(true), c)),
              const SizedBox(width: 8),
              Expanded(child: _pill(t(lang, 'settings.light'), !state.isDark, () => state.toggleDark(false), c)),
            ]),
            const SizedBox(height: 18),
            Caption(t(lang, 'settings.language'), c),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _pill('English', state.lang == 'en', () => state.setLang('en'), c)),
              const SizedBox(width: 8),
              Expanded(child: _pill('Türkçe', state.lang == 'tr', () => state.setLang('tr'), c)),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
        SectionCard(
          c: c,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Caption(t(lang, 'settings.agent'), c),
            const SizedBox(height: 12),
            Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: state.agentConnected ? c.ok : c.alarm)),
              const SizedBox(width: 8),
              Text(state.agentConnected ? t(lang, 'settings.agentRunning') : t(lang, 'settings.agentDown'), style: TextStyle(color: c.inkSoft)),
              const Spacer(),
              GhostButton(label: t(lang, 'action.refresh'), c: c, onPressed: () => state.refreshAgent()),
            ]),
            const SizedBox(height: 10),
            Text(t(lang, 'settings.agentNote'), style: TextStyle(color: c.inkGhost, fontSize: 11.5)),
          ]),
        ),
        const SizedBox(height: 14),
        const _UpdatesPanel(),
        const SizedBox(height: 14),
        SectionCard(
          c: c,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Caption(t(lang, 'settings.about'), c),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 3.4,
              children: [
                StatCell(t(lang, 'settings.version'), 'v$kAppVersion', c),
                StatCell('Agent', health?['app_version'] != null ? 'v${health!['app_version']}' : '—', c),
                StatCell(t(lang, 'settings.host'), health?['host']?.toString() ?? '—', c),
                StatCell(t(lang, 'settings.os'), health?['os']?.toString() ?? '—', c),
                StatCell(t(lang, 'settings.method'), state.agentMethod, c),
              ],
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _pill(String label, bool active, VoidCallback onTap, AppColors c) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? c.accentWeak : Colors.transparent,
            border: Border.all(color: active ? c.accentLine : c.line),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, style: TextStyle(color: active ? c.accent : c.inkFaint, fontWeight: FontWeight.w600, fontSize: 12.5)),
        ),
      );
}


/// "Güncellemeleri denetle" - sorusu sayfanin kendisinde cevaplanir, ayri bir
/// pencere acmadan: ne bulundugu, indirme ilerlemesi ve hata varsa sebebi
/// ayni kartta gorunur. Acilistaki diyalogla ayni kurulum yolunu kullanir.
class _UpdatesPanel extends StatefulWidget {
  const _UpdatesPanel();
  @override
  State<_UpdatesPanel> createState() => _UpdatesPanelState();
}

class _UpdatesPanelState extends State<_UpdatesPanel> {
  bool _checking = false;
  bool _installing = false;
  double? _progress;
  UpdateInfo? _info;
  String? _message;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Acilistaki kontrol zaten bir sonuc bulduysa tekrar sormaya gerek yok.
    _info = UpdateChecker.available.value;
  }

  Future<void> _check() async {
    setState(() {
      _checking = true;
      _message = null;
      _error = null;
    });
    final lang = context.read<AppState>().lang;
    final result = await UpdateChecker.checkNow(kAppVersion);
    if (!mounted) return;
    setState(() {
      _checking = false;
      if (result.failed) {
        _error = t(lang, 'update.failed');
      } else if (result.info == null) {
        _info = null;
        _message = tf(lang, 'update.upToDate', [kAppVersion]);
      } else {
        _info = result.info;
        UpdateChecker.available.value = result.info;
      }
    });
  }

  Future<void> _install() async {
    final info = _info;
    if (info == null) return;
    setState(() {
      _installing = true;
      _progress = 0;
      _error = null;
    });
    final error = await installUpdate(info, onProgress: (p) {
      if (mounted) setState(() => _progress = p);
    });
    if (!mounted) return;
    setState(() {
      _installing = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final c = AppTheme(state.isDark).c;
    final lang = state.lang;
    final info = _info;

    return SectionCard(
      c: c,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Caption(t(lang, 'settings.updates'), c),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: Text('v$kAppVersion', style: TextStyle(color: c.inkSoft, fontSize: 12.5)),
          ),
          GhostButton(
            label: t(lang, 'action.checkUpdates'),
            c: c,
            icon: Icon(Icons.system_update_alt, size: 13, color: c.inkFaint),
            onPressed: (_checking || _installing) ? null : _check,
          ),
        ]),
        if (_checking) ...[
          const SizedBox(height: 12),
          StatusLine(kind: StatusKind.busy, text: t(lang, 'update.checking'), c: c),
        ],
        if (_message != null) ...[
          const SizedBox(height: 12),
          StatusLine(kind: StatusKind.ok, text: _message!, c: c),
        ],
        if (info != null && !_installing) ...[
          const SizedBox(height: 12),
          Text(tf(lang, 'update.found', ['v${info.version}']),
              style: TextStyle(color: c.ink, fontSize: 13, fontWeight: FontWeight.w600)),
          if (info.sizeLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(tf(lang, 'update.size', [info.sizeLabel]),
                style: TextStyle(color: c.inkFaint, fontSize: 11.5)),
          ],
          const SizedBox(height: 12),
          Row(children: [
            if (info.canSelfInstall && _error == null)
              GhostButton(
                label: t(lang, 'action.updateNow'),
                c: c,
                icon: Icon(Icons.system_update_alt, size: 13, color: c.accent),
                onPressed: _install,
              )
            else
              GhostButton(
                label: t(lang, 'action.openDownloadPage'),
                c: c,
                onPressed: () => UpdateChecker.openReleasePage(info),
              ),
          ]),
        ],
        if (_installing) ...[
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: _progress, backgroundColor: c.fillHover, color: c.accent, minHeight: 6),
          ),
          const SizedBox(height: 8),
          Text(
            _progress == null
                ? t(lang, 'update.downloading')
                : '${t(lang, 'update.downloading')} ${(_progress! * 100).toStringAsFixed(0)}%',
            style: TextStyle(color: c.inkFaint, fontSize: 11.5),
          ),
          const SizedBox(height: 4),
          Text(t(lang, 'update.installed'), style: TextStyle(color: c.inkGhost, fontSize: 11)),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          StatusLine(kind: StatusKind.error, text: _error!, c: c),
        ],
        const SizedBox(height: 10),
        Text(t(lang, 'settings.updatesNote'),
            style: TextStyle(color: c.inkGhost, fontSize: 11, height: 1.5)),
      ]),
    );
  }
}
