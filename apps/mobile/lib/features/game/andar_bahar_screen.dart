import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AndarBaharScreen extends StatefulWidget {
  const AndarBaharScreen({super.key});

  @override
  State<AndarBaharScreen> createState() => _AndarBaharScreenState();
}

class _AndarBaharScreenState extends State<AndarBaharScreen> {
  int currentBet = 500;
  String? selectedSpot;
  bool isDealing = false;
  String? winningSpot;
  String jokerCardText = "4 ♣";
  List<String> andarCards = [];
  List<String> baharCards = [];

  void adjustBet(int delta) {
    if (isDealing) return;
    setState(() {
      currentBet = (currentBet + delta).clamp(100, 10000);
    });
  }

  void placeBetAndPlay(String spot) {
    if (isDealing) return;
    setState(() {
      selectedSpot = spot;
      isDealing = true;
      winningSpot = null;
      andarCards.clear();
      baharCards.clear();
      jokerCardText = "4 ♣";
    });

    // Simulate round execution
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        andarCards = ["10 ♠", "Q ♦", "Q ♠"];
        baharCards = ["5 ♥", "K ♦", "4 ♠"]; // 4 Matches Joker!
        winningSpot = "BAHAR";
        isDealing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWin = winningSpot != null && selectedSpot == winningSpot;
    final payout = isWin ? currentBet * 2 : 0;

    return Scaffold(
      backgroundColor: AppColors.tableFeltDark,
      appBar: AppBar(
        title: const Text('Andar Bahar 2X Table', style: TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: AppColors.goldPrimary),
      ),
      body: Column(
        children: [
          // CENTER JOKER CARD SLOT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              border: const Border(bottom: BorderSide(color: AppColors.goldPrimary, width: 2)),
            ),
            child: Column(
              children: [
                const Text('CENTER JOKER CARD', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.goldPrimary, width: 3),
                    boxShadow: const [BoxShadow(color: AppColors.goldGlow, blurRadius: 15)],
                  ),
                  child: Text(jokerCardText, style: const TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // ANDAR (RIGHT) vs BAHAR (LEFT) CARDS BOARD
          Expanded(
            child: Row(
              children: [
                // LEFT SIDE: BAHAR
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text('👈 LEFT: BAHAR', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                        const Divider(color: Colors.amber),
                        Wrap(
                          spacing: 6,
                          children: baharCards.map((c) => Chip(label: Text(c), backgroundColor: Colors.white)).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // RIGHT SIDE: ANDAR
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text('👉 RIGHT: ANDAR', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                        const Divider(color: Colors.blue),
                        Wrap(
                          spacing: 6,
                          children: andarCards.map((c) => Chip(label: Text(c), backgroundColor: Colors.white)).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // WINNER ANNOUNCEMENT & 2X PAYOUT BANNER
          if (winningSpot != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: isWin ? Colors.green.shade900 : Colors.red.shade900,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isWin ? '🎉 2X WINNER! YOU WON 🪙 $payout!' : '❌ LOST! WINNING SPOT WAS [$winningSpot]',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),

          // USER BETTING CONTROLS PANEL
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: Column(
              children: [
                // BET ADJUSTMENT BUTTONS (- / +)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(onPressed: () => adjustBet(-100), icon: const Icon(Icons.remove_circle, color: AppColors.goldPrimary, size: 32)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.goldPrimary)),
                      child: Text('🪙 $currentBet', style: const TextStyle(color: AppColors.goldPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(onPressed: () => adjustBet(100), icon: const Icon(Icons.add_circle, color: AppColors.goldPrimary, size: 32)),
                  ],
                ),
                const SizedBox(height: 12),

                // BET PLACEMENT BUTTONS (LEFT = BAHAR, RIGHT = ANDAR)
                Row(
                  children: [
                    // LEFT: BAHAR BUTTON
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => placeBetAndPlay('BAHAR'),
                        child: const Text('👈 BET BAHAR (2X)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // RIGHT: ANDAR BUTTON
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => placeBetAndPlay('ANDAR'),
                        child: const Text('👉 BET ANDAR (2X)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
