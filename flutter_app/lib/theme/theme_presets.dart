import 'dart:ui' show Color;

/// Bir renk temasi. CommandS'teki tema kataloguyla ayni palet (arayuz
/// renkleri); terminal ANSI yerine durum renkleri (ok/alarm/warn) tutulur -
/// Network Console'da ping/sweep sonuclari bunlarla boyanir.
class ThemePreset {
  const ThemePreset({
    required this.id,
    required this.name,
    required this.dark,
    required this.background,
    required this.panel,
    required this.panelAlt,
    required this.border,
    required this.text,
    required this.textDim,
    required this.accent,
    required this.ok,
    required this.alarm,
    required this.warn,
  });

  final String id;
  final String name;
  final bool dark;
  final Color background, panel, panelAlt, border, text, textDim, accent;
  final Color ok, alarm, warn;
}

ThemePreset _p(String id, String name, bool dark, List<int> ui, int ok, int alarm, int warn) {
  Color c(int v) => Color(0xFF000000 | v);
  return ThemePreset(
    id: id,
    name: name,
    dark: dark,
    background: c(ui[0]),
    panel: c(ui[1]),
    panelAlt: c(ui[2]),
    border: c(ui[3]),
    text: c(ui[4]),
    textDim: c(ui[5]),
    accent: c(ui[6]),
    ok: c(ok),
    alarm: c(alarm),
    warn: c(warn),
  );
}

/// Network Console'un kendi iki temasi. Renkleri AppColors.dark/light'ta
/// elle ayarlanmis haliyle durur (bkz. AppColors.forPreset); buradaki
/// degerler sadece Ayarlar'daki onizleme kartlari icin.
const kNcDarkId = 'nc-dark';
const kNcLightId = 'nc-light';

final List<ThemePreset> builtInThemes = List.unmodifiable([
  _p(kNcDarkId, 'Network Console', true,
      [0x08080D, 0x0F0F17, 0x15151F, 0x2A2A33, 0xEFE8D8, 0x726D62, 0xC89A3C], 0x7FB069, 0xD2604A, 0xC79430),
  _p(kNcLightId, 'Network Console Light', false,
      [0xE6E2D6, 0xF3F0E6, 0xFAF8F1, 0xD6D2C6, 0x17161C, 0x7E7A70, 0x96701F], 0x4B7A38, 0xB03E27, 0x96701F),
  _p('commands', 'CommandS', true,
      [0x0D0D0D, 0x161616, 0x1F1F1F, 0x2C2C2C, 0xF5F3EF, 0x9A9690, 0xFF8A3D], 0x6BCB77, 0xFF5C5C, 0xFFB066),
  _p('aurora', 'Aurora', true,
      [0x0A0A10, 0x15121F, 0x211B33, 0x2A2440, 0xEDEDF5, 0x8B8AA6, 0x8C7CFF], 0x5BFFA3, 0xFF5B6E, 0xFFC85B),
  _p('tokyo-night', 'Tokyo Night', true,
      [0x1A1B26, 0x16161E, 0x1F2335, 0x292E42, 0xC0CAF5, 0x737AA2, 0x7AA2F7], 0x9ECE6A, 0xF7768E, 0xE0AF68),
  _p('dracula', 'Dracula', true,
      [0x282A36, 0x21222C, 0x343746, 0x44475A, 0xF8F8F2, 0x8C93BC, 0xBD93F9], 0x50FA7B, 0xFF5555, 0xF1FA8C),
  _p('one-dark', 'One Dark', true,
      [0x282C34, 0x21252B, 0x2C313A, 0x3E4451, 0xABB2BF, 0x7F848E, 0x61AFEF], 0x98C379, 0xE06C75, 0xE5C07B),
  _p('monokai', 'Monokai', true,
      [0x272822, 0x1E1F1C, 0x3E3D32, 0x49483E, 0xF8F8F2, 0x908A6F, 0xA6E22E], 0xA6E22E, 0xF92672, 0xF4BF75),
  _p('nord', 'Nord', true,
      [0x2E3440, 0x292E39, 0x3B4252, 0x434C5E, 0xECEFF4, 0x8C97AD, 0x88C0D0], 0xA3BE8C, 0xBF616A, 0xEBCB8B),
  _p('gruvbox-dark', 'Gruvbox Dark', true,
      [0x282828, 0x1D2021, 0x3C3836, 0x504945, 0xEBDBB2, 0xA89984, 0xFABD2F], 0xB8BB26, 0xFB4934, 0xFABD2F),
  _p('catppuccin-mocha', 'Catppuccin Mocha', true,
      [0x1E1E2E, 0x181825, 0x313244, 0x45475A, 0xCDD6F4, 0x9399B2, 0xCBA6F7], 0xA6E3A1, 0xF38BA8, 0xF9E2AF),
  _p('rose-pine', 'Rosé Pine', true,
      [0x191724, 0x1F1D2E, 0x26233A, 0x403D52, 0xE0DEF4, 0x908CAA, 0xEBBCBA], 0x9CCFD8, 0xEB6F92, 0xF6C177),
  _p('everforest-dark', 'Everforest Dark', true,
      [0x2D353B, 0x232A2E, 0x343F44, 0x475258, 0xD3C6AA, 0x9DA9A0, 0xA7C080], 0xA7C080, 0xE67E80, 0xDBBC7F),
  _p('kanagawa', 'Kanagawa', true,
      [0x1F1F28, 0x16161D, 0x2A2A37, 0x363646, 0xDCD7BA, 0x8A8980, 0x7E9CD8], 0x98BB6C, 0xE46876, 0xE6C384),
  _p('github-dark', 'GitHub Dark', true,
      [0x0D1117, 0x010409, 0x161B22, 0x30363D, 0xE6EDF3, 0x8D96A0, 0x58A6FF], 0x3FB950, 0xFF7B72, 0xD29922),
  _p('solarized-dark', 'Solarized Dark', true,
      [0x002B36, 0x00252E, 0x073642, 0x0E4552, 0x93A1A1, 0x6C8288, 0x268BD2], 0x859900, 0xDC322F, 0xB58900),
  _p('solarized-light', 'Solarized Light', false,
      [0xFDF6E3, 0xEEE8D5, 0xFFFBEF, 0xDDD6C1, 0x586E75, 0x839496, 0x268BD2], 0x859900, 0xDC322F, 0xB58900),
  _p('github-light', 'GitHub Light', false,
      [0xFFFFFF, 0xF6F8FA, 0xFFFFFF, 0xD0D7DE, 0x1F2328, 0x656D76, 0x0969DA], 0x1A7F37, 0xCF222E, 0x9A6700),
  _p('catppuccin-latte', 'Catppuccin Latte', false,
      [0xEFF1F5, 0xE6E9EF, 0xFFFFFF, 0xCCD0DA, 0x4C4F69, 0x6C6F85, 0x8839EF], 0x40A02B, 0xD20F39, 0xDF8E1D),
]);

ThemePreset themeById(String? id) =>
    builtInThemes.firstWhere((t) => t.id == id, orElse: () => builtInThemes.first);
