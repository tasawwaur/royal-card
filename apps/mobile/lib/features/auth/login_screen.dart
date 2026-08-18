import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../routing/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  final _phoneController = TextEditingController();
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _continueAsGuest() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _loginWithPhone() {
    if (_phoneController.text.length == 10) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),

                  // ── Logo Header ──────────────────────────────────────────
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFFE57F), Color(0xFFFFD700), Color(0xFFB8860B)],
                    ).createShader(bounds),
                    child: Text('TEEN PATTI GOLD',
                      style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white),
                    ),
                  ),
                  Text('Play • Win • Celebrate!',
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted, letterSpacing: 1),
                  ),
                  const SizedBox(height: 40),

                  // ── Card Illustration ────────────────────────────────────
                  _buildCardIllustration(),
                  const SizedBox(height: 40),

                  // ── Guest Login ──────────────────────────────────────────
                  GestureDetector(
                    onTap: _continueAsGuest,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFB8860B)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppColors.goldGlowShadow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_outline, color: Colors.black87, size: 22),
                          const SizedBox(width: 10),
                          Text('Play as Guest',
                            style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Divider ──────────────────────────────────────────────
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 12)),
                      ),
                      const Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Mobile Login ─────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardSurfaceDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.goldBorder.withOpacity(0.4)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Text('+91', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        const SizedBox(height: 40, child: VerticalDivider(color: Colors.white24, width: 1)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: GoogleFonts.poppins(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Enter Mobile Number',
                              hintStyle: GoogleFonts.poppins(color: AppColors.textMuted),
                              border: InputBorder.none,
                              counterText: '',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  GestureDetector(
                    onTap: _loginWithPhone,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurfaceDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.goldBorder, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone_android, color: AppColors.goldPrimary, size: 20),
                          const SizedBox(width: 10),
                          Text('Login with Mobile', style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── Terms ────────────────────────────────────────────────
                  Text(
                    'By continuing, you agree to our Terms of Service\nand Privacy Policy. 18+ only.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: AppColors.textDisabled, fontSize: 10),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardIllustration() {
    final suits = ['♠', '♥', '♣', '♦'];
    final ranks = ['A', 'K', 'Q'];
    return SizedBox(
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < 3; i++)
            Positioned(
              left: 60.0 + (i * 50),
              child: Transform.rotate(
                angle: (i - 1) * 0.25,
                child: _buildSingleCard(ranks[i], suits[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleCard(String rank, String suit) {
    final isRed = suit == '♥' || suit == '♦';
    return Container(
      width: 72,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.goldBorder, width: 2),
        boxShadow: AppColors.cardGlowShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rank, style: TextStyle(color: isRed ? Colors.red : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(suit, style: TextStyle(color: isRed ? Colors.red : Colors.black87, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
