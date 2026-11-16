import 'package:flutter/material.dart';
import 'theme_presets.dart';

/// Renk paleti - ag-konsolu.html'deki CSS degiskenlerinin birebir karsiligi.
class AppColors {
  final Color bgDeep, bgBase, bgRise, bgHigh, bgSink;
  final Color ink, inkSoft, inkFaint, inkGhost;
  final Color line, lineSoft, lineStrong;
  final Color accent, accentInk, accentWeak, accentLine;
  final Color ok, okWeak, okLine;
  final Color alarm, alarmWeak, alarmLine;
  final Color warn, warnWeak, warnLine;
  final Color fillFaint, fillHover, fillActive;

  const AppColors({
    required this.bgDeep, required this.bgBase, required this.bgRise, required this.bgHigh, required this.bgSink,
    required this.ink, required this.inkSoft, required this.inkFaint, required this.inkGhost,
    required this.line, required this.lineSoft, required this.lineStrong,
    required this.accent, required this.accentInk, required this.accentWeak, required this.accentLine,
    required this.ok, required this.okWeak, required this.okLine,
    required this.alarm, required this.alarmWeak, required this.alarmLine,
    required this.warn, required this.warnWeak, required this.warnLine,
    required this.fillFaint, required this.fillHover, required this.fillActive,
  });

  static const dark = AppColors(
    bgDeep: Color(0xFF08080D), bgBase: Color(0xFF0F0F17), bgRise: Color(0xFF15151F), bgHigh: Color(0xFF1C1C28),
    bgSink: Color(0x47000000),
    ink: Color(0xFFEFE8D8), inkSoft: Color(0xFFABA595), inkFaint: Color(0xFF726D62), inkGhost: Color(0xFF4A4754),
    line: Color(0x17EFE8D8), lineSoft: Color(0x0DEFE8D8), lineStrong: Color(0x2BEFE8D8),
    accent: Color(0xFFC89A3C), accentInk: Color(0xFF0A0A0F), accentWeak: Color(0x21C89A3C), accentLine: Color(0x51C89A3C),
    ok: Color(0xFF7FB069), okWeak: Color(0x217FB069), okLine: Color(0x4D7FB069),
    alarm: Color(0xFFD2604A), alarmWeak: Color(0x21D2604A), alarmLine: Color(0x4DD2604A),
    warn: Color(0xFFC79430), warnWeak: Color(0x21C79430), warnLine: Color(0x4DC79430),
    fillFaint: Color(0x06EFE8D8), fillHover: Color(0x0FEFE8D8), fillActive: Color(0x17EFE8D8),
  );

  /// Bir tema presetinden tam palet. Network Console'un kendi iki temasi elle
  /// ayarlanmis sabitleri kullanir; katalogdakiler (CommandS'tekiyle ayni)
  /// yedi arayuz renginden ve uc durum renginden turetilir.
  static AppColors forPreset(ThemePreset p) {
    if (p.id == kNcDarkId) return dark;
    if (p.id == kNcLightId) return light;
    final d = p.dark;
    Color a(Color c, double o) => c.withValues(alpha: o);
    final ink = p.text;
    final lum = p.accent.computeLuminance();
    return AppColors(
      bgDeep: p.background,
      bgBase: p.panel,
      bgRise: p.panelAlt,
      bgHigh: Color.lerp(p.panelAlt, p.border, .5)!,
      bgSink: d ? const Color(0x47000000) : a(ink, .045),
      ink: ink,
      inkSoft: Color.lerp(ink, p.textDim, .45)!,
      inkFaint: p.textDim,
      inkGhost: Color.lerp(p.textDim, p.background, .38)!,
      line: d ? a(ink, .09) : a(ink, .12),
      lineSoft: d ? a(ink, .05) : a(ink, .07),
      lineStrong: d ? a(ink, .17) : a(ink, .22),
      accent: p.accent,
      accentInk: lum > .4 ? const Color(0xFF0A0A0F) : const Color(0xFFFFFDF6),
      accentWeak: a(p.accent, d ? .13 : .11),
      accentLine: a(p.accent, .32),
      ok: p.ok, okWeak: a(p.ok, d ? .13 : .11), okLine: a(p.ok, .30),
      alarm: p.alarm, alarmWeak: a(p.alarm, d ? .13 : .10), alarmLine: a(p.alarm, .30),
      warn: p.warn, warnWeak: a(p.warn, d ? .13 : .11), warnLine: a(p.warn, .30),
      fillFaint: a(ink, d ? .024 : .02),
      fillHover: a(ink, d ? .06 : .055),
      fillActive: a(ink, d ? .09 : .085),
    );
  }

  static const light = AppColors(
    bgDeep: Color(0xFFE6E2D6), bgBase: Color(0xFFF3F0E6), bgRise: Color(0xFFFAF8F1), bgHigh: Color(0xFFEEEADE),
    bgSink: Color(0x0B17161C),
    ink: Color(0xFF17161C), inkSoft: Color(0xFF4B4854), inkFaint: Color(0xFF7E7A70), inkGhost: Color(0xFFA6A198),
    line: Color(0x1F17161C), lineSoft: Color(0x1217161C), lineStrong: Color(0x3817161C),
    accent: Color(0xFF96701F), accentInk: Color(0xFFFFFDF6), accentWeak: Color(0x1C96701F), accentLine: Color(0x4D96701F),
    ok: Color(0xFF4B7A38), okWeak: Color(0x1C4B7A38), okLine: Color(0x4D4B7A38),
    alarm: Color(0xFFB03E27), alarmWeak: Color(0x1AB03E27), alarmLine: Color(0x47B03E27),
    warn: Color(0xFF96701F), warnWeak: Color(0x1C96701F), warnLine: Color(0x4796701F),
    fillFaint: Color(0x0517161C), fillHover: Color(0x0E17161C), fillActive: Color(0x1617161C),
  );
}
