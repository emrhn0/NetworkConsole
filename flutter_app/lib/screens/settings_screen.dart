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
import '../theme/theme_presets.dart';
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

  _SettingsPage _page = _SettingsPage.general;

  List<Widget> _content(_SettingsPage page, AppState state, AppColors c) {
    final lang = state.lang;
    final health = state.agent.lastHealth;
    switch (page) {
      case _SettingsPage.general:
        return [
          _Section(title: t(lang, 'settings.language'), c: c, children: [
            Row(children: [
              SizedBox(width: 150, child: _pill('English', state.lang == 'en', () => state.setLang('en'), c)),
              const SizedBox(width: 8),
              SizedBox(width: 150, child: _pill('Türkçe', state.lang == 'tr', () => state.setLang('tr'), c)),
            ]),
            const SizedBox(height: 10),
            Text(t(lang, 'settings.languageNote'), style: TextStyle(color: c.inkFaint, fontSize: 12)),
          ]),
        ];
      case _SettingsPage.theme:
        return [
          _Section(title: t(lang, 'settings.appTheme'), c: c, children: [
            Wrap(spacing: 12, runSpacing: 14, children: [
              for (final p in builtInThemes)
                _ThemeCard(
                  key: ValueKey('theme-${p.id}'),
                  preset: p,
                  selected: state.themeId == p.id,
                  c: c,
                  onTap: () => state.setTheme(p.id),
                ),
            ]),
            const SizedBox(height: 12),
            Text(t(lang, 'settings.themeNote'), style: TextStyle(color: c.inkFaint, fontSize: 12)),
          ]),
        ];
      case _SettingsPage.virustotal:
        return [
          _Section(title: t(lang, 'settings.vtTitle'), c: c, children: [
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
            ]),
            const SizedBox(height: 10),
            if (_testText.isNotEmpty)
              StatusLine(kind: _testKind, text: _testText, c: c)
            else
              Text(state.vtKey.isNotEmpty ? t(lang, 'settings.vtHave') : t(lang, 'settings.vtMissing'), style: TextStyle(color: c.inkFaint, fontSize: 11.5)),
            const SizedBox(height: 12),
            Text(t(lang, 'settings.vtSteps'), style: TextStyle(color: c.inkGhost, fontSize: 11, height: 1.5)),
            const SizedBox(height: 12),
            Row(children: [
              GhostButton(label: t(lang, 'action.goVt'), c: c, icon: Icon(Icons.north_east, size: 12, color: c.inkFaint), onPressed: () => launchUrl(Uri.parse(kVtApiKeyUrl))),
            ]),
          ]),
        ];
      case _SettingsPage.agent:
        return [
          _Section(title: t(lang, 'settings.agent'), c: c, children: [
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
        ];
      case _SettingsPage.updates:
        return const [_UpdatesPanel()];
      case _SettingsPage.about:
        return [
          _Section(title: t(lang, 'settings.about'), c: c, children: [
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
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final c = AppTheme(state.themeId).c;
    final lang = state.lang;

    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _SettingsNav(current: _page, lang: lang, c: c, onSelect: (p) => setState(() => _page = p)),
      Expanded(
        child: SingleChildScrollView(
          key: ValueKey('settings-page-${_page.name}'),
          padding: const EdgeInsets.fromLTRB(32, 26, 32, 32),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(t(lang, _page.titleKey), style: TextStyle(color: c.ink, fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 18),
                ..._content(_page, state, c),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _pill(String label, bool active, VoidCallback onTap, AppColors c) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? c.accentWeak : Colors.transparent,
              border: Border.all(color: active ? c.accentLine : c.line),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label, style: TextStyle(color: active ? c.accent : c.inkFaint, fontWeight: FontWeight.w600, fontSize: 12.5)),
          ),
        ),
      );
}

/// Ayarlar sayfalari, kenar cubugundaki sirayla (CommandS'teki duzen).
enum _SettingsPage {
  general('settings.page.general', Icons.tune),
  theme('settings.page.theme', Icons.palette_outlined),
  virustotal('settings.page.vt', Icons.shield_outlined),
  agent('settings.page.agent', Icons.memory),
  updates('settings.updates', Icons.system_update_alt),
  about('settings.about', Icons.info_outline);

  const _SettingsPage(this.titleKey, this.icon);
  final String titleKey;
  final IconData icon;
}

class _SettingsNav extends StatelessWidget {
  const _SettingsNav({required this.current, required this.lang, required this.c, required this.onSelect});
  final _SettingsPage current;
  final String lang;
  final AppColors c;
  final ValueChanged<_SettingsPage> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      decoration: BoxDecoration(color: c.bgBase, border: Border(right: BorderSide(color: c.line))),
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 14),
      child: ListView(children: [
        for (final page in _SettingsPage.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Material(
              color: page == current ? c.fillActive : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              child: InkWell(
                key: ValueKey('settings-nav-${page.name}'),
                borderRadius: BorderRadius.circular(7),
                hoverColor: c.fillHover,
                onTap: () => onSelect(page),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(children: [
                    Icon(page.icon, size: 17, color: page == current ? c.accent : c.inkFaint),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        t(lang, page.titleKey),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: page == current ? FontWeight.w600 : FontWeight.w400,
                          color: page == current ? c.ink : c.inkSoft,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({this.title, required this.c, required this.children});
  final String? title;
  final AppColors c;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      decoration: BoxDecoration(
        color: c.bgRise,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (title != null) ...[
          Text(title!, style: TextStyle(color: c.ink, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
        ],
        ...children,
      ]),
    );
  }
}

/// Bir temadaki uygulamanin minyaturu - baslik cubugu, kenar cubugu, icerik -
/// secim okuyarak degil bakarak yapilsin diye (CommandS'teki kartlarin aynisi).
class _ThemeCard extends StatelessWidget {
  const _ThemeCard({super.key, required this.preset, required this.selected, required this.c, required this.onTap});
  final ThemePreset preset;
  final bool selected;
  final AppColors c;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = preset;
    const width = 160.0;
    const height = 96.0;
    Widget bar(double w, Color color) => Container(
          width: w,
          height: 4,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: p.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: selected ? c.accent : c.line, width: selected ? 2 : 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                Container(height: 10, color: p.panel),
                Expanded(
                  child: Row(children: [
                    Container(
                      width: 46,
                      decoration: BoxDecoration(color: p.panel, border: Border(right: BorderSide(color: p.border))),
                      padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        bar(30, p.accent),
                        bar(24, p.border),
                        bar(32, p.border),
                      ]),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: p.panelAlt,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: p.border),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            bar(44, p.text.withValues(alpha: .75)),
                            bar(54, p.ok),
                            bar(34, p.warn),
                            bar(40, p.alarm),
                          ]),
                        ),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 16, color: selected ? c.accent : c.inkFaint),
              const SizedBox(width: 6),
              Expanded(
                child: Text(p.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: c.ink, fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
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
    final c = AppTheme(state.themeId).c;
    final lang = state.lang;
    final info = _info;

    return SectionCard(
      c: c,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
