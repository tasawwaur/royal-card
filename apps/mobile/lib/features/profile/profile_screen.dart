import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/game_models.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = PlayerModel.demo();
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.backgroundDark2, AppColors.backgroundDark.withOpacity(0.9)],
                    ),
                    border: const Border(bottom: BorderSide(color: AppColors.goldBorder, width: 1)),
                  ),
                  child: Column(
                    children: [
                      // Back
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Avatar
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 90, height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.goldPrimary, width: 3),
                              gradient: const RadialGradient(colors: [Color(0xFF444444), Color(0xFF111111)]),
                              boxShadow: AppColors.goldGlowShadow,
                            ),
                            child: const Icon(Icons.person, color: AppColors.goldPrimary, size: 52),
                          ),
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(color: AppColors.goldPrimary, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
                            child: const Icon(Icons.edit, size: 14, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(player.name, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20)),
                      Text('ID: ${player.id}', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 12)),
                      const SizedBox(height: 8),
                      // VIP Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.goldDark]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('⭐ VIP ${player.vipLevel} • Level ${player.level}',
                          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ),

                // ── Stats ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildStatRow('Games Played', '${player.stats.gamesPlayed}', Icons.sports_esports),
                      _buildStatRow('Games Won', '${player.stats.gamesWon}', Icons.emoji_events),
                      _buildStatRow('Win Rate', '${player.stats.winRate.toStringAsFixed(1)}%', Icons.percent),
                      _buildStatRow('Biggest Win', _fmt(player.stats.biggestWin), Icons.monetization_on),
                      _buildStatRow('Total Earnings', _fmt(player.stats.totalEarnings), Icons.account_balance_wallet),
                      const SizedBox(height: 20),

                      // XP Bar
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurfaceDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Experience', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold)),
                                Text('${player.xp} / ${player.xpMax} XP', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: player.xp / player.xpMax,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.goldPrimary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13)),
          const Spacer(),
          Text(value, style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)} Cr';
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)} L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return '$v';
  }
}
