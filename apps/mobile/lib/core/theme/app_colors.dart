import 'package:flutter/material.dart';

class AppColors {
  // ── Dark Casino Backgrounds ──────────────────────────────────
  static const Color backgroundDark    = Color(0xFF1A0A0A);  // Deep maroon-black
  static const Color backgroundDark2   = Color(0xFF2D0E0E);  // Richer maroon
  static const Color cardSurfaceDark   = Color(0xFF220D0D);  // Card surface
  static const Color surfaceElevated   = Color(0xFF2E1010);  // Elevated surface

  // ── Metallic Gold ────────────────────────────────────────────
  static const Color goldPrimary    = Color(0xFFFFD700);
  static const Color goldSecondary  = Color(0xFFFDB813);
  static const Color goldDark       = Color(0xFFB8860B);
  static const Color goldGlow       = Color(0xFFFFAA00);
  static const Color goldLight      = Color(0xFFFFE57F);
  static const Color goldBorder     = Color(0xFFD4AF37);

  // ── Table Felt ───────────────────────────────────────────────
  static const Color tableFeltDark   = Color(0xFF0A2050);  // Deep blue felt (Andar Bahar)
  static const Color tableFeltMid    = Color(0xFF0D2860);
  static const Color tableFeltLight  = Color(0xFF0F3070);
  static const Color tableGreenDark  = Color(0xFF052415);  // Teen Patti green
  static const Color tableGreenLight = Color(0xFF0B3B24);

  // ── Accent Colors ────────────────────────────────────────────
  static const Color rubyRed      = Color(0xFFCC0000);
  static const Color rubyRedLight = Color(0xFFE60039);
  static const Color emeraldGreen = Color(0xFF00C853);
  static const Color royalPurple  = Color(0xFF6A0DAD);
  static const Color neonBlue     = Color(0xFF00B4FF);
  static const Color orangeAccent = Color(0xFFFF6B00);
  static const Color amberWarm    = Color(0xFFFFB300);

  // ── Text ─────────────────────────────────────────────────────
  static const Color textPrimary  = Color(0xFFFFFFFF);
  static const Color textSecondary= Color(0xFFE0D0B0);
  static const Color textMuted    = Color(0xFFA08860);
  static const Color textDisabled = Color(0xFF666666);

  // ── Chip Colors ──────────────────────────────────────────────
  static const Color chip200  = Color(0xFF4CAF50);  // Green
  static const Color chip500  = Color(0xFF2196F3);  // Blue
  static const Color chip1K   = Color(0xFF9C27B0);  // Purple
  static const Color chip2K   = Color(0xFFE53935);  // Red
  static const Color chip5K   = Color(0xFF795548);  // Brown
  static const Color chip10K  = Color(0xFF212121);  // Black

  // ── Button Colors ────────────────────────────────────────────
  static const Color andarGreen  = Color(0xFF1B8A1B);
  static const Color baharRed    = Color(0xFFAA1111);
  static const Color dealGold    = Color(0xFFB8860B);

  // ── VIP Badge Colors ─────────────────────────────────────────
  static const Color vip1 = Color(0xFF8B7355);
  static const Color vip2 = Color(0xFF9E9E9E);
  static const Color vip3 = Color(0xFFFFD700);
  static const Color vip4 = Color(0xFF00BCD4);
  static const Color vip5 = Color(0xFFE040FB);

  // ── Status ───────────────────────────────────────────────────
  static const Color onlineGreen = Color(0xFF00E676);
  static const Color offlineGray = Color(0xFF757575);

  // ── Gradients ────────────────────────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFE57F), Color(0xFFFFD700), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF2D0E0E), Color(0xFF1A0A0A), Color(0xFF0D0505)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient tableGradient = LinearGradient(
    colors: [Color(0xFF0A2050), Color(0xFF0D2860), Color(0xFF0F3070)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient maharajaGradient = LinearGradient(
    colors: [Color(0xFF6A0DAD), Color(0xFF9C27B0), Color(0xFF4A0080)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient teenPattiGradient = LinearGradient(
    colors: [Color(0xFFCC0000), Color(0xFF880000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rummyGradient = LinearGradient(
    colors: [Color(0xFF0033AA), Color(0xFF001166)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pokerGradient = LinearGradient(
    colors: [Color(0xFF004D00), Color(0xFF002200)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient andarBaharGradient = LinearGradient(
    colors: [Color(0xFF880000), Color(0xFF440000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient tableRadialGlow = RadialGradient(
    colors: [Color(0xFF1A3878), Color(0xFF0A2050)],
    center: Alignment.center,
    radius: 0.8,
  );

  // ── Shadow / Glow ─────────────────────────────────────────────
  static List<BoxShadow> get goldGlowShadow => [
    BoxShadow(color: goldGlow.withOpacity(0.6), blurRadius: 12, spreadRadius: 2),
    BoxShadow(color: goldPrimary.withOpacity(0.3), blurRadius: 24, spreadRadius: 4),
  ];

  static List<BoxShadow> get cardGlowShadow => [
    BoxShadow(color: Colors.black.withOpacity(0.7), blurRadius: 10, offset: const Offset(0, 4)),
    BoxShadow(color: goldBorder.withOpacity(0.2), blurRadius: 8, spreadRadius: 1),
  ];
}
