/// EN/TR sozluk. key -> [en, tr]. Kullanim: t(state.lang, "key")
const Map<String, List<String>> _strings = {
  'nav.ping': ['Ping', 'Ping'],
  'nav.trace': ['Trace', 'İz Sürme'],
  'nav.telnet': ['Telnet', 'Telnet'],
  'nav.dns': ['DNS', 'DNS'],
  'nav.cert': ['Certificate', 'Sertifika'],
  'nav.http': ['HTTP', 'HTTP'],
  'nav.sweep': ['IP Scan', 'IP Tarama'],
  'nav.subnet': ['Subnet', 'Alt Ağ'],
  'nav.urlcheck': ['URL Check', 'URL Kontrol'],
  'nav.snmp': ['SNMP', 'SNMP'],
  'nav.wol': ['Wake-on-LAN', 'Wake-on-LAN'],
  'nav.settings': ['Settings', 'Ayarlar'],
  'nav.dashboard': ['Dashboard', 'Panel'],

  'nav.group.diagnostics': ['Diagnostics', 'Tanılama'],
  'nav.group.advanced': ['Advanced', 'Gelişmiş'],

  'desc.ping': ['Continuous reachability measurement', 'Sürekli erişilebilirlik ölçümü'],
  'desc.trace': ['Hop-by-hop route and latency (MTR)', 'Adım adım rota ve gecikme'],
  'desc.telnet': ['TCP port reachability check', 'TCP port erişim kontrolü'],
  'desc.dns': ['Compare internal and external DNS records', 'İç/dış DNS kayıtlarını karşılaştır'],
  'desc.cert': ['TLS certificate detail and expiry', 'TLS sertifika detayı ve süresi'],
  'desc.http': ['Status code, redirects, headers', 'Durum kodu, yönlendirme, başlıklar'],
  'desc.sweep': ['Find alive devices in a CIDR range', 'CIDR aralığında canlı cihaz bul'],
  'desc.subnet': ['CIDR calculation and VLSM split', 'CIDR hesaplama ve VLSM bölme'],
  'desc.urlcheck': ['URL reputation check via VirusTotal', 'VirusTotal ile URL itibar kontrolü'],
  'desc.settings': ['VirusTotal key, theme, language, agent', 'VirusTotal anahtarı, tema, dil, ajan'],
  'desc.snmp': ['Read system info from a switch/router/firewall', 'Switch/router/firewall sistem bilgisini oku'],
  'desc.wol': ['Wake a device remotely with a magic packet', 'Bir cihazı magic packet ile uzaktan uyandır'],

  'action.check': ['Check', 'Kontrol Et'],
  'action.connect': ['Connect', 'Bağlan'],
  'action.disconnect': ['Disconnect', 'Bağlantıyı Kes'],
  'action.start': ['Start', 'Başlat'],
  'action.stop': ['Stop', 'Durdur'],
  'action.scan': ['Scan', 'Tara'],
  'action.send': ['Send', 'Gönder'],
  'action.calculate': ['Calculate', 'Hesapla'],
  'action.clear': ['Clear', 'Temizle'],
  'action.copy': ['Copy', 'Kopyala'],
  'action.export': ['Export', 'Dışa Aktar'],
  'action.import': ['Import', 'İçe Aktar'],
  'action.save': ['Save', 'Kaydet'],
  'action.remove': ['Remove', 'Kaldır'],
  'action.goVt': ["Go to VirusTotal", "VirusTotal'a Git"],
  'action.refresh': ['Refresh', 'Yenile'],
  'action.cancel': ['Cancel', 'Vazgeç'],
  'action.update': ['Update', 'Güncelle'],
  'action.updateNow': ['Update now', 'Şimdi güncelle'],
  'action.remindLater': ['Remind me later', 'Daha sonra hatırlat'],
  'action.skipVersion': ['Skip this version', 'Bu sürümü atla'],
  'action.openDownloadPage': ['Open download page', 'İndirme sayfasını aç'],
  'action.checkUpdates': ['Check for updates', 'Güncellemeleri denetle'],

  'update.title': ['Update available', 'Güncelleme mevcut'],
  'update.downloading': ['Downloading update…', 'Güncelleme indiriliyor…'],
  'update.running': ['You are running v{0}.', 'Şu an v{0} kullanıyorsunuz.'],
  'update.size': ['Download is {0}.', 'İndirme boyutu {0}.'],
  'update.manualNote': [
    'Downloading opens the release page in your browser. Unzip the app and drag it to Applications, replacing the old one.',
    'İndirme, sürüm sayfasını tarayıcınızda açar. Uygulamayı arşivden çıkarıp Applications klasörüne sürükleyin ve eskisinin üzerine yazın.'],
  'update.errorHint': [
    'You can still download it yourself from the release page.',
    'Dilerseniz sürüm sayfasından kendiniz indirebilirsiniz.'],
  'update.checking': ['Checking for updates…', 'Güncellemeler denetleniyor…'],
  'update.upToDate': ['You are on the latest version (v{0}).', 'En güncel sürümü kullanıyorsunuz (v{0}).'],
  'update.failed': [
    'Could not reach GitHub to check for updates. Check your internet connection and try again.',
    "Güncelleme denetimi için GitHub'a ulaşılamadı. İnternet bağlantınızı kontrol edip tekrar deneyin."],
  'update.found': ['Version {0} is available.', '{0} sürümü yayınlandı.'],
  'update.askInstall': ['Update to {0} now?', '{0} sürümüne şimdi güncellensin mi?'],
  'update.installed': ['The update will restart the app when it finishes.',
    'Güncelleme tamamlanınca uygulama yeniden başlatılacak.'],
  'settings.updates': ['Updates', 'Güncellemeler'],
  'settings.updatesNote': [
    'Network Console checks GitHub for a newer release each time it starts and offers to install it. You can also check here at any time.',
    'Network Console her açılışta GitHub üzerinde yeni sürüm olup olmadığına bakar ve varsa kurmayı önerir. Buradan istediğiniz zaman da denetleyebilirsiniz.'],

  'settings.vtTitle': ['VirusTotal API Key', 'VirusTotal API Anahtarı'],
  'settings.vtPlaceholder': ['Your own VirusTotal API key', 'Kendi VirusTotal API anahtarınız'],
  'settings.vtHave': ["Key saved — queries use your own VirusTotal account.",
    'Anahtar kayıtlı — sorgular kendi VirusTotal hesabınız üzerinden yapılır.'],
  'settings.vtMissing': ['No key set — follow the steps below to add one.',
    'Anahtar girilmedi — aşağıdaki adımları izleyip ekleyin.'],
  'settings.vtSteps': [
    "1) Sign in to VirusTotal (or create a free account) · 2) Go to the API Key tab in your profile · 3) Copy it, paste it above and press Save. Stored only on this computer.",
    "1) VirusTotal'a giriş yapın (yoksa ücretsiz oluşturun) · 2) Profil menüsünden API Key sekmesine gidin · 3) Kopyalayıp yukarı yapıştırıp Kaydet'e basın. Sadece bu bilgisayarda saklanır."],
  'settings.appearance': ['Appearance', 'Görünüm'],
  'settings.page.general': ['General', 'Genel'],
  'settings.page.theme': ['Theme & colors', 'Tema ve renkler'],
  'settings.page.vt': ['VirusTotal', 'VirusTotal'],
  'settings.page.agent': ['Local agent', 'Yerel ajan'],
  'settings.appTheme': ['App theme', 'Uygulama teması'],
  'settings.themeNote': ['Applies right away and is remembered on this computer.',
      'Hemen uygulanır ve bu bilgisayarda hatırlanır.'],
  'settings.languageNote': ['Applies to the app\'s own menus and pages.',
      'Uygulamanın kendi menü ve sayfalarına uygulanır.'],
  'settings.dark': ['Dark', 'Koyu'],
  'settings.light': ['Light', 'Açık'],
  'settings.language': ['Language', 'Dil'],
  'settings.agent': ['Local Agent', 'Yerel Ajan'],
  'settings.agentNote': ['The agent must be running on this computer for measurements (ping, trace, port scan, etc.) to work.',
    'Ölçümlerin (ping, iz sürme, port taraması vb.) çalışması için ajan bu bilgisayarda çalışıyor olmalı.'],
  'settings.agentRunning': ['Running', 'Çalışıyor'],
  'settings.agentDown': ['Not found', 'Bulunamadı'],
  'settings.about': ['About', 'Hakkında'],
  'settings.version': ['Version', 'Sürüm'],
  'settings.host': ['Agent host', 'Ajan makinesi'],
  'settings.os': ['Operating system', 'İşletim sistemi'],
  'settings.method': ['Measurement method', 'Ölçüm yöntemi'],

  'urlcheck.nudge': ['You need your own VirusTotal API key (Settings) to run queries.',
    "Sorgu yapabilmek için kendi VirusTotal API anahtarınızı Ayarlar'a eklemeniz gerekir."],
  'urlcheck.enterUrl': ['Enter a URL and check', 'Bir URL girin ve kontrol edin'],
  'urlcheck.results': ['Scan Results', 'Tarama Sonuçları'],
  'urlcheck.querying': ['Querying…', 'Sorgulanıyor…'],
  'urlcheck.failed': ['Query failed', 'Sorgu başarısız'],
  'urlcheck.clean': ['Clean', 'Temiz'],
  'urlcheck.malicious': ['Malicious', 'Zararlı'],
  'urlcheck.suspicious': ['Suspicious', 'Şüpheli'],
  'urlcheck.harmless': ['Harmless', 'Zararsız'],
  'urlcheck.undetected': ['Undetected', 'Tespitsiz'],
  'urlcheck.reputation': ['Reputation', 'İtibar'],
  'urlcheck.lastAnalysis': ['Last analysis', 'Son analiz'],
  'urlcheck.risk': ['Risk', 'Risk'],
  'urlcheck.url': ['URL', 'URL'],

  'sweep.cidr': ['CIDR / Range', 'CIDR / Aralık'],
  'sweep.port': ['Port (optional)', 'Port (opsiyonel)'],
  'sweep.alive': ['Alive', 'Canlı'],
  'sweep.dead': ['No response', 'Yanıt yok'],
  'sweep.total': ['Total', 'Toplam'],
  'sweep.progress': ['Progress', 'İlerleme'],
  'sweep.tooLarge': ['Too large — max /20 (4096 addresses)', 'Çok geniş — en fazla /20 (4096 adres)'],

  'field.target': ['Target', 'Hedef'],
  'field.port': ['Port', 'Port'],
  'field.url': ['URL', 'URL'],
  'field.host': ['Host', 'Sunucu'],
  'field.query': ['Query', 'Sorgu'],
  'field.method': ['Method', 'Yöntem'],
  'field.server': ['Server', 'Sunucu'],
  'field.type': ['Type', 'Tür'],

  'app.name': ['Network Console', 'Network Console'],
  'dashboard.title': ['Measure first, then decide.', 'Önce ölç, sonra karar ver.'],
  'dashboard.desc': [
    "Ping, trace, DNS, certificates, HTTP, port sweeps, subnet math and URL reputation — nine instruments, one console.",
    'Ping, iz sürme, DNS, sertifika, HTTP, port taraması, alt ağ hesaplama ve URL itibarı — dokuz araç, tek konsol.'],
  'dashboard.recent': ['Recent Activity', 'Son Etkinlik'],
  'dashboard.empty': ['No activity yet', 'Henüz etkinlik yok'],
  'dashboard.emptySub': ['Use any tool and it will show up here', 'Bir araç kullanınca burada görünür'],
};

/// [t], with `{0}`, `{1}`, ... replaced by [args] -- for the few strings that
/// carry a version number or a file size.
String tf(String lang, String key, List<String> args) {
  var out = t(lang, key);
  for (var i = 0; i < args.length; i++) {
    out = out.replaceAll('{$i}', args[i]);
  }
  return out;
}

String t(String lang, String key) {
  final e = _strings[key];
  if (e == null) return key;
  return lang == 'tr' ? e[1] : e[0];
}
