import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

/// Design tokens shared by every screen. They follow the current theme
/// (light/dark + accent), set by [AppColors.apply] from the app root.
class AppColors {
  static bool _dark = true;
  static int _accent = 0;

  static void apply({required bool dark, required int accent}) {
    _dark = dark;
    _accent = accent;
  }

  static bool get isDark => _dark;
  static Color _p(int dark, int light) => Color(_dark ? dark : light);

  static Color get bg => _p(0xFF111113, 0xFFF6F6F7);
  static Color get surface => _p(0xFF1C1C1F, 0xFFFFFFFF);
  static Color get surfaceHi => _p(0xFF2A2A2E, 0xFFF0F0F2);
  static Color get text => _p(0xFFF4F4F5, 0xFF18181B);
  static Color get textDim => _p(0xFFA1A1AA, 0xFF52525B);
  static Color get textFaint => _p(0xFF8A8A93, 0xFF71717A);
  static Color get border => _p(0xFF26262A, 0xFFE4E4E7);
  static Color get accent {
    final a = accentOptions[_accent];
    return _dark ? a.dark : a.light;
  }

  static Color get onAccent => _p(0xFF111113, 0xFFFFFFFF);
  // The old second accent, gold and rose all collapse into the one accent.
  static Color get accent2 => accent;
  static Color get gold => accent;
  static Color get rose => accent;
  static Color get success => _p(0xFF4ADE80, 0xFF15803D);
  static Color get warn => _p(0xFFFACC15, 0xFFA16207);
  static Color get danger => _p(0xFFF87171, 0xFFB91C1C);
  static List<Color> get sunrise => [accent, accent];
}

ThemeData buildAppTheme() {
  final brightness = AppColors.isDark ? Brightness.dark : Brightness.light;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: brightness,
      ).copyWith(
        primary: AppColors.accent,
        onPrimary: AppColors.onAccent,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: AppColors.danger,
      );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _SmoothTransitions(),
        TargetPlatform.iOS: _SmoothTransitions(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: AppColors.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.onAccent
            : AppColors.textDim,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.accent
            : AppColors.surfaceHi,
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      dragHandleColor: AppColors.textFaint,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(backgroundColor: AppColors.surface),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceHi,
      selectedColor: AppColors.accent,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      showCheckmark: false,
    ),
    dividerTheme: DividerThemeData(color: AppColors.border, space: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: AppColors.accent),
  );
}

/// Fade + gentle upward slide, with a shared scale on entry.
class _SmoothTransitions extends PageTransitionsBuilder {
  const _SmoothTransitions();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondary,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    final out = CurvedAnimation(parent: secondary, curve: Curves.easeInCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween(begin: 1.0, end: 0.97).animate(out),
          child: child,
        ),
      ),
    );
  }
}

/// Fades and slides [child] in once, after an optional [delay] (for staggering).
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset offset;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 14),
  });

  /// Delay for the [i]th item of a staggered list (capped so long lists stay snappy).
  static Duration stagger(int i) => Duration(milliseconds: 60 * math.min(i, 8));

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    const dur = 400;
    final total = dur + widget.delay.inMilliseconds;
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: total),
    )..forward();
    _t = CurvedAnimation(
      parent: _c,
      curve: Interval(
        widget.delay.inMilliseconds / total,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (_, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
          offset: widget.offset * (1 - _t.value),
          child: child,
        ),
      ),
    );
  }
}

/// Tap target that springs down slightly while pressed and gives haptic feedback.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap != null && _down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Kept for callers; the flat redesign draws no glow.
class PulseGlow extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double radius;

  const PulseGlow({
    super.key,
    required this.child,
    this.color,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) => child;
}

/// Horizontal shake driven by [trigger] changing (e.g. a wrong-answer counter).
class ShakeOnChange extends StatelessWidget {
  final Object trigger;
  final Widget child;

  const ShakeOnChange({super.key, required this.trigger, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(trigger),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (_, t, c) => Transform.translate(
        offset: Offset(math.sin(t * math.pi * 6) * 10 * (1 - t), 0),
        child: c,
      ),
      child: child,
    );
  }
}

/// Counts a number up from zero when first shown.
class CountUp extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String suffix;

  const CountUp({super.key, required this.value, this.style, this.suffix = ''});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Text('${v.round()}$suffix', style: style),
    );
  }
}

/// Rounded surface used for list rows, tiles and panels.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Gradient? gradient; // ignored: the flat redesign uses solid surfaces
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows; // ignored, see above

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.gradient,
    this.onTap,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: child,
    );
    return onTap == null
        ? box
        : Pressable(onTap: onTap, scale: 0.98, child: box);
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        color: AppColors.textDim,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

/// Small rounded status pill.
class Tag extends StatelessWidget {
  final String text;
  final Color? color; // tints the icon only; the pill itself stays neutral
  final IconData? icon;

  const Tag(this.text, {super.key, this.color, this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.surfaceHi,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: color ?? AppColors.textDim),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

/// Full-width pill button with a solid fill and press spring.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final List<Color>? colors; // first color is the fill; defaults to the accent
  final Color? textColor;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 56,
    this.colors,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final fg = textColor ?? AppColors.onAccent;
    return Pressable(
      onTap: onPressed,
      child: Container(
        height: height,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors?.first ?? AppColors.accent,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: fg, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fg,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kept for callers; the flat redesign has no background glow.
class GlowBackground extends StatelessWidget {
  final Widget child;
  final Color? color;
  const GlowBackground({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) => child;
}

/// Springs [child] in with an elastic scale (success checkmarks, badges).
class PopIn extends StatelessWidget {
  final Widget child;
  const PopIn({super.key, required this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 800),
    curve: Curves.elasticOut,
    builder: (_, v, c) => Transform.scale(scale: v, child: c),
    child: child,
  );
}

/// Thick circular progress that animates smoothly between values, with [child] centred.
class ProgressRing extends StatelessWidget {
  final double value;
  final Widget child;
  final double size;

  const ProgressRing({
    super.key,
    required this.value,
    required this.child,
    this.size = 230,
  });

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value),
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
    builder: (_, v, c) => SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: v,
              strokeWidth: 14,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.surfaceHi,
              color: AppColors.accent,
            ),
          ),
          c!,
        ],
      ),
    ),
    child: child,
  );
}

/// The WakeLock mark: a padlock with a sunrise cut out of its body.
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size * 480 / 595, size), painter: _LogoPainter());
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.height / 595;
    Offset p(double x, double y) => Offset((x - 272) * s, (y - 215) * s);
    final bounds = Offset.zero & size;
    final fill = Paint()
      ..shader = LinearGradient(colors: AppColors.sunrise).createShader(bounds);

    canvas.saveLayer(bounds.inflate(4), Paint());
    final shackle = Path()
      ..moveTo(p(359, 470).dx, p(359, 470).dy)
      ..lineTo(p(359, 405).dx, p(359, 405).dy)
      ..arcTo(
        Rect.fromCircle(center: p(512, 405), radius: 153 * s),
        math.pi,
        math.pi,
        false,
      )
      ..lineTo(p(665, 470).dx, p(665, 470).dy);
    canvas.drawPath(
      shackle,
      Paint()
        ..shader = fill.shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 74 * s,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(p(272, 440), p(752, 810)),
        Radius.circular(96 * s),
      ),
      fill,
    );

    final clear = Paint()..blendMode = BlendMode.clear;
    final c = p(512, 696);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: 84 * s),
      math.pi,
      math.pi,
      true,
      clear,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(p(352, 696), p(672, 730)),
        Radius.circular(17 * s),
      ),
      clear,
    );
    final ray = Paint()
      ..blendMode = BlendMode.clear
      ..strokeWidth = 30 * s
      ..strokeCap = StrokeCap.round;
    for (final deg in [22, 56, 90, 124, 158]) {
      final a = deg * math.pi / 180;
      canvas.drawLine(
        c + Offset(math.cos(a), -math.sin(a)) * 122 * s,
        c + Offset(math.cos(a), -math.sin(a)) * 160 * s,
        ray,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true; // accent can change
}
