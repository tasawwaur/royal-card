import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/game_models.dart';
import '../../routing/app_routes.dart';

class GameLobbyScreen extends StatelessWidget {
  const GameLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rooms = [
      GameRoom(tableId: 'T101', type: GameType.teenPatti, minBet: 100, maxBet: 1000, onlinePlayers: 4, variation: 'Classic'),
      GameRoom(tableId: 'T102', type: GameType.teenPatti, minBet: 500, maxBet: 5000, onlinePlayers: 3, variation: 'Joker'),
      GameRoom(tableId: 'T103', type: GameType.teenPatti, minBet: 1000, maxBet: 10000, onlinePlayers: 5, variation: 'Muflis'),
      GameRoom(tableId: 'A101', type: GameType.andarBahar, minBet: 200, maxBet: 5000, onlinePlayers: 3, variation: 'Classic'),
      GameRoom(tableId: 'A102', type: GameType.andarBahar, minBet: 1000, maxBet: 20000, onlinePlayers: 4, variation: '2X Payout'),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Game Lobby', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundDark2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            // Tabs
            _buildGameTabs(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: rooms.length,
                itemBuilder: (_, i) => _buildRoomCard(context, rooms[i]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.goldPrimary,
        label: Text('Create Private Room', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildGameTabs() {
    return Container(
      height: 44,
      color: AppColors.cardSurfaceDark,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        children: ['All', 'Teen Patti', 'Andar Bahar', 'Rummy', 'Poker'].map((tab) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: tab == 'All' ? AppColors.goldPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tab == 'All' ? AppColors.goldPrimary : Colors.white24),
            ),
            child: Text(tab, style: GoogleFonts.poppins(
              color: tab == 'All' ? Colors.black : AppColors.textMuted,
              fontWeight: FontWeight.w600, fontSize: 12)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, GameRoom room) {
    final isAB = room.type == GameType.andarBahar;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, isAB ? AppRoutes.andarBahar : AppRoutes.teenPatti),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardSurfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.goldBorder.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: isAB ? AppColors.andarBaharGradient : AppColors.teenPattiGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(isAB ? 'AB' : 'TP', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Table ${room.tableId}', style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${room.variation} • ${room.onlinePlayers}/5 Players', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 11)),
                  Text('Bet: ${_fmt(room.minBet)} - ${_fmt(room.maxBet)}', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 11)),
                ],
              ),
            ),
            // Join button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.goldDark]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('JOIN', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 1000) return '${v ~/ 1000}K';
    return '$v';
  }
}
