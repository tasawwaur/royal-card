import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _spinUsed = false;
  int _dailyBonusClaimed = 3; // day 3 of streak

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Rewards', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundDark2,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary), onPressed: () => Navigator.pop(context)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.goldPrimary,
          labelColor: AppColors.goldPrimary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11),
          tabs: const [
            Tab(text: 'Lucky Cards'),
            Tab(text: 'Daily Bonus'),
            Tab(text: 'Chest'),
            Tab(text: 'Achievements'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildLuckyCards(),
            _buildDailyBonus(),
            _buildChest(),
            _buildAchievements(),
          ],
        ),
      ),
    );
  }

  // ── Lucky Cards ────────────────────────────────────────────────────────────
  Widget _buildLuckyCards() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.style, color: AppColors.goldPrimary, size: 72),
            const SizedBox(height: 16),
            Text('Lucky Cards', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 8),
            Text('Collect 6 Lucky Cards to win massive rewards!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) => Container(
                width: 44, height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: i < 2 ? AppColors.goldPrimary.withOpacity(0.9) : AppColors.cardSurfaceDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: i < 2 ? AppColors.goldPrimary : Colors.white24, width: 1.5),
                ),
                child: Center(child: Icon(
                  i < 2 ? Icons.star : Icons.question_mark,
                  color: i < 2 ? Colors.black : Colors.white24, size: 20)),
              )),
            ),
            const SizedBox(height: 8),
            Text('2/6 Collected • 6 Cr Reward', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.goldDark]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.goldGlowShadow,
              ),
              child: Text('Play to Collect Cards', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Daily Bonus ────────────────────────────────────────────────────────────
  Widget _buildDailyBonus() {
    final bonuses = [
      _Bonus('Day 1', '10,000', false, true),
      _Bonus('Day 2', '25,000', false, true),
      _Bonus('Day 3', '50,000', true, false),
      _Bonus('Day 4', '1 L', false, false),
      _Bonus('Day 5', '2 L', false, false),
      _Bonus('Day 6', '5 L', false, false),
      _Bonus('Day 7 🎁', '10 L + Gems', false, false),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Login Streak Rewards', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text('Keep your streak for bigger rewards!', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.9,
          children: bonuses.map((b) => _buildBonusDay(b)).toList(),
        ),
        const SizedBox(height: 20),
        if (bonuses[_dailyBonusClaimed - 1].isCurrent)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.goldDark]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppColors.goldGlowShadow,
            ),
            child: Center(child: Text('Claim Day $_dailyBonusClaimed Bonus!',
              style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16))),
          ),
      ],
    );
  }

  Widget _buildBonusDay(_Bonus b) {
    return Container(
      decoration: BoxDecoration(
        color: b.isCurrent ? AppColors.goldPrimary.withOpacity(0.15) : AppColors.cardSurfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: b.isCurrent ? AppColors.goldPrimary : b.isClaimed ? Colors.green : Colors.white12, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (b.isClaimed)
            const Icon(Icons.check_circle, color: Colors.green, size: 22)
          else
            Icon(Icons.monetization_on, color: b.isCurrent ? AppColors.goldPrimary : AppColors.textMuted, size: 22),
          const SizedBox(height: 4),
          Text(b.day, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: b.isCurrent ? AppColors.goldPrimary : AppColors.textMuted, fontSize: 8, fontWeight: FontWeight.bold)),
          Text(b.reward, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 7)),
        ],
      ),
    );
  }

  // ── Chest ─────────────────────────────────────────────────────────────────
  Widget _buildChest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              child: const Icon(Icons.inventory_2, color: Colors.orange, size: 80),
            ),
            const SizedBox(height: 16),
            Text('Free Chest', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 22)),
            Text('30 L Prize Pool', style: GoogleFonts.poppins(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('Opens in 16h 13m', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.cardSurfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.goldBorder),
              ),
              child: Text('Open with 💎 10 Gems', style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Achievements ──────────────────────────────────────────────────────────
  Widget _buildAchievements() {
    final achievements = [
      _Achievement('First Win', 'Win your first game', true, 0),
      _Achievement('Hot Streak', 'Win 5 games in a row', true, 1),
      _Achievement('High Roller', 'Win a bet of 1L+', false, 2),
      _Achievement('Social Butterfly', 'Add 10 friends', false, 3),
      _Achievement('Lucky Charm', 'Win with a trail', false, 4),
      _Achievement('Master Player', 'Reach Level 50', false, 5),
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (_, i) => _buildAchievementCard(achievements[i]),
    );
  }

  Widget _buildAchievementCard(_Achievement a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: a.isUnlocked ? AppColors.goldBorder : Colors.white10, width: a.isUnlocked ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: a.isUnlocked ? AppColors.goldPrimary.withOpacity(0.2) : Colors.white10,
            ),
            child: Icon(
              a.isUnlocked ? Icons.emoji_events : Icons.lock_outline,
              color: a.isUnlocked ? AppColors.goldPrimary : AppColors.textDisabled,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title, style: GoogleFonts.poppins(color: a.isUnlocked ? AppColors.goldPrimary : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(a.description, style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          if (a.isUnlocked)
            const Icon(Icons.check_circle, color: Colors.green, size: 22),
        ],
      ),
    );
  }
}

class _Bonus {
  final String day, reward;
  final bool isCurrent, isClaimed;
  const _Bonus(this.day, this.reward, this.isCurrent, this.isClaimed);
}

class _Achievement {
  final String title, description;
  final bool isUnlocked;
  final int index;
  const _Achievement(this.title, this.description, this.isUnlocked, this.index);
}
