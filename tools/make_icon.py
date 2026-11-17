"""Network Console logosunu (nabiz cizgisi, marka altini) tum boyutlarda uretir.

Kullanim:  python tools/make_icon.py
Yazdiklari: network-console-icon.ico/.png (kok), Windows runner app_icon.ico,
macOS AppIcon.appiconset/app_icon_*.png. Uygulama icindeki logo ayni geometriyi
lib/widgets/app_logo.dart'ta CustomPainter ile cizer - degisirse ikisini de guncelle.
"""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent

BG = (0x17, 0x14, 0x0C, 255)
BORDER = (0x4A, 0x3A, 0x18, 255)
GLOW = (0x6B, 0x52, 0x21, 255)
LINE = (0xF2, 0xC1, 0x4E, 255)
# 150x150 kutuda nabiz cizgisi
PULSE = [(22, 78), (52, 78), (64, 52), (80, 108), (94, 62), (104, 78), (128, 78)]


def render(size, margin=0.0):
    ss = 4  # supersample
    big = size * ss
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    m = big * margin
    box = big - 2 * m
    s = box / 150.0
    radius = 34 * s
    d.rounded_rectangle([m, m, m + box - 1, m + box - 1], radius=radius, fill=BG,
                        outline=BORDER, width=max(int(2 * s), ss))
    # Kucuk boyutlarda cizgi okunur kalsin diye minimum kalinlik (hedef px).
    line_w = max(6 * s, 1.7 * ss)
    glow_w = max(12 * s, line_w * 1.9)
    pts = [(m + x * s, m + y * s) for x, y in PULSE]
    for w, col in ((glow_w, GLOW), (line_w, LINE)):
        d.line(pts, fill=col, width=int(round(w)), joint="curve")
        r = w / 2
        for x, y in (pts[0], pts[-1]):
            d.ellipse([x - r, y - r, x + r, y + r], fill=col)
    return img.resize((size, size), Image.LANCZOS)


def main():
    sizes = [16, 20, 24, 32, 40, 48, 64, 128, 256]
    frames = [render(n) for n in sizes]
    for target in (ROOT / "network-console-icon.ico",
                   ROOT / "flutter_app/windows/runner/resources/app_icon.ico"):
        frames[-1].save(target, format="ICO", sizes=[(n, n) for n in sizes],
                        append_images=frames[:-1])
    render(512).save(ROOT / "network-console-icon.png")
    mac = ROOT / "flutter_app/macos/Runner/Assets.xcassets/AppIcon.appiconset"
    # macOS simge izgarasi: 1024 tuvalde ~824'luk govde, kenarlarda bosluk.
    for n in (16, 32, 64, 128, 256, 512, 1024):
        render(n, margin=0.1 if n >= 64 else 0.04).save(mac / f"app_icon_{n}.png")
    print("ok")


if __name__ == "__main__":
    main()
