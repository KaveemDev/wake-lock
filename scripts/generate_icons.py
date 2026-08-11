import math
import os
import struct
import zlib

def make_png(width, height, pixel_bytes_rgba):
    """
    Generates a PNG byte string for raw RGBA bytes of size width*height*4.
    """
    raw_data = bytearray()
    row_bytes = width * 4
    for y in range(height):
        raw_data.append(0) # Filter type 0 (None)
        start = y * row_bytes
        raw_data.extend(pixel_bytes_rgba[start:start + row_bytes])

    compressed = zlib.compress(bytes(raw_data), level=6)

    def make_chunk(chunk_type, data):
        length = len(data)
        crc = zlib.crc32(chunk_type + data) & 0xffffffff
        return struct.pack(">I", length) + chunk_type + data + struct.pack(">I", crc)

    png_header = b"\x89PNG\r\n\x1a\n"
    ihdr_data = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    ihdr_chunk = make_chunk(b"IHDR", ihdr_data)
    idat_chunk = make_chunk(b"IDAT", compressed)
    iend_chunk = make_chunk(b"IEND", b"")

    return png_header + ihdr_chunk + idat_chunk + iend_chunk

STOPS = [
    (0.00, (79, 70, 229)),    # #4F46E5 Indigo
    (0.35, (124, 92, 237)),   # #7C3AED Violet
    (0.70, (236, 72, 153)),   # #EC4899 Magenta
    (1.00, (245, 158, 11)),   # #F59E0B Amber
]

def interpolate_color(t):
    t = max(0.0, min(1.0, t))
    for i in range(len(STOPS) - 1):
        t0, c0 = STOPS[i]
        t1, c1 = STOPS[i+1]
        if t0 <= t <= t1:
            factor = (t - t0) / (t1 - t0)
            r = int(c0[0] + (c1[0] - c0[0]) * factor)
            g = int(c0[1] + (c1[1] - c0[1]) * factor)
            b = int(c0[2] + (c1[2] - c0[2]) * factor)
            return r, g, b
    return STOPS[-1][1]

def dist_to_segment(px, py, x1, y1, x2, y2):
    dx = x2 - x1
    dy = y2 - y1
    if dx == 0 and dy == 0:
        return math.hypot(px - x1, py - y1)
    t = ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy)
    t = max(0.0, min(1.0, t))
    closest_x = x1 + t * dx
    closest_y = y1 + t * dy
    return math.hypot(px - closest_x, py - closest_y)

def rounded_rect_dist(x, y, rx1, ry1, rx2, ry2, radius):
    cx = max(rx1 + radius, min(rx2 - radius, x))
    cy = max(ry1 + radius, min(ry2 - radius, y))
    return math.hypot(x - cx, y - cy) - radius

def render_master_buffer(size=512, transparent_bg=False):
    buffer = bytearray(size * size * 4)
    scale = 1024.0 / size
    idx = 0

    cx, cy = 512, 540
    circle_r = 250.0
    stroke_w = 30.0

    for y in range(size):
        ny = (y + 0.5) * scale
        v = ny / 1024.0
        for x in range(size):
            nx = (x + 0.5) * scale
            u = nx / 1024.0

            if transparent_bg:
                bg_r, bg_g, bg_b, bg_a = 0, 0, 0, 0
            else:
                sq_dist = rounded_rect_dist(nx, ny, 32, 32, 992, 992, 220)
                bg_alpha = max(0.0, min(1.0, 0.5 - sq_dist / 2.0))
                if bg_alpha <= 0:
                    idx += 4
                    continue

                t_grad = (u + v) / 2.0
                gr, gg, gb = interpolate_color(t_grad)

                glow_dist = math.hypot(u - 0.4, v - 0.3)
                glow_factor = max(0.0, 1.0 - glow_dist / 0.75) * 0.35
                gr = min(255, int(gr + (255 - gr) * glow_factor))
                gg = min(255, int(gg + (255 - gg) * glow_factor))
                gb = min(255, int(gb + (255 - gb) * glow_factor))

                inner_dist = abs(sq_dist + 3.0)
                if inner_dist < 3.0:
                    border_alpha = (1.0 - inner_dist / 3.0) * 0.3
                    gr = int(gr + (255 - gr) * border_alpha)
                    gg = int(gg + (255 - gg) * border_alpha)
                    gb = int(gb + (255 - gb) * border_alpha)

                bg_r, bg_g, bg_b, bg_a = gr, gg, gb, int(bg_alpha * 255)

            dist_center = math.hypot(nx - cx, ny - cy)
            d_circle = abs(dist_center - circle_r)
            d_h1 = dist_to_segment(nx, ny, 213, 160, 85, 288)
            d_h2 = dist_to_segment(nx, ny, 939, 288, 811, 160)
            d_l1 = dist_to_segment(nx, ny, 256, 842, 171, 928)
            d_l2 = dist_to_segment(nx, ny, 768, 842, 853, 928)
            d_hand1 = dist_to_segment(nx, ny, 512, 370, 512, 540)
            d_hand2 = dist_to_segment(nx, ny, 512, 540, 597, 625)

            d_min = min(d_circle, d_h1, d_h2, d_l1, d_l2, d_hand1, d_hand2)

            d_min_shadow = min(
                abs(math.hypot(nx - cx, ny - (cy - 10)) - circle_r),
                dist_to_segment(nx, ny - 10, 213, 160, 85, 288),
                dist_to_segment(nx, ny - 10, 939, 288, 811, 160),
                dist_to_segment(nx, ny - 10, 256, 842, 171, 928),
                dist_to_segment(nx, ny - 10, 768, 842, 853, 928),
                dist_to_segment(nx, ny - 10, 512, 370, 512, 540),
                dist_to_segment(nx, ny - 10, 512, 540, 597, 625),
            )
            shadow_alpha = max(0.0, min(1.0, 1.0 - (d_min_shadow - stroke_w) / 18.0)) * 0.4
            stroke_alpha = max(0.0, min(1.0, 0.5 - (d_min - stroke_w) / 4.0))

            if transparent_bg:
                if stroke_alpha > 0:
                    buffer[idx:idx+4] = bytes([255, 255, 255, int(stroke_alpha * 255)])
                elif shadow_alpha > 0:
                    buffer[idx:idx+4] = bytes([15, 23, 42, int(shadow_alpha * 255)])
                idx += 4
                continue

            final_r, final_g, final_b, final_a = bg_r, bg_g, bg_b, bg_a

            if shadow_alpha > 0:
                sr, sg, sb = 15, 23, 42
                sa = shadow_alpha
                final_r = int(final_r * (1 - sa) + sr * sa)
                final_g = int(final_g * (1 - sa) + sg * sa)
                final_b = int(final_b * (1 - sa) + sb * sa)

            if stroke_alpha > 0:
                ir, ig, ib = 255, 255, 255
                ia = stroke_alpha
                final_r = int(final_r * (1 - ia) + ir * ia)
                final_g = int(final_g * (1 - ia) + ig * ia)
                final_b = int(final_b * (1 - ia) + ib * ia)
                final_a = max(final_a, int(ia * 255))

            buffer[idx:idx+4] = bytes([final_r, final_g, final_b, final_a])
            idx += 4

    return buffer

def downsample(src_buffer, src_size, dst_size):
    dst_buffer = bytearray(dst_size * dst_size * 4)
    scale = src_size / dst_size
    dst_idx = 0

    for dy in range(dst_size):
        sy = min(src_size - 1, int((dy + 0.5) * scale))
        for dx in range(dst_size):
            sx = min(src_size - 1, int((dx + 0.5) * scale))
            src_idx = (sy * src_size + sx) * 4
            dst_buffer[dst_idx:dst_idx+4] = src_buffer[src_idx:src_idx+4]
            dst_idx += 4

    return dst_buffer

def generate_all_icons(base_dir):
    print("Rendering 512x512 Master Canvas...")
    master_512_buf = render_master_buffer(512, False)
    fg_512_buf = render_master_buffer(512, True)

    master_1024_buf = downsample(master_512_buf, 512, 1024)
    fg_1024_buf = downsample(fg_512_buf, 512, 1024)

    os.makedirs(os.path.join(base_dir, "assets", "icon"), exist_ok=True)
    with open(os.path.join(base_dir, "assets", "icon", "app_icon.png"), "wb") as f:
        f.write(make_png(1024, 1024, master_1024_buf))
    with open(os.path.join(base_dir, "assets", "icon", "app_icon_foreground.png"), "wb") as f:
        f.write(make_png(1024, 1024, fg_1024_buf))

    # Android targets
    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    res_dir = os.path.join(base_dir, "android", "app", "src", "main", "res")
    for folder, size in android_sizes.items():
        out_folder = os.path.join(res_dir, folder)
        os.makedirs(out_folder, exist_ok=True)
        img_buf = downsample(master_512_buf, 512, size)
        fg_buf = downsample(fg_512_buf, 512, size)
        
        with open(os.path.join(out_folder, "ic_launcher.png"), "wb") as f:
            f.write(make_png(size, size, img_buf))
        with open(os.path.join(out_folder, "ic_launcher_round.png"), "wb") as f:
            f.write(make_png(size, size, img_buf))
        with open(os.path.join(out_folder, "ic_launcher_foreground.png"), "wb") as f:
            f.write(make_png(size, size, fg_buf))
        print(f"Android {folder} ({size}x{size}) ready.")

    # iOS targets
    ios_sizes = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }
    ios_dir = os.path.join(base_dir, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    os.makedirs(ios_dir, exist_ok=True)
    for filename, size in ios_sizes.items():
        img_buf = downsample(master_512_buf, 512, size)
        with open(os.path.join(ios_dir, filename), "wb") as f:
            f.write(make_png(size, size, img_buf))
        print(f"iOS {filename} ({size}x{size}) ready.")

    # Web targets
    web_dir = os.path.join(base_dir, "web")
    web_icons_dir = os.path.join(web_dir, "icons")
    os.makedirs(web_icons_dir, exist_ok=True)
    web_targets = {
        os.path.join(web_dir, "favicon.png"): 32,
        os.path.join(web_icons_dir, "Icon-192.png"): 192,
        os.path.join(web_icons_dir, "Icon-512.png"): 512,
        os.path.join(web_icons_dir, "Icon-maskable-192.png"): 192,
        os.path.join(web_icons_dir, "Icon-maskable-512.png"): 512,
    }
    for path, size in web_targets.items():
        img_buf = downsample(master_512_buf, 512, size)
        with open(path, "wb") as f:
            f.write(make_png(size, size, img_buf))
        print(f"Web {path} ({size}x{size}) ready.")

    # macOS targets
    macos_dir = os.path.join(base_dir, "macos", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    if os.path.exists(os.path.join(base_dir, "macos")):
        os.makedirs(macos_dir, exist_ok=True)
        macos_sizes = {
            "app_icon_16.png": 16,
            "app_icon_32.png": 32,
            "app_icon_64.png": 64,
            "app_icon_128.png": 128,
            "app_icon_256.png": 256,
            "app_icon_512.png": 512,
            "app_icon_1024.png": 1024,
        }
        for filename, size in macos_sizes.items():
            img_buf = downsample(master_512_buf, 512, size)
            with open(os.path.join(macos_dir, filename), "wb") as f:
                f.write(make_png(size, size, img_buf))
            print(f"macOS {filename} ({size}x{size}) ready.")

    print("ALL APP ICONS SUCCESSFULLY GENERATED!")

if __name__ == "__main__":
    generate_all_icons("/Users/vemp/Downloads/Kaveem/Personal/Projects/WakeLock")
