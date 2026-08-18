import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/state/player_state.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerState>(
      builder: (ctx, player, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          appBar: AppBar(
            title: Text('Wallet', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.backgroundDark2,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary), onPressed: () => Navigator.pop(ctx)),
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Real Balance Card ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.goldLight]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppColors.goldGlowShadow,
                  ),
                  child: Column(children: [
                    Text('Total Balance', style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 6),
                    // ← REAL balance from PlayerState
                    Text(player.formattedChips, style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 36)),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _walletStat('🪙 Chips', player.formattedChips),
                      _walletStat('💎 Gems', '${player.gems}'),
                      _walletStat('⭐ Level', '${player.level}'),
                    ]),
                    const SizedBox(height: 8),
                    // XP bar
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('XP Progress', style: GoogleFonts.poppins(color: Colors.black54, fontSize: 10)),
                        Text('${player.xp}/${player.xpMax}', style: GoogleFonts.poppins(color: Colors.black54, fontSize: 10)),
                      ]),
                      const SizedBox(height: 4),
                      ClipRRect(borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: player.xp / player.xpMax,
                          backgroundColor: Colors.black12,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.black54),
                          minHeight: 6)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),

                // ── Stats ─────────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.cardSurfaceDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
                  child: Column(children: [
                    Text('Game Stats', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    _statRow('Games Played',  '${player.gamesPlayed}',  Icons.sports_esports),
                    _statRow('Games Won',     '${player.gamesWon}',     Icons.emoji_events),
                    _statRow('Win Rate',      '${player.winRate.toStringAsFixed(1)}%', Icons.percent),
                    _statRow('Biggest Win',   player.biggestWin > 0 ? _fmt(player.biggestWin) : '—', Icons.monetization_on),
                  ]),
                ),
                const SizedBox(height: 16),

                // ── Add Chips ─────────────────────────────────────────────────
                Text('Add Chips', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.15,
                  children: [
                    _chipPkg(ctx, player, '10K',  10058,   '₹10'),
                    _chipPkg(ctx, player, '50K',  50000,   '₹40'),
                    _chipPkg(ctx, player, '1 L',  100000,  '₹80'),
                    _chipPkg(ctx, player, '5 L',  500000,  '₹350',  isHot: true),
                    _chipPkg(ctx, player, '20 L', 2000000, '₹1,200'),
                    _chipPkg(ctx, player, '1 Cr', 10000000,'₹5,999', isHot: true),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Transaction History (real from PlayerState) ────────────────
                Text('Transaction History', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                if (player.transactions.isEmpty)
                  Center(child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text('No transactions yet.\nPlay a game to see history!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 12))))
                else
                  for (final tx in player.transactions.reversed.take(20))
                    _txRow(tx),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _walletStat(String label, String value) => Column(children: [
    Text(label, style: GoogleFonts.poppins(color: Colors.black54, fontSize: 11)),
    Text(value, style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
  ]);

  Widget _statRow(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Icon(icon, color: AppColors.goldPrimary, size: 18),
      const SizedBox(width: 10),
      Text(label, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 12)),
      const Spacer(),
      Text(value, style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
    ]),
  );

  Widget _chipPkg(BuildContext ctx, PlayerState player, String chips, int amount, String price, {bool isHot = false}) {
    return GestureDetector(
      onTap: () {
        // Simulate in-app purchase granting chips
        player.claimDailyBonus(amount); // in real app: IAP receipt validation
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text('+$chips chips added!'), backgroundColor: AppColors.emeraldGreen,
          duration: const Duration(seconds: 2)));
      },
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardSurfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isHot ? AppColors.goldPrimary : Colors.white12, width: isHot ? 1.5 : 1)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.monetization_on, color: AppColors.goldPrimary, size: 26),
            Text(chips, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(price, style: GoogleFonts.poppins(color: AppColors.goldSecondary, fontSize: 11)),
          ]),
        ),
        if (isHot) Positioned(top: -6, right: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(color: AppColors.rubyRed, borderRadius: BorderRadius.circular(5)),
            child: Text('HOT', style: GoogleFonts.poppins(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)))),
      ]),
    );
  }

  Widget _txRow(WalletTransaction tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: AppColors.cardSurfaceDark, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)),
      child: Row(children: [
        Icon(tx.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
          color: tx.isCredit ? AppColors.emeraldGreen : AppColors.rubyRed, size: 16),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx.label, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 12)),
          Text('${tx.timestamp.hour}:${tx.timestamp.minute.toString().padLeft(2, '0')}',
            style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 9)),
        ])),
        Text('${tx.isCredit ? '+' : '-'}${tx.formattedAmount}',
          style: GoogleFonts.poppins(color: tx.isCredit ? AppColors.emeraldGreen : AppColors.rubyRed, fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    );
  }

  String _fmt(int v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000)     return '${(v / 1000).toStringAsFixed(0)}K';
    return '$v';
  }
}
