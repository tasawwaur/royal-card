import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/game_models.dart';
import '../../routing/app_routes.dart';
import '../rewards/rewards_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedNav = 0;
  final PlayerModel _player = PlayerModel.demo();
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnim;
  final PageController _bannerController = PageController();
  int _bannerPage = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Auto-scroll banner
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      final next = (_bannerPage + 1) % 3;
      _bannerController.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      setState(() => _bannerPage = next);
      return true;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildBannerRow(),
                      const SizedBox(height: 10),
                      _buildGameCardsRow(),
                      const SizedBox(height: 14),
                      _buildQuickAccessGrid(),
                    ],
                  ),
                ),
              ),
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  // ── TOP BAR ─────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark2.withOpacity(0.95),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          // ── Player Avatar + VIP ───────────────────────────────────────
          _buildPlayerAvatar(),
          const SizedBox(width: 8),

          // ── Chips Balance ─────────────────────────────────────────────
          _buildChipsBalance(),
          const SizedBox(width: 6),

          // ── Total Balance (Matka) ─────────────────────────────────────
          _buildTotalBalance(),
          const Spacer(),

          // ── Maharaja Pack ─────────────────────────────────────────────
          _buildMaharajaPack(),
          const SizedBox(width: 6),

          // ── Mail + Settings ───────────────────────────────────────────
          _buildIconButton(Icons.mail_outlined, badge: '5', onTap: () {}),
          const SizedBox(width: 4),
          _buildIconButton(Icons.settings_outlined, onTap: () => Navigator.pushNamed(context, AppRoutes.settings)),
          const SizedBox(width: 6),
          // Online
          _buildOnlineCount(),
        ],
      ),
    );
  }

  Widget _buildPlayerAvatar() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.goldPrimary, width: 2),
              gradient: const RadialGradient(colors: [Color(0xFF333333), Color(0xFF111111)]),
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.person, color: AppColors.goldPrimary, size: 26),
            ),
          ),
          // Edit pencil
          Positioned(
            right: -2, top: -2,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(color: AppColors.goldPrimary, shape: BoxShape.circle),
              child: const Icon(Icons.edit, size: 9, color: Colors.black),
            ),
          ),
          // VIP Badge
          Positioned(
            bottom: -8, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.vip3,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('VIP ${_player.vipLevel}', style: GoogleFonts.poppins(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipsBalance() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.wallet),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22, height: 22,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.amber),
                child: const Center(child: Text('₹', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 4),
              Text(_player.formattedChips, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 4),
              Container(
                width: 18, height: 18,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.goldPrimary),
                child: const Icon(Icons.add, size: 12, color: Colors.black),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.diamond, color: Colors.purpleAccent, size: 12),
              const SizedBox(width: 4),
              Text('${_player.gems}', style: GoogleFonts.poppins(color: Colors.purpleAccent, fontSize: 11)),
            ],
          ),
          Text('${_player.name}  ID: ${_player.id}', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildTotalBalance() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          const Icon(Icons.sports_kabaddi, color: AppColors.goldPrimary, size: 18),
          Text(_player.formattedBalance,
            style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 10)),
          Text('Total Balance', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 7)),
          Row(
            children: [
              const Icon(Icons.access_time, size: 8, color: AppColors.textMuted),
              const SizedBox(width: 2),
              Text('4d 06h', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 7)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaharajaPack() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.rubyRed.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.goldBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: AppColors.goldPrimary, size: 12),
              const SizedBox(width: 2),
              Text('75+Cr', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
            child: Text('165% Extra', style: GoogleFonts.poppins(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
          ),
          Text('20 Cr', style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 8)),
          Text('Packs Left', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 7)),
          Text('1 3 9', style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {String? badge, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.cardSurfaceDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
          if (badge != null)
            Positioned(
              right: -4, top: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOnlineCount() {
    return Row(
      children: [
        Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.onlineGreen, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text('128 Online', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 9)),
      ],
    );
  }

  // ── BANNER ROW (Left: Rank / Center: Maharaja / Right: Game cards) ──────
  Widget _buildBannerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: Rank Card ─────────────────────────────────────────
          _buildRankCard(),
          const SizedBox(width: 8),
          // ── Center + Right: Game Cards PageView ─────────────────────
          Expanded(child: _buildGameBannerSlider()),
        ],
      ),
    );
  }

  Widget _buildRankCard() {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.goldDark]),
              boxShadow: AppColors.goldGlowShadow,
            ),
            child: const Center(child: Icon(Icons.diamond, color: Colors.black, size: 28)),
          ),
          const SizedBox(height: 8),
          Text('Rank ${_player.rank}', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          // XP Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: _player.xp / _player.xpMax,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 3),
          Text('${_player.xp}/${_player.xpMax}',
            style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 9)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, size: 9, color: AppColors.textMuted),
              const SizedBox(width: 2),
              Text('10h 16m left', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameBannerSlider() {
    return SizedBox(
      height: 195,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _bannerController,
              onPageChanged: (i) => setState(() => _bannerPage = i),
              children: [
                _buildMaharajaBanner(),
                _buildTeenPattiBanner(),
                _buildAndarBaharBanner(),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _bannerPage == i ? 16 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: _bannerPage == i ? AppColors.goldPrimary : Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildMaharajaBanner() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.gameLobby),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          gradient: AppColors.maharajaGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldBorder, width: 1.5),
        ),
        child: Stack(
          children: [
            // HOT Badge
            Positioned(
              top: 0, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(
                  color: AppColors.rubyRed,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                ),
                child: Text('HOT', style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.workspace_premium, color: AppColors.goldPrimary, size: 36),
                  Text('MAHARAJA', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text('Max 2 Per Player', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.goldDark]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sports_kabaddi, color: Colors.black87, size: 16),
                        const SizedBox(width: 6),
                        Text('15 Cr', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeenPattiBanner() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.teenPatti),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          gradient: AppColors.teenPattiGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldBorder, width: 1.5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('TEEN PATTI', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['A', 'A', '♠'].map((c) => _buildSmallCard(c)).toList(),
              ),
              const SizedBox(height: 8),
              Text('Play Now', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAndarBaharBanner() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.andarBahar),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          gradient: AppColors.andarBaharGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldBorder, width: 1.5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ANDAR BAHAR', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircleLetter('A', AppColors.andarGreen),
                  const SizedBox(width: 16),
                  _buildCircleLetter('B', AppColors.baharRed),
                ],
              ),
              const SizedBox(height: 8),
              Text('2X Payout', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallCard(String text) {
    return Container(
      width: 30, height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.goldBorder, width: 1),
      ),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13))),
    );
  }

  Widget _buildCircleLetter(String letter, Color color) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: AppColors.goldBorder, width: 2),
      ),
      child: Center(child: Text(letter, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22))),
    );
  }

  // ── GAME CARDS ROW ────────────────────────────────────────────────────────
  Widget _buildGameCardsRow() {
    final games = [
      _GameCard(label: 'TEEN\nPATTI', gradient: AppColors.teenPattiGradient, route: AppRoutes.teenPatti),
      _GameCard(label: 'RUMMY', gradient: AppColors.rummyGradient, route: AppRoutes.gameLobby),
      _GameCard(label: 'POKER', gradient: AppColors.pokerGradient, route: AppRoutes.gameLobby),
      _GameCard(label: 'ANDAR\nBAHAR', gradient: AppColors.andarBaharGradient, route: AppRoutes.andarBahar),
    ];
    return SizedBox(
      height: 115,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: games.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => Navigator.pushNamed(context, games[i].route),
          child: Container(
            width: 90,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              gradient: games[i].gradient,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.goldBorder, width: 1.5),
              boxShadow: AppColors.cardGlowShadow,
            ),
            child: Center(
              child: Text(
                games[i].label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── QUICK ACCESS GRID ─────────────────────────────────────────────────────
  Widget _buildQuickAccessGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // ── Top Row: Free Chest, Daily Target, Leaderboard ─────────────
          Row(
            children: [
              _buildQuickTile(Icons.inventory_2, 'Free Chest', '30L', '16h 13m', Colors.orange, () => Navigator.pushNamed(context, AppRoutes.rewards)),
              const SizedBox(width: 8),
              _buildQuickTile(Icons.track_changes, 'Daily Target', '1', '10h 13m', AppColors.rubyRed, () => Navigator.pushNamed(context, AppRoutes.rewards)),
              const SizedBox(width: 8),
              _buildQuickTile(Icons.leaderboard, 'Leaderboards', null, 'Live Now', Colors.blue, () => Navigator.pushNamed(context, AppRoutes.leaderboard)),
            ],
          ),
          const SizedBox(height: 10),

          // ── Voice Room Banner ────────────────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.social),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2C1654), Color(0xFF8B1A8B)]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.goldBorder, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Talk to your friends!', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 10)),
                        Text('Voice Room', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.w900, fontSize: 18)),
                        Text('Join Now!', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.mic, color: AppColors.goldPrimary, size: 44),
                  const Icon(Icons.headset, color: Colors.purpleAccent, size: 36),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Bottom Row: Lucky Cards, Bazaar, Gift, Invite ──────────────
          Row(
            children: [
              _buildIconTile(Icons.style, 'Lucky Cards', '6 Cr', AppColors.goldPrimary, () => Navigator.pushNamed(context, AppRoutes.store)),
              const SizedBox(width: 8),
              _buildIconTile(Icons.emoji_emotions, 'Bazaar', null, Colors.yellow, () => Navigator.pushNamed(context, AppRoutes.store)),
              const SizedBox(width: 8),
              _buildIconTile(Icons.card_giftcard, 'Gift', null, Colors.pinkAccent, () => Navigator.pushNamed(context, AppRoutes.social)),
              const SizedBox(width: 8),
              _buildIconTile(Icons.person_add, 'Invite', null, AppColors.neonBlue, () => Navigator.pushNamed(context, AppRoutes.social)),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildQuickTile(IconData icon, String label, String? badge, String sub, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.cardSurfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: color, size: 32),
                  if (badge != null)
                    Positioned(
                      right: -8, top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.w600)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, size: 9, color: AppColors.textMuted),
                  const SizedBox(width: 2),
                  Text(sub, style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 8)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconTile(IconData icon, String label, String? subtitle, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.cardSurfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 9, fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: 3),
              Text(label, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 9, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // ── BOTTOM NAVIGATION ─────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      _NavItem(Icons.home_rounded, 'Home', AppRoutes.home),
      _NavItem(Icons.people_rounded, 'Friends', AppRoutes.social),
      _NavItem(Icons.chat_bubble_rounded, 'Chat', AppRoutes.social),
      _NavItem(Icons.headset_mic_rounded, 'Support', AppRoutes.settings),
      _NavItem(Icons.mail_rounded, 'Mail', AppRoutes.social),
      _NavItem(Icons.workspace_premium, 'VIP', AppRoutes.profile),
      _NavItem(Icons.more_horiz_rounded, 'More', AppRoutes.settings),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark2,
        border: Border(top: BorderSide(color: AppColors.goldBorder, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isSelected = i == _selectedNav;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedNav = i);
              if (item.route != AppRoutes.home) Navigator.pushNamed(context, item.route);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(item.icon, color: isSelected ? AppColors.goldPrimary : AppColors.textMuted, size: 24),
                    if (item.label == 'Chat' || item.label == 'Mail')
                      Positioned(
                        right: -6, top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text(item.label == 'Chat' ? '3' : '5', style: const TextStyle(color: Colors.white, fontSize: 7)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(item.label,
                  style: GoogleFonts.poppins(
                    color: isSelected ? AppColors.goldPrimary : AppColors.textMuted,
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  )),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _GameCard {
  final String label;
  final LinearGradient gradient;
  final String route;
  const _GameCard({required this.label, required this.gradient, required this.route});
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(this.icon, this.label, this.route);
}
