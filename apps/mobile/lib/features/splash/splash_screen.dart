import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../routing/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late AnimationController _glowController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _progressAnim;
  late Animation<double> _glowAnim;

  String _loadingText = 'Initializing...';
  final List<String> _loadingSteps = [
    'Loading game assets...',
    'Connecting to servers...',
    'Checking version...',
    'Preparing your table...',
    'Almost ready...',
  ];

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(_glowController);

    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _logoScale   = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.5)));

    _progressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_progressController);

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () => _progressController.forward());

    _progressController.addListener(() {
      final progress = _progressAnim.value;
      final stepIndex = (progress * _loadingSteps.length).clamp(0, _loadingSteps.length - 1).toInt();
      if (mounted) setState(() => _loadingText = _loadingSteps[stepIndex]);
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
        });
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── Logo Section ─────────────────────────────────────────────
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: Column(
                    children: [
                      // Crown Icon with Glow
                      AnimatedBuilder(
                        animation: _glowAnim,
                        builder: (_, child) => Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFFFFD700), Color(0xFF8B0000)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldGlow.withOpacity(_glowAnim.value),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.style, size: 64, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // App Name
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFFE57F), Color(0xFFFFD700), Color(0xFFB8860B)],
                        ).createShader(bounds),
                        child: Text(
                          'TEEN PATTI',
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'G O L D',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 12,
                          color: AppColors.goldSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "India's #1 Card Game",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ── Loading Progress ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _progressAnim,
                      builder: (_, __) => Column(
                        children: [
                          // Progress Bar
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progressAnim.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldDark],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [BoxShadow(color: AppColors.goldGlow.withOpacity(0.6), blurRadius: 8)],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _loadingText,
                            style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Version 5.4.2',
                      style: GoogleFonts.poppins(color: AppColors.textDisabled, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
