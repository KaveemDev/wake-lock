"""Generates the WakeLock launcher icon (padlock with a sunrise) for Android + iOS.

Requires Pillow:  python3 -m pip install pillow
Run from the repo root:  python3 scripts/generate_icons.py
"""
import os
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps

SS = 2048  # supersampled master size; every output is downsampled from this
SUN_TOP, SUN_BOT = (255, 190, 100), (255, 77, 125)
BG_TOP, BG_BOT = (28, 20, 72), (7, 7, 18)


def vgrad(size, top, bot):
    g = Image.linear_gradient("L").resize((size, size))
    return ImageOps.colorize(g, black=top, white=bot).convert("RGBA")


def background():
    bg = vgrad(SS, BG_TOP, BG_BOT)
    # warm dawn glow rising from behind the lock
    glow = Image.new("RGBA", (SS, SS), (0, 0, 0, 0))
    d = ImageDraw.Draw(glow)
    d.ellipse((SS * 0.15, SS * 0.55, SS * 0.85, SS * 1.2), fill=(255, 90, 110, 120))
    glow = glow.filter(ImageFilter.GaussianBlur(SS * 0.12))
    return Image.alpha_composite(bg, glow)


def glyph_mask():
    """Padlock whose body has a sunrise cut out of it. Returns an 'L' mask."""
    k = SS / 1024
    m = Image.new("L", (SS, SS), 0)
    d = ImageDraw.Draw(m)
    # shackle
    w = 74 * k
    d.arc((322 * k, 215 * k, 702 * k, 595 * k), 180, 360, fill=255, width=int(w))
    d.rectangle((322 * k, 405 * k, 322 * k + w, 470 * k), fill=255)
    d.rectangle((702 * k - w, 405 * k, 702 * k, 470 * k), fill=255)
    # body
    d.rounded_rectangle((272 * k, 440 * k, 752 * k, 810 * k), radius=96 * k, fill=255)
    # sunrise cut-out: half sun + horizon bar
    cut = Image.new("L", (SS, SS), 0)
    c = ImageDraw.Draw(cut)
    import math
    cx, cy = 512 * k, 696 * k
    c.pieslice((cx - 84 * k, cy - 84 * k, cx + 84 * k, cy + 84 * k), 180, 360, fill=255)
    c.rounded_rectangle((352 * k, cy, 672 * k, cy + 34 * k), radius=17 * k, fill=255)
    rw = 15 * k  # ray half-width -> round caps
    for deg in (22, 56, 90, 124, 158):
        a_ = math.radians(deg)
        p1 = (cx + math.cos(a_) * 122 * k, cy - math.sin(a_) * 122 * k)
        p2 = (cx + math.cos(a_) * 160 * k, cy - math.sin(a_) * 160 * k)
        c.line((*p1, *p2), fill=255, width=int(rw * 2))
        for px, py in (p1, p2):
            c.ellipse((px - rw, py - rw, px + rw, py + rw), fill=255)
    return ImageChops.subtract(m, cut)


def glyph_layer(mask, scale=1.0):
    g = Image.composite(vgrad(SS, SUN_TOP, SUN_BOT), Image.new("RGBA", (SS, SS), (0, 0, 0, 0)), mask)
    if scale != 1.0:
        n = int(SS * scale)
        small = g.resize((n, n), Image.LANCZOS)
        out = Image.new("RGBA", (SS, SS), (0, 0, 0, 0))
        out.paste(small, ((SS - n) // 2, (SS - n) // 2), small)
        g = out
    return g


def mono_layer(mask, scale=1.0):
    g = Image.composite(Image.new("RGBA", (SS, SS), (255, 255, 255, 255)), Image.new("RGBA", (SS, SS), (0, 0, 0, 0)), mask)
    n = int(SS * scale)
    out = Image.new("RGBA", (SS, SS), (0, 0, 0, 0))
    out.paste(g.resize((n, n), Image.LANCZOS), ((SS - n) // 2, (SS - n) // 2))
    return out


def shape_mask(kind):
    m = Image.new("L", (SS, SS), 0)
    d = ImageDraw.Draw(m)
    if kind == "circle":
        d.ellipse((0, 0, SS - 1, SS - 1), fill=255)
    else:  # rounded square for legacy Android launchers
        d.rounded_rectangle((0, 0, SS - 1, SS - 1), radius=int(SS * 0.22), fill=255)
    return m


def save(img, path, size, flatten=False):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    out = img.resize((size, size), Image.LANCZOS)
    if flatten:  # iOS icons must not contain alpha
        out = out.convert("RGB")
    out.save(path)


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    bg = background()
    mask = glyph_mask()
    full = Image.alpha_composite(bg, glyph_layer(mask))

    # master assets
    save(full, f"{root}/assets/icon/app_icon.png", 1024, flatten=True)
    save(glyph_layer(mask, 0.62), f"{root}/assets/icon/app_icon_foreground.png", 1024)

    # Android: legacy (<26) icons
    def clipped(kind):
        out = Image.new("RGBA", (SS, SS), (0, 0, 0, 0))
        out.paste(Image.alpha_composite(bg, glyph_layer(mask, 0.9)), (0, 0), shape_mask(kind))
        return out

    legacy, round_ = clipped("square"), clipped("circle")
    fg, bgl, mono = glyph_layer(mask, 0.62), bg, mono_layer(mask, 0.62)
    res = f"{root}/android/app/src/main/res"
    for folder, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        save(legacy, f"{res}/mipmap-{folder}/ic_launcher.png", px)
        save(round_, f"{res}/mipmap-{folder}/ic_launcher_round.png", px)
        ad = px * 108 // 48  # adaptive layers are 108dp
        save(fg, f"{res}/mipmap-{folder}/ic_launcher_foreground.png", ad)
        save(bgl, f"{res}/mipmap-{folder}/ic_launcher_background.png", ad)
        save(mono, f"{res}/mipmap-{folder}/ic_launcher_monochrome.png", ad)

    os.makedirs(f"{res}/mipmap-anydpi-v26", exist_ok=True)
    with open(f"{res}/mipmap-anydpi-v26/ic_launcher.xml", "w") as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@mipmap/ic_launcher_background" />\n'
            '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
            '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome" />\n'
            '</adaptive-icon>\n'
        )
    with open(f"{res}/mipmap-anydpi-v26/ic_launcher_round.xml", "w") as f:
        f.write(open(f"{res}/mipmap-anydpi-v26/ic_launcher.xml").read())

    # iOS
    ios = f"{root}/ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for name in os.listdir(ios):
        if name.startswith("Icon-App-") and name.endswith(".png"):
            px = Image.open(f"{ios}/{name}").size[0]
            save(full, f"{ios}/{name}", px, flatten=True)
    print("icons generated")


if __name__ == "__main__":
    main()
