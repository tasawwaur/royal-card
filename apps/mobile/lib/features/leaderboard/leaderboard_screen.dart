import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaders = [
      _Leader('RajKumar99', 98750000, 1),
      _Leader('GoldenAce', 75400000, 2),
      _Leader('TeenPattiKing', 52300000, 3),
      _Leader('Player123', 20310000, 4),
      _Leader('LuckyShot', 18000000, 5),
      _Leader('AceOfSpades', 15600000, 6),
      _Leader('RoyalFlush', 12000000, 7),
      _Leader('MaharajaPro', 9500000, 8),
      _Leader('BluffMaster', 8200000, 9),
      _Leader('ChampionX', 7500000, 10),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Leaderboards', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundDark2,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary), onPressed: () => Navigator.pop(context)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('Live Now', style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ]),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            // ── Top 3 Podium ─────────────────────────────────────────────
            _buildPodium(leaders.take(3).toList()),
            const SizedBox(height: 8),
            // ── Rest of list ─────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: leaders.length - 3,
                itemBuilder: (_, i) => _buildLeaderRow(leaders[i + 3]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium(List<_Leader> top3) {
    final order = [top3[1], top3[0], top3[2]]; // 2, 1, 3
    final heights = [100.0, 130.0, 80.0];
    final medals = ['🥈', '🥇', '🥉'];

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) => Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(medals[i], style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 4),
              CircleAvatar(
                radius: i == 1 ? 26 : 20,
                backgroundColor: AppColors.cardSurfaceDark,
                child: Icon(Icons.person, color: i == 1 ? AppColors.goldPrimary : AppColors.textMuted, size: i == 1 ? 28 : 20),
              ),
              const SizedBox(height: 4),
              Text(order[i].name, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 9, fontWeight: FontWeight.bold)),
              Text(_fmt(order[i].chips), style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 9)),
              Container(
                height: heights[i],
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: i == 1
                        ? [AppColors.goldLight, AppColors.goldDark]
                        : i == 0
                        ? [Colors.grey.shade400, Colors.grey.shade700]
                        : [const Color(0xFFCD7F32), const Color(0xFF8B4513)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
                child: Center(child: Text('#${order[i].rank}', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14))),
              ),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildLeaderRow(_Leader l) {
    final isSelf = l.name == 'Player123';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSelf ? AppColors.goldPrimary.withOpacity(0.1) : AppColors.cardSurfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelf ? AppColors.goldBorder : Colors.white10, width: isSelf ? 1.5 : 1),
      ),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('#${l.rank}', style: GoogleFonts.poppins(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13))),
          CircleAvatar(radius: 16, backgroundColor: AppColors.cardSurfaceDark, child: Icon(Icons.person, color: isSelf ? AppColors.goldPrimary : AppColors.textMuted, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(l.name, style: GoogleFonts.poppins(color: isSelf ? AppColors.goldPrimary : AppColors.textPrimary, fontWeight: isSelf ? FontWeight.bold : FontWeight.normal, fontSize: 13))),
          Text(_fmt(l.chips), style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)} Cr';
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)} L';
    return '$v';
  }
}

class _Leader {
  final String name;
  final int chips, rank;
  const _Leader(this.name, this.chips, this.rank);
}
