import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_presets.dart';
import 'agent.dart';
import 'constants.dart';
import 'update_checker.dart';

class HistoryEntry {
  final String view, summary;
  final DateTime ts;
  HistoryEntry(this.view, this.summary, this.ts);
}

class AppState extends ChangeNotifier {
  final Agent agent = Agent();
  SharedPreferences? _prefs;

  /// Secili tema (theme_presets.dart'taki id). Eski surumler sadece
  /// koyu/acik tutuyordu ('nc-dark' bool) - ilk acilista oradan tasinir.
  String themeId = kNcLightId;
  bool get isDark => themeById(themeId).dark;
  String lang = 'en'; // 'en' | 'tr'
  String vtKey = '';
  bool agentConnected = false;
  String agentMethod = 'HTTPS';
  final List<HistoryEntry> history = [];
  DateTime sessionStart = DateTime.now();

  // Guncelleme kontrolu (GitHub Releases). Her acilista tekrar calisir;
  // kullanici "bu surumu atla" derse SADECE o surum icin acilista sorulmaz,
  // Ayarlar'daki "Güncellemeleri denetle" yine her zaman gosterir.
  UpdateInfo? updateAvailable;

  /// Acilistaki diyalogun atlanmasi gerekip gerekmedigi - "bu surumu atla"
  /// secilmis surum icin true.
  bool updateSkipped = false;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs?.getString('nc-theme');
    themeId = (savedTheme != null && builtInThemes.any((t) => t.id == savedTheme))
        ? savedTheme
        : ((_prefs?.getBool('nc-dark') ?? false) ? kNcDarkId : kNcLightId);
    lang = _prefs?.getString('nc-lang') ?? 'en';
    vtKey = _prefs?.getString('nc-vt-key') ?? '';
    notifyListeners();

    final ok = await agent.ensureRunning();
    agentConnected = ok;
    agentMethod = ok ? 'ICMP' : 'HTTPS';
    if (!ok && vtKey.isEmpty) {
      // dosya yedeginden anahtar kurtarma girisimi (agent olmasa da dosya okunabilir)
    }
    notifyListeners();

    // Acilisi bloklamadan arka planda kontrol et - internet yoksa/GitHub
    // erisilemezse checkForUpdate zaten sessizce null doner.
    UpdateChecker.checkForUpdate(kAppVersion).then((info) async {
      if (info == null) return;
      UpdateChecker.available.value = info;
      updateSkipped = await UpdateChecker.isSkipped(info.version);
      updateAvailable = info;
      notifyListeners();
    });
  }

  void setTheme(String id) {
    themeId = themeById(id).id;
    _prefs?.setString('nc-theme', themeId);
    // Eski surume geri donulurse en azindan koyu/acik tercihi korunsun.
    _prefs?.setBool('nc-dark', isDark);
    notifyListeners();
  }

  void setLang(String l) {
    lang = l;
    _prefs?.setString('nc-lang', l);
    notifyListeners();
  }

  void setVtKey(String v) {
    vtKey = v.trim();
    _prefs?.setString('nc-vt-key', vtKey);
    notifyListeners();
  }

  void clearVtKey() {
    vtKey = '';
    _prefs?.remove('nc-vt-key');
    notifyListeners();
  }

  /// Acilis diyalogu kapatildi. updateAvailable KORUNUR - Ayarlar sayfasi ve
  /// sonraki "denetle" cagrilari ayni surumu gostermeye devam etsin diye;
  /// sadece bu oturumda diyalog bir daha acilmaz (bkz. AppShell).
  void dismissUpdate() {
    notifyListeners();
  }

  Future<void> refreshAgent() async {
    final ok = await agent.ensureRunning();
    agentConnected = ok;
    agentMethod = ok ? 'ICMP' : 'HTTPS';
    notifyListeners();
  }

  void logHistory(String view, String summary) {
    history.insert(0, HistoryEntry(view, summary, DateTime.now()));
    if (history.length > 40) history.removeLast();
    notifyListeners();
  }
}
