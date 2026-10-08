import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../theme/app_colors.dart';

/// Native pencere baslik cubugu (TitleBarStyle.hidden) yerine gecen,
/// uygulamanin kendi renk/temasiyla cizilen ust serit. Boylece OS'un
/// siyah/varsayilan baslik cubugu ile alttaki kendi arayuzumuz arasinda
/// "iki ayri kutu" gorunumu olmaz, tek parca gibi durur.
///
/// macOS'ta pencere dugmeleri (kirmizi/sari/yesil) gizlenmez - hidden stilde
/// bile isletim sistemi onlari seridin sol ustune cizmeye devam eder. Bu
/// yuzden macOS'ta kendi kapat/kucult/buyut dugmelerimizi CIZMIYORUZ (yoksa
/// Windows'taki gibi sagda ikinci bir takim olur) ve solda onlara yer
/// birakiyoruz; v2.7.8'de trafik isiklari uygulama adinin uzerine biniyordu.
class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  final AppColors c;
  const TitleBar({super.key, required this.c});

  @override
  Size get preferredSize => const Size.fromHeight(34);

  @override
  Widget build(BuildContext context) {
    final isMac = Platform.isMacOS;
    return Container(
      height: preferredSize.height,
      color: c.bgBase,
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            // macOS'ta baslik cubuguna cift tiklamak pencereyi buyutur/eski
            // haline getirir; native cubugu gizledigimiz icin bunu kendimiz
            // yapiyoruz. Windows'ta da ayni davranis beklenir.
            onDoubleTap: () async {
              if (await windowManager.isMaximized()) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
            },
            child: DragToMoveArea(
            child: Container(
              alignment: Alignment.centerLeft,
              // Trafik isiklari icin yer; Windows'ta serit kenardan baslar.
              padding: EdgeInsets.only(left: isMac ? 78 : 14),
              child: Row(children: [
                Container(
                  width: 18, height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(4)),
                  child: Icon(Icons.terminal, size: 11, color: c.accentInk),
                ),
                const SizedBox(width: 9),
                Text('Network Console', style: TextStyle(color: c.inkFaint, fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: .3)),
              ]),
            ),
            ),
          ),
        ),
        if (!isMac) ...[
          _CaptionButton(icon: Icons.remove, c: c, onTap: () => windowManager.minimize()),
          _MaximizeButton(c: c),
          _CaptionButton(icon: Icons.close, c: c, isClose: true, onTap: () => windowManager.close()),
        ],
      ]),
    );
  }
}

class _MaximizeButton extends StatefulWidget {
  final AppColors c;
  const _MaximizeButton({required this.c});
  @override
  State<_MaximizeButton> createState() => _MaximizeButtonState();
}

class _MaximizeButtonState extends State<_MaximizeButton> with WindowListener {
  bool _maximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.isMaximized().then((v) => mounted ? setState(() => _maximized = v) : null);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _maximized = true);
  @override
  void onWindowUnmaximize() => setState(() => _maximized = false);

  Future<void> _toggle() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  @override
  Widget build(BuildContext context) => _CaptionButton(
        icon: _maximized ? Icons.filter_none : Icons.crop_square,
        c: widget.c,
        iconSize: _maximized ? 12 : 13,
        onTap: _toggle,
      );
}

class _CaptionButton extends StatefulWidget {
  final IconData icon;
  final AppColors c;
  final VoidCallback onTap;
  final bool isClose;
  final double iconSize;
  const _CaptionButton({required this.icon, required this.c, required this.onTap, this.isClose = false, this.iconSize = 13});
  @override
  State<_CaptionButton> createState() => _CaptionButtonState();
}

class _CaptionButtonState extends State<_CaptionButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final hoverBg = widget.isClose ? const Color(0xFFE81123) : widget.c.fillHover;
    final iconColor = widget.isClose && _hover ? Colors.white : widget.c.inkFaint;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 46,
          height: 34,
          alignment: Alignment.center,
          color: _hover ? hoverBg : Colors.transparent,
          child: Icon(widget.icon, size: widget.iconSize, color: iconColor),
        ),
      ),
    );
  }
}
