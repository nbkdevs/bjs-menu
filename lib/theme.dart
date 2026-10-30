import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette mirrored from bjsmenus.com (site.css / meal-builder.css).
class C {
  static const red = Color(0xFFA91F2B);
  static const redDark = Color(0xFF861822);
  static const redTint = Color(0xFFF6E4E5);
  static const ink = Color(0xFF2B2B2B);
  static const body = Color(0xFF4D443E);
  static const muted = Color(0xFF6A645E);
  static const faint = Color(0xFF767068);
  static const bg = Color(0xFFF7F5F0);
  static const bgAlt = Color(0xFFECE9E2);
  static const card = Color(0xFFFFFDF9);
  static const field = Color(0xFFF1EADF);
  static const line = Color(0x244D443E);
  static const lineStrong = Color(0x524D443E);
}

TextStyle serif(double size, {FontWeight w = FontWeight.w700, Color c = C.ink}) =>
    // Gelasio is metric-compatible with Georgia, the site's heading face (Georgia isn't on Android).
    GoogleFonts.gelasio(fontSize: size, fontWeight: w, color: c, height: 1.15);

TextStyle eyebrow({Color c = C.red}) =>
    GoogleFonts.bricolageGrotesque(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: c);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: C.red, primary: C.red, surface: C.bg),
    scaffoldBackgroundColor: C.bg,
    fontFamily: GoogleFonts.bricolageGrotesque().fontFamily,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: C.body, displayColor: C.ink),
    appBarTheme: const AppBarTheme(backgroundColor: C.bg, surfaceTintColor: Colors.transparent, elevation: 0, foregroundColor: C.ink),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: C.red,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: GoogleFonts.bricolageGrotesque(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: C.ink,
        side: const BorderSide(color: C.lineStrong),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.bricolageGrotesque(fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: C.card,
      indicatorColor: C.redTint,
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(color: s.contains(WidgetState.selected) ? C.red : C.muted)),
    ),
    snackBarTheme: const SnackBarThemeData(backgroundColor: C.ink, behavior: SnackBarBehavior.floating, actionTextColor: Color(0xFFFFB4B9)),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: C.card, showDragHandle: true, surfaceTintColor: Colors.transparent),
  );
}

/// Rounded cream card used throughout, like the site's .card panels.
class PanelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final bool accentTop;
  const PanelCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.accentTop = false});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: C.line),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 6))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (accentTop) Container(height: 5, color: C.red),
          Padding(padding: padding, child: child),
        ]),
      );
}

class ItemThumb extends StatelessWidget {
  final String? url;
  final String name;
  final double size;
  const ItemThumb(this.url, this.name, {super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final ph = Container(
      width: size,
      height: size,
      color: C.redTint,
      alignment: Alignment.center,
      child: Text(name.isEmpty ? '?' : name[0], style: serif(size * .4, c: C.red)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: url == null
          ? ph
          : Image.network(url!, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, _, _) => ph,
              loadingBuilder: (_, child, p) => p == null ? child : ph),
    );
  }
}
