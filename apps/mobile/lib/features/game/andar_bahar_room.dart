import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/engine/game_engine.dart';
import '../../core/state/player_state.dart';
import '../../core/state/andar_bahar_state.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ANDAR BAHAR ROOM — fully wired to AndarBaharGameState (real engine)
// ═══════════════════════════════════════════════════════════════════════════
class AndarBaharRoom extends StatelessWidget {
  const AndarBaharRoom({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.read<PlayerState>();
    return ChangeNotifierProvider(
      create: (_) => AndarBaharGameState(playerState: player),
      child: const _AndarBaharRoomInner(),
    );
  }
}

class _AndarBaharRoomInner extends StatefulWidget {
  const _AndarBaharRoomInner();
  @override
  State<_AndarBaharRoomInner> createState() => _AndarBaharRoomInnerState();
}

class _AndarBaharRoomInnerState extends State<_AndarBaharRoomInner>
    with SingleTickerProviderStateMixin {
  final _chatCtrl = TextEditingController();
  final _chatScroll = ScrollController();
  late AnimationController _jokerPulse;
  int _selectedChip = 200;
  String? _errorMsg;

  final List<int> _chipValues = [200, 500, 1000, 2000, 5000];
  final List<Color> _chipColors = [
    AppColors.chip200, AppColors.chip500, AppColors.chip1K,
    AppColors.chip2K,  AppColors.chip5K,
  ];
  final List<String> _chipLabels = ['200', '500', '1K', '2K', '5K'];

  @override
  void initState() {
    super.initState();
    _jokerPulse = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _jokerPulse.dispose();
    _chatCtrl.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  void _scrollChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(_chatScroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  // ── Place bet ─────────────────────────────────────────────────────────────
  void _placeBet(BuildContext ctx, SpotType side) {
    final gs = ctx.read<AndarBaharGameState>();
    final err = gs.placeBet(side, _selectedChip);
    setState(() => _errorMsg = err);
    if (err != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.rubyRed,
            duration: const Duration(seconds: 2)));
    }
  }

  void _deal(BuildContext ctx) {
    final gs = ctx.read<AndarBaharGameState>();
    if (gs.yourSide == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        content: Text('Please choose Andar or Bahar first!'),
        backgroundColor: AppColors.rubyRed));
      return;
    }
    gs.deal();
  }

  void _sendChat(BuildContext ctx) {
    final gs = ctx.read<AndarBaharGameState>();
    gs.sendChat(_chatCtrl.text);
    _chatCtrl.clear();
    _scrollChat();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AndarBaharGameState>(
      builder: (ctx, gs, _) {
        _scrollChat();
        final size = MediaQuery.of(ctx).size;
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(ctx, gs),
                  Expanded(
                    child: Row(
                      children: [
                        _buildLeftSidebar(ctx, gs),
                        Expanded(
                          child: Column(
                            children: [
                              _buildDealerStrip(gs),
                              Expanded(child: _buildTableArea(ctx, gs, size)),
                              _buildChatPanel(ctx, gs),
                            ],
                          ),
                        ),
                        _buildRightSidebar(ctx, gs),
                      ],
                    ),
                  ),
                  _buildBottomControls(ctx, gs),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── TOP BAR ────────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext ctx, AndarBaharGameState gs) {
    final player = ctx.watch<PlayerState>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: AppColors.backgroundDark2.withOpacity(0.95),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Container(width: 34, height: 34,
            decoration: BoxDecoration(color: AppColors.cardSurfaceDark, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white12)),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary, size: 14)),
        ),
        const SizedBox(width: 8),
        // Real player avatar
        _miniAvatar(player),
        const SizedBox(width: 8),
        // Real chips from wallet
        _realChipsWidget(player),
        const Spacer(),
        // Real balance
        _realBalance(player),
        const Spacer(),
        _topMaharaja(),
        const SizedBox(width: 6),
        _iconBtn(Icons.chat_bubble_outlined, onTap: () {}),
        const SizedBox(width: 4),
        _iconBtn(Icons.settings_outlined, onTap: () {}),
        const SizedBox(width: 6),
        _onlineWidget(),
        const SizedBox(width: 4),
        _buyBtn(),
      ]),
    );
  }

  Widget _miniAvatar(PlayerState p) {
    return Stack(clipBehavior: Clip.none, children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle,
          border: Border.all(color: AppColors.goldPrimary, width: 2), color: AppColors.cardSurfaceDark),
        child: Center(child: Text('👑', style: const TextStyle(fontSize: 20)))),
      Positioned(bottom: -6, left: 0, right: 0,
        child: Center(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(color: AppColors.vip3, borderRadius: BorderRadius.circular(4)),
          child: Text('VIP ${p.vipLevel}', style: GoogleFonts.poppins(color: Colors.black, fontSize: 7, fontWeight: FontWeight.bold))))),
    ]);
  }

  Widget _realChipsWidget(PlayerState p) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Container(width: 18, height: 18, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.amber),
          child: const Center(child: Text('₹', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 3),
        // ← REAL chips from PlayerState
        Text(p.formattedChips, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
      ]),
      Row(children: [
        const Icon(Icons.diamond, color: Colors.purpleAccent, size: 10),
        const SizedBox(width: 2),
        Text('${p.gems}', style: GoogleFonts.poppins(color: Colors.purpleAccent, fontSize: 9)),
      ]),
    ]);
  }

  Widget _realBalance(PlayerState p) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.sports_kabaddi, color: AppColors.goldPrimary, size: 18),
      // ← REAL balance from PlayerState
      Text(p.formattedChips, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 10)),
      Text('Total Balance', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 7)),
    ]);
  }

  Widget _topMaharaja() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(color: AppColors.rubyRed.withOpacity(0.85), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.goldBorder)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('75+Cr', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 8, fontWeight: FontWeight.bold)),
      Text('20 Cr', style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 7)),
      Text('1 3 9', style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 8, letterSpacing: 2)),
    ]),
  );

  Widget _iconBtn(IconData icon, {required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(width: 30, height: 30,
      decoration: BoxDecoration(color: AppColors.cardSurfaceDark, borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.white12)),
      child: Icon(icon, color: AppColors.textPrimary, size: 15)));

  Widget _onlineWidget() => Row(children: [
    Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.onlineGreen, shape: BoxShape.circle)),
    const SizedBox(width: 2),
    Text('128', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 9)),
  ]);

  Widget _buyBtn() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: AppColors.rubyRed, borderRadius: BorderRadius.circular(6)),
    child: Text('Buy', style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)));

  // ── LEFT SIDEBAR ───────────────────────────────────────────────────────────
  Widget _buildLeftSidebar(BuildContext ctx, AndarBaharGameState gs) {
    return Container(
      width: 54,
      color: AppColors.backgroundDark2.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(children: [
        _sideItem('💎', 'Rank ${context.watch<PlayerState>().level}'),
        const SizedBox(height: 10),
        _sideItem('🏆', 'Leaders'),
        const SizedBox(height: 10),
        _sideItem('🎯', 'Daily'),
        const SizedBox(height: 10),
        _sideItem('📦', 'Chest\n30L'),
      ]),
    );
  }

  Widget _sideItem(String emoji, String label) => Column(children: [
    Text(emoji, style: const TextStyle(fontSize: 22)),
    const SizedBox(height: 2),
    Text(label, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 7)),
  ]);

  // ── RIGHT SIDEBAR ──────────────────────────────────────────────────────────
  Widget _buildRightSidebar(BuildContext ctx, AndarBaharGameState gs) {
    return Container(
      width: 54,
      color: AppColors.backgroundDark2.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(children: [
        _sideItem('🃏', 'Lucky\nCards 6'),
        const SizedBox(height: 10),
        _sideItem('😊', 'Bazaar'),
        const SizedBox(height: 10),
        _sideItem('🎁', 'Gift'),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _showInviteDialog(ctx, gs),
          child: _sideItem('➕', 'Invite'),
        ),
      ]),
    );
  }

  // ── DEALER STRIP ───────────────────────────────────────────────────────────
  Widget _buildDealerStrip(AndarBaharGameState gs) {
    return Container(
      height: 56,
      color: Colors.transparent,
      child: Stack(alignment: Alignment.center, children: [
        // Dealer
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(colors: [Color(0xFFE91E63), Color(0xFF880E4F)]),
            border: Border.all(color: AppColors.goldBorder, width: 2),
            boxShadow: AppColors.goldGlowShadow,
          ),
          child: const Center(child: Text('💃', style: TextStyle(fontSize: 26))),
        ),
        // Table info
        Positioned(right: 10, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Table #${100 + gs.roundNumber}', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 9)),
          Row(children: [
            Text('Round ${gs.roundNumber}', style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 9)),
            const SizedBox(width: 4),
            Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.onlineGreen, shape: BoxShape.circle)),
          ]),
        ])),
        // Betting timer
        if (gs.phase == ABGamePhase.betting)
          Positioned(left: 10, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.goldBorder)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.timer, color: AppColors.goldPrimary, size: 12),
              const SizedBox(width: 3),
              Text('${gs.bettingSecondsLeft}s', style: GoogleFonts.poppins(
                color: gs.bettingSecondsLeft < 5 ? Colors.red : AppColors.goldPrimary,
                fontWeight: FontWeight.bold, fontSize: 12)),
            ]),
          )),
      ]),
    );
  }

  // ── TABLE AREA ─────────────────────────────────────────────────────────────
  Widget _buildTableArea(BuildContext ctx, AndarBaharGameState gs, Size size) {
    final tableW = size.width - 108.0;
    final tableH = size.height * 0.33;

    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Oval Blue Felt Table ───────────────────────────────────────
        Container(
          width: tableW * 0.92,
          height: tableH,
          decoration: BoxDecoration(
            gradient: AppColors.tableRadialGlow,
            borderRadius: BorderRadius.all(Radius.elliptical(tableW * 0.46, tableH / 2)),
            border: Border.all(color: AppColors.goldBorder, width: 4),
            boxShadow: [
              BoxShadow(color: AppColors.goldGlow.withOpacity(0.25), blurRadius: 22, spreadRadius: 3),
              BoxShadow(color: Colors.black.withOpacity(0.7), blurRadius: 30),
            ],
          ),
          child: _buildTableInner(ctx, gs, tableW, tableH),
        ),

        // ── Player Seats ────────────────────────────────────────────────
        for (int i = 0; i < gs.seats.length; i++)
          _positionedSeat(ctx, gs, gs.seats[i], i, tableW, tableH),
      ],
    );
  }

  Widget _positionedSeat(BuildContext ctx, AndarBaharGameState gs, TableSeat seat, int i, double tw, double th) {
    double left = 0, right = 0, top = 0, bottom = 0;
    bool useLeft = true, useTop = false;
    switch (i) {
      case 0: left = 2; top = th * 0.15; useLeft = true; useTop = true; break;
      case 1: left = tw * 0.1; bottom = 0; useLeft = true; useTop = false; break;
      case 2: break; // self — centered bottom
      case 3: right = tw * 0.05; bottom = 0; useLeft = false; useTop = false; break;
      case 4: right = 2; top = th * 0.15; useLeft = false; useTop = true; break;
    }

    Widget child = i == 2
        ? _buildSelfSeat(ctx, gs)
        : seat.isEmpty
            ? _buildEmptySeat(ctx, gs, seat)
            : _buildBotSeat(seat);

    if (i == 2) return Positioned(bottom: 0, child: child);
    if (useLeft && useTop)  return Positioned(left: left, top: top, child: child);
    if (useLeft && !useTop) return Positioned(left: left, bottom: bottom, child: child);
    if (!useLeft && useTop) return Positioned(right: right, top: top, child: child);
    return Positioned(right: right, bottom: bottom, child: child);
  }

  // ── Bot seat ──────────────────────────────────────────────────────────────
  Widget _buildBotSeat(TableSeat seat) {
    final hasBet = seat.placedSide != null;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardSurfaceDark,
            border: Border.all(
              color: seat.placedSide == SpotType.andar ? Colors.green : seat.placedSide == SpotType.bahar ? Colors.red : AppColors.goldBorder,
              width: 2,
            ),
          ),
          child: Center(child: Text(seat.avatarEmoji, style: const TextStyle(fontSize: 22))),
        ),
        // Bet indicator
        if (hasBet) Positioned(bottom: -4, right: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: seat.placedSide == SpotType.andar ? Colors.green.shade800 : Colors.red.shade800,
              borderRadius: BorderRadius.circular(6)),
            child: Text(seat.placedSide == SpotType.andar ? 'A' : 'B',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)))),
        Positioned(right: -5, top: -3,
          child: Container(width: 16, height: 16,
            decoration: const BoxDecoration(color: AppColors.goldPrimary, shape: BoxShape.circle),
            child: const Icon(Icons.card_giftcard, size: 8, color: Colors.black))),
      ]),
      const SizedBox(height: 2),
      Text(seat.name, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 9, fontWeight: FontWeight.bold)),
      // Real chip value from seat
      Text(seat.formattedChips, style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 9)),
      if (hasBet)
        Text('Bet: ${_fmt(seat.currentBet)}', style: GoogleFonts.poppins(color: AppColors.amberWarm, fontSize: 8)),
    ]);
  }

  // ── Self seat ─────────────────────────────────────────────────────────────
  Widget _buildSelfSeat(BuildContext ctx, AndarBaharGameState gs) {
    final player = ctx.watch<PlayerState>();
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.goldPrimary, width: 2.5),
            gradient: const RadialGradient(colors: [Color(0xFF555555), Color(0xFF222222)]),
            boxShadow: AppColors.goldGlowShadow,
          ),
          child: Center(child: Text(
            gs.yourSide == SpotType.andar ? '🟢' : gs.yourSide == SpotType.bahar ? '🔴' : '👑',
            style: const TextStyle(fontSize: 24))),
        ),
        Positioned(right: -5, top: -3,
          child: GestureDetector(
            onTap: () => _showGiftSheet(ctx, gs),
            child: Container(width: 16, height: 16,
              decoration: const BoxDecoration(color: AppColors.goldPrimary, shape: BoxShape.circle),
              child: const Icon(Icons.card_giftcard, size: 8, color: Colors.black)))),
      ]),
      const SizedBox(height: 2),
      Text('You', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 9, fontWeight: FontWeight.bold)),
      // ← REAL chips from PlayerState
      Text(player.formattedChips, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 9)),
      if (gs.yourBet > 0)
        Text('Bet: ${_fmt(gs.yourBet)} on ${gs.yourSide == SpotType.andar ? "A" : "B"}',
          style: GoogleFonts.poppins(color: AppColors.amberWarm, fontSize: 8)),
    ]);
  }

  // ── Empty seat invite ─────────────────────────────────────────────────────
  Widget _buildEmptySeat(BuildContext ctx, AndarBaharGameState gs, TableSeat seat) {
    return GestureDetector(
      onTap: () => _showInviteDialog(ctx, gs, targetSeatId: seat.seatId),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.cardSurfaceDark,
            border: Border.all(color: Colors.white24, width: 1.5)),
          child: const Icon(Icons.add, color: Colors.white38, size: 24)),
        const SizedBox(height: 2),
        Text('Invite', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 9)),
      ]),
    );
  }

  // ── TABLE INNER CONTENT ────────────────────────────────────────────────────
  Widget _buildTableInner(BuildContext ctx, AndarBaharGameState gs, double tableW, double tableH) {
    return Stack(alignment: Alignment.center, children: [
      // ANDAR zone (left)
      Positioned(left: tableW * 0.02, child: _buildZone(ctx, gs, SpotType.andar, tableH)),
      // Center joker + bets
      Column(mainAxisSize: MainAxisSize.min, children: [
        _buildJokerCard(gs),
        const SizedBox(height: 4),
        _buildCenterPools(gs),
      ]),
      // BAHAR zone (right)
      Positioned(right: tableW * 0.02, child: _buildZone(ctx, gs, SpotType.bahar, tableH)),
    ]);
  }

  Widget _buildZone(BuildContext ctx, AndarBaharGameState gs, SpotType side, double tableH) {
    final isAndar = side == SpotType.andar;
    final label   = isAndar ? 'ANDAR' : 'BAHAR';
    final color   = isAndar ? Colors.lightBlueAccent : Colors.amberAccent;
    final letter  = isAndar ? 'A' : 'B';
    final chips   = isAndar ? gs.andarPool : gs.baharPool;
    final odds    = isAndar ? gs.andarOdds : gs.baharOdds;
    final cards   = isAndar ? gs.andarCards : gs.baharCards;

    return Column(mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isAndar ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: isAndar
            ? [_letterBadge(letter, AppColors.andarGreen), const SizedBox(width: 4),
               Text(label, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 11))]
            : [Text(label, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
               const SizedBox(width: 4), _letterBadge(letter, AppColors.baharRed)],
        ),
        const SizedBox(height: 4),
        // Pool amount — real from state
        Row(mainAxisSize: MainAxisSize.min, children: [
          _letterBadge(letter, isAndar ? AppColors.andarGreen : AppColors.baharRed),
          const SizedBox(width: 4),
          Text(_fmt(chips), style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 2),
        Text('${label.toUpperCase()} WINS\n${odds.toStringAsFixed(1)}x',
          textAlign: isAndar ? TextAlign.left : TextAlign.right,
          style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 7)),
        const SizedBox(height: 4),
        // Cards from real engine
        _buildCardSlots(cards, isAndar: isAndar, gs: gs),
      ],
    );
  }

  Widget _letterBadge(String letter, Color color) => Container(
    width: 18, height: 18,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: Center(child: Text(letter, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))));

  Widget _buildCardSlots(List<Card> cards, {required bool isAndar, required AndarBaharGameState gs}) {
    final winning = gs.winningSpot;
    final isWinSide = winning != null && (isAndar ? winning == SpotType.andar : winning == SpotType.bahar);

    return Wrap(
      spacing: 3, runSpacing: 3,
      children: [
        // Show dealt cards (from real engine)
        for (final card in cards)
          _realCardWidget(card, highlight: isWinSide && card.rank == gs.jokerCard?.rank),
        // Empty placeholder slot if no cards yet
        if (cards.isEmpty)
          Container(width: 26, height: 36,
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white24))),
      ],
    );
  }

  Widget _realCardWidget(Card card, {bool highlight = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 26, height: 36,
      decoration: BoxDecoration(
        color: highlight ? AppColors.goldPrimary.withOpacity(0.9) : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: highlight ? AppColors.goldPrimary : AppColors.goldBorder.withOpacity(0.5), width: highlight ? 2 : 1),
        boxShadow: highlight ? AppColors.goldGlowShadow : AppColors.cardGlowShadow,
      ),
      child: Center(child: Text(
        card.display,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: highlight ? Colors.black87 : (card.isRed ? Colors.red : Colors.black87),
          fontSize: 7, fontWeight: FontWeight.bold,
        ),
      )),
    );
  }

  // ── JOKER CARD (real from engine) ─────────────────────────────────────────
  Widget _buildJokerCard(AndarBaharGameState gs) {
    final joker = gs.jokerCard;
    return AnimatedBuilder(
      animation: _jokerPulse,
      builder: (_, __) {
        final scale = gs.phase == ABGamePhase.dealing
            ? 0.95 + _jokerPulse.value * 0.1
            : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 52, height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.goldPrimary, width: 2.5),
              boxShadow: AppColors.goldGlowShadow,
            ),
            child: joker == null
                ? const Center(child: Icon(Icons.style, color: AppColors.goldPrimary, size: 28))
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(joker.rank,
                      style: TextStyle(
                        color: joker.isRed ? Colors.red : Colors.black87,
                        fontWeight: FontWeight.bold, fontSize: 20)),
                    Text(Card.suitSymbol(joker.suit),
                      style: TextStyle(
                        color: joker.isRed ? Colors.red : Colors.black87,
                        fontSize: 18)),
                  ]),
          ),
        );
      },
    );
  }

  Widget _buildCenterPools(AndarBaharGameState gs) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _poolRow('A', gs.andarPool, AppColors.andarGreen),
      _poolRow('B', gs.baharPool, AppColors.baharRed),
      Text('Pool: ${_fmt(gs.andarPool + gs.baharPool)}',
        style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 8, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _poolRow(String label, int amount, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      _letterBadge(label, color),
      const SizedBox(width: 4),
      Text(_fmt(amount), style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 9)),
    ]));

  // ── CHAT ──────────────────────────────────────────────────────────────────
  Widget _buildChatPanel(BuildContext ctx, AndarBaharGameState gs) {
    return Container(
      height: 66,
      color: Colors.black54,
      child: Row(children: [
        Expanded(
          child: ListView.builder(
            controller: _chatScroll,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: gs.chatMessages.length,
            itemBuilder: (_, i) {
              final m = gs.chatMessages[i];
              final color = m.isSystem ? AppColors.goldPrimary
                : m.sender == 'You' ? Colors.greenAccent
                : m.sender == 'Fahad' ? const Color(0xFF00E676)
                : m.sender == 'HODAYATSOP' ? AppColors.goldPrimary
                : Colors.lightBlueAccent;
              return RichText(text: TextSpan(children: [
                TextSpan(text: '${m.sender}: ', style: GoogleFonts.poppins(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
                TextSpan(text: m.text, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 9)),
              ]));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(children: [
            SizedBox(width: 100,
              child: TextField(
                controller: _chatCtrl,
                style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 10),
                onSubmitted: (_) => _sendChat(ctx),
                decoration: InputDecoration(
                  hintText: 'Type here...',
                  hintStyle: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 9),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  filled: true, fillColor: AppColors.cardSurfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              )),
            const SizedBox(width: 4),
            GestureDetector(onTap: () => _showEmojiSheet(ctx, gs),
              child: const Text('😊', style: TextStyle(fontSize: 18))),
            const SizedBox(width: 4),
            GestureDetector(onTap: () => _sendChat(ctx),
              child: Container(width: 26, height: 26,
                decoration: BoxDecoration(color: AppColors.goldPrimary, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.send, color: Colors.black, size: 13))),
          ]),
        ),
      ]),
    );
  }

  // ── BOTTOM CONTROLS ────────────────────────────────────────────────────────
  Widget _buildBottomControls(BuildContext ctx, AndarBaharGameState gs) {
    final player = ctx.watch<PlayerState>();
    final isResult = gs.phase == ABGamePhase.roundResult;
    final isDealing = gs.phase == ABGamePhase.dealing;

    return Container(
      color: AppColors.backgroundDark2,
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        // ── Winner/Loser banner ───────────────────────────────────────
        if (isResult) _buildResultBanner(gs),

        // ── Chip selector label ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
          child: Row(children: [
            Text('— CHOOSE BET AMOUNT —', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 9)),
            const Spacer(),
            Text('Balance: ${player.formattedChips}',
              style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 9, fontWeight: FontWeight.bold)),
          ]),
        ),

        // ── Chip circles (real values) ────────────────────────────────
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: _chipValues.length,
            itemBuilder: (_, i) {
              final v = _chipValues[i];
              final sel = _selectedChip == v;
              final canAfford = v <= player.chips;
              return GestureDetector(
                onTap: canAfford ? () => setState(() => _selectedChip = v) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 46, height: 46,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: canAfford ? _chipColors[i] : _chipColors[i].withOpacity(0.3),
                    border: Border.all(color: sel ? Colors.white : Colors.transparent, width: 2.5),
                    boxShadow: sel ? [BoxShadow(color: _chipColors[i].withOpacity(0.7), blurRadius: 10)] : [],
                  ),
                  child: Center(child: Text(_chipLabels[i],
                    style: GoogleFonts.poppins(color: canAfford ? Colors.white : Colors.white38,
                      fontWeight: FontWeight.bold, fontSize: 11))),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),

        // ── ANDAR / BAHAR / DEAL buttons ─────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Row(children: [
            // ANDAR
            Expanded(flex: 2, child: _betButton(
              ctx: ctx, gs: gs, side: SpotType.andar,
              label: 'A', sublabel: 'ANDAR',
              activeColor: const Color(0xFF2E7D32), inactiveColor: const Color(0xFF1B5E20),
              isDealing: isDealing || isResult,
            )),
            const SizedBox(width: 6),
            // BAHAR
            Expanded(flex: 2, child: _betButton(
              ctx: ctx, gs: gs, side: SpotType.bahar,
              label: 'B', sublabel: 'BAHAR',
              activeColor: const Color(0xFFB71C1C), inactiveColor: const Color(0xFF7F0000),
              isDealing: isDealing || isResult,
            )),
            const SizedBox(width: 6),
            // DEAL / PLAY AGAIN
            Expanded(flex: 3, child: GestureDetector(
              onTap: isResult ? gs.playAgain : () => _deal(ctx),
              onLongPress: () { gs.toggleAutoRebet(); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.goldDark]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: AppColors.goldGlowShadow,
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(isResult ? 'PLAY AGAIN' : isDealing ? 'DEALING...' : 'DEAL',
                    style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 14)),
                  Text(isDealing ? '${gs.andarCards.length + gs.baharCards.length} cards dealt' : 'HOLD FOR AUTO',
                    style: GoogleFonts.poppins(color: Colors.black54, fontSize: 7)),
                ]),
              ),
            )),
          ]),
        ),

        // ── Auto rebet + total won ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(right: 10, bottom: 6),
          child: Row(children: [
            const SizedBox(width: 10),
            Text('Won today: ${_fmt(gs.yourTotalWon)}',
              style: GoogleFonts.poppins(color: AppColors.emeraldGreen, fontSize: 9)),
            const Spacer(),
            Transform.scale(scale: 0.75,
              child: Switch(value: gs.autoRebet, onChanged: (_) => gs.toggleAutoRebet(),
                activeColor: AppColors.goldPrimary)),
            Text('Auto Rebet', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 9)),
          ]),
        ),
      ]),
    );
  }

  Widget _betButton({
    required BuildContext ctx, required AndarBaharGameState gs,
    required SpotType side, required String label, required String sublabel,
    required Color activeColor, required Color inactiveColor,
    required bool isDealing,
  }) {
    final isSelected = gs.yourSide == side;
    return GestureDetector(
      onTap: isDealing ? null : () => _placeBet(ctx, side),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: activeColor.withOpacity(0.5), blurRadius: 12)] : [],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          Text(sublabel, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 9)),
          if (isSelected && gs.yourBet > 0)
            Text('₹${_fmt(gs.yourBet)}', style: GoogleFonts.poppins(color: AppColors.amberWarm, fontSize: 8, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildResultBanner(AndarBaharGameState gs) {
    final player = context.read<PlayerState>();
    final won    = gs.yourSide == gs.winningSpot;
    final payout = won ? AndarBaharEngine.calculate2xPayout(gs.yourBet, gs.yourSide!, gs.winningSpot!) : 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: won ? const Color(0xFF1B5E20) : const Color(0xFF7F0000),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          won
            ? '🎉 ${gs.winningSpot == SpotType.andar ? "ANDAR" : "BAHAR"} WINS! +${_fmt(payout)} → Balance: ${player.formattedChips}'
            : '❌ ${gs.winningSpot == SpotType.andar ? "ANDAR" : "BAHAR"} WINS. Balance: ${player.formattedChips}',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      ]),
    );
  }

  // ── Invite Dialog ────────────────────────────────────────────────────────
  void _showInviteDialog(BuildContext ctx, AndarBaharGameState gs, {String? targetSeatId}) {
    final emptySeat = targetSeatId ?? gs.seats.firstWhere((s) => s.isEmpty, orElse: () => TableSeat.empty('none')).seatId;
    if (emptySeat == 'none') {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Table is full!'), backgroundColor: AppColors.rubyRed));
      return;
    }
    final controller = TextEditingController();
    showDialog(context: ctx, builder: (_) => Dialog(
      backgroundColor: AppColors.cardSurfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.goldBorder)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Invite to Table', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Friend name (optional)',
              hintStyle: GoogleFonts.poppins(color: AppColors.textMuted),
              filled: true, fillColor: AppColors.backgroundDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white24)),
                child: Center(child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textMuted)))),
            )),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                gs.inviteToSeat(emptySeat, friendName: controller.text.trim().isEmpty ? null : controller.text.trim());
              },
              child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.goldDark]), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text('Invite', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)))),
            )),
          ]),
        ]),
      ),
    ));
  }

  // ── Emoji sheet ───────────────────────────────────────────────────────────
  void _showEmojiSheet(BuildContext ctx, AndarBaharGameState gs) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.cardSurfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12, runSpacing: 12,
          children: ['😂','🔥','👑','💰','🎉','👏','😎','🤣','😱','🙏','❤️','💯'].map((e) =>
            GestureDetector(
              onTap: () { Navigator.pop(ctx); gs.sendEmoji(e); _scrollChat(); },
              child: Text(e, style: const TextStyle(fontSize: 32)))).toList(),
        ),
      ),
    );
  }

  // ── Gift sheet ────────────────────────────────────────────────────────────
  void _showGiftSheet(BuildContext ctx, AndarBaharGameState gs) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.cardSurfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Send Gift', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12,
            children: [
              ('🌹','Rose','10💎'), ('🏎','Car','500💎'), ('🚀','Rocket','200💎'),
              ('💍','Ring','1000💎'), ('💣','Bomb','50💎'), ('🏆','Trophy','300💎'),
            ].map(((String, String, String) g) => GestureDetector(
              onTap: () { Navigator.pop(ctx); gs.sendChat('Sent ${g.$1} ${g.$2}!'); },
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(g.$1, style: const TextStyle(fontSize: 36)),
                Text(g.$2, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 10)),
                Text(g.$3, style: GoogleFonts.poppins(color: Colors.purpleAccent, fontSize: 9)),
              ]),
            )).toList()),
        ]),
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '${(v / 100000).toStringAsFixed(2)}L';
    if (v >= 1000)     return '${(v / 1000).toStringAsFixed(0)}K';
    return '$v';
  }
}
