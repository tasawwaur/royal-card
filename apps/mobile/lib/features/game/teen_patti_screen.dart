import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/engine/game_engine.dart';
import '../../core/state/player_state.dart';
import '../../core/state/teen_patti_state.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TEEN PATTI SCREEN — fully wired to TeenPattiGameState (real engine)
// ═══════════════════════════════════════════════════════════════════════════
class TeenPattiScreen extends StatelessWidget {
  const TeenPattiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.read<PlayerState>();
    return ChangeNotifierProvider(
      create: (_) => TeenPattiGameState(playerState: player, variation: GameVariation.classic, bootAmount: 100),
      child: const _TeenPattiInner(),
    );
  }
}

class _TeenPattiInner extends StatefulWidget {
  const _TeenPattiInner();
  @override
  State<_TeenPattiInner> createState() => _TeenPattiInnerState();
}

class _TeenPattiInnerState extends State<_TeenPattiInner> with TickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;
  late AnimationController _pulseCtrl;
  final _chatCtrl = TextEditingController();
  GameVariation _selectedVariation = GameVariation.classic;
  int _selectedBet = 100;
  String? _errorSnack;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(_glowCtrl);
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _pulseCtrl.dispose();
    _chatCtrl.dispose();
    super.dispose();
  }

  void _showError(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: AppColors.rubyRed,
      duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeenPattiGameState>(
      builder: (ctx, gs, _) {
        final size = MediaQuery.of(ctx).size;
        return Scaffold(
          backgroundColor: AppColors.tableGreenDark,
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [AppColors.tableGreenLight.withOpacity(0.8), AppColors.tableGreenDark],
                radius: 1.2,
              ),
            ),
            child: SafeArea(
              child: Column(children: [
                _buildTopBar(ctx, gs),
                _buildVariationRow(ctx, gs),
                _buildPotRow(ctx, gs),
                Expanded(child: _buildTableStack(ctx, gs, size)),
                _buildActionPanel(ctx, gs),
              ]),
            ),
          ),
        );
      },
    );
  }

  // ── TOP BAR ──────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext ctx, TeenPattiGameState gs) {
    final player = ctx.watch<PlayerState>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      color: Colors.black54,
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Container(width: 32, height: 32,
            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary, size: 13)),
        ),
        const SizedBox(width: 8),
        Text('Teen Patti Gold', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 6),
        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: AppColors.rubyRed.withOpacity(0.8), borderRadius: BorderRadius.circular(6)),
          child: Text(_variationName(_selectedVariation),
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
        const Spacer(),
        // Real chips from wallet
        Row(children: [
          Container(width: 16, height: 16, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.amber),
            child: const Center(child: Text('₹', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 3),
          Text(player.formattedChips, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 11)),
        ]),
        const SizedBox(width: 8),
        _topIconBtn(Icons.chat_bubble_outlined),
        const SizedBox(width: 4),
        _topIconBtn(Icons.settings_outlined),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => _showInviteDialog(ctx, gs),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.goldDark]), borderRadius: BorderRadius.circular(6)),
            child: Row(children: [
              const Icon(Icons.person_add, color: Colors.black, size: 11),
              const SizedBox(width: 2),
              Text('Invite', style: GoogleFonts.poppins(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
            ])),
        ),
      ]),
    );
  }

  Widget _topIconBtn(IconData icon) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.white12)),
    child: Icon(icon, color: AppColors.textPrimary, size: 14));

  // ── VARIATION TABS ────────────────────────────────────────────────────────
  Widget _buildVariationRow(BuildContext ctx, TeenPattiGameState gs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.center,
        children: GameVariation.values.map((v) => GestureDetector(
          onTap: () { setState(() => _selectedVariation = v); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _selectedVariation == v ? AppColors.goldPrimary : Colors.black38,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _selectedVariation == v ? AppColors.goldPrimary : Colors.white24)),
            child: Text(_variationName(v), style: GoogleFonts.poppins(
              color: _selectedVariation == v ? Colors.black : Colors.white70,
              fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        )).toList()),
    );
  }

  String _variationName(GameVariation v) {
    switch (v) {
      case GameVariation.classic:  return 'Classic';
      case GameVariation.joker:    return 'Joker';
      case GameVariation.muflis:   return 'Muflis';
      case GameVariation.ak47:     return 'AK47';
    }
  }

  // ── POT + BOOT ───────────────────────────────────────────────────────────
  Widget _buildPotRow(BuildContext ctx, TeenPattiGameState gs) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.goldPrimary, width: 1.5),
            boxShadow: [BoxShadow(color: AppColors.goldGlow.withOpacity(_glowAnim.value * 0.6), blurRadius: 12, spreadRadius: 2)],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.sports_kabaddi, color: AppColors.goldPrimary, size: 16),
            const SizedBox(width: 8),
            Text('POT: 🪙 ${_fmt(gs.pot)}', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(width: 10),
            Text('Boot: ${_fmt(gs.bootAmount)}', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 9)),
            const SizedBox(width: 8),
            Text('Round ${gs.roundNumber}', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 9)),
          ]),
        ),
      ]),
    );
  }

  // ── TABLE STACK ───────────────────────────────────────────────────────────
  Widget _buildTableStack(BuildContext ctx, TeenPattiGameState gs, Size size) {
    final tableW = size.width * 0.86;
    final tableH = size.height * 0.36;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
        // ── Green Oval Felt Table ─────────────────────────────────────
        Container(
          width: tableW, height: tableH,
          decoration: BoxDecoration(
            gradient: const RadialGradient(colors: [AppColors.tableGreenLight, AppColors.tableGreenDark], radius: 0.9),
            borderRadius: BorderRadius.all(Radius.elliptical(tableW / 2, tableH / 2)),
            border: Border.all(color: AppColors.goldBorder, width: 4),
            boxShadow: [
              BoxShadow(color: AppColors.goldGlow.withOpacity(0.2), blurRadius: 20, spreadRadius: 4),
              BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 30),
            ],
          ),
          child: Center(child: Text('TEEN PATTI GOLD',
            style: GoogleFonts.poppins(color: Colors.white10, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 3))),
        ),

        // ── Winner announcement (overlay) ─────────────────────────────
        if (gs.phase == TPPhase.roundResult && gs.winnerName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.goldPrimary, width: 2),
              boxShadow: AppColors.goldGlowShadow,
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('🏆 ${gs.winnerName} WINS!', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              if (gs.winnerEval != null)
                Text(gs.winnerEval!.label, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13)),
              Text('Pot: ${_fmt(gs.winnerPot ?? 0)}', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 11)),
            ]),
          ),

        // ── Turn timer ring ─────────────────────────────────────────────
        if (gs.phase == TPPhase.playing)
          AnimatedBuilder(animation: _pulseCtrl, builder: (_, __) {
            final secs = gs.turnSecondsLeft;
            final scale = gs.isYourTurn ? (0.95 + _pulseCtrl.value * 0.08) : 1.0;
            return Transform.scale(scale: scale, child: SizedBox(
              width: 54, height: 54,
              child: CircularProgressIndicator(
                value: secs / 30.0,
                strokeWidth: 4,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  secs < 10 ? Colors.red : AppColors.goldPrimary),
              ),
            ));
          }),

        // ── Seats ──────────────────────────────────────────────────────
        // Top-left
        Positioned(top: 4, left: size.width * 0.04 - 54,
          child: _buildSeat(ctx, gs, gs.seats[0])),
        // Top-center
        Positioned(top: -22,
          child: _buildSeat(ctx, gs, gs.seats[1])),
        // Bottom-left
        Positioned(bottom: 0, left: size.width * 0.04 - 54,
          child: _buildSeat(ctx, gs, gs.seats[4])),
        // Bottom-center (self)
        Positioned(bottom: -22,
          child: _buildSelfSeat(ctx, gs)),
        // Bottom-right
        Positioned(bottom: 0, right: size.width * 0.04 - 54,
          child: _buildSeat(ctx, gs, gs.seats[3])),
      ]),
    );
  }

  // ── Seat widget (bot/opponent) ────────────────────────────────────────────
  Widget _buildSeat(BuildContext ctx, TeenPattiGameState gs, TPSeat seat) {
    if (seat.isEmpty) return _buildEmptySeat(ctx, gs, seat);

    Color ringColor;
    switch (seat.tpStatus) {
      case TPStatus.blind:   ringColor = Colors.blueAccent; break;
      case TPStatus.seen:    ringColor = AppColors.emeraldGreen; break;
      case TPStatus.packed:  ringColor = Colors.grey; break;
      case TPStatus.winner:  ringColor = AppColors.goldPrimary; break;
      default:               ringColor = AppColors.goldBorder;
    }

    final isPacked = seat.tpStatus == TPStatus.packed;
    final isTurn = seat.isCurrentTurn && gs.phase == TPPhase.playing;

    return Opacity(
      opacity: isPacked ? 0.4 : 1.0,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Stack(clipBehavior: Clip.none, children: [
          // 3 face-down cards above avatar
          Positioned(top: -18,
            child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => Container(
              width: 12, height: 17,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: isPacked ? Colors.grey.shade800 : const Color(0xFF8B0000),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: AppColors.goldBorder, width: 0.7)),
            )))),
          // Avatar ring with status color
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 46, height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(colors: [Color(0xFF555555), Color(0xFF111111)]),
              border: Border.all(color: isTurn ? Colors.white : ringColor, width: isTurn ? 3 : 2),
              boxShadow: isTurn ? [BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 12)] : [BoxShadow(color: ringColor.withOpacity(0.4), blurRadius: 6)],
            ),
            child: Center(child: Text(seat.avatarEmoji, style: const TextStyle(fontSize: 22))),
          ),
          // Gift
          Positioned(right: -5, top: -3,
            child: Container(width: 15, height: 15,
              decoration: const BoxDecoration(color: AppColors.goldPrimary, shape: BoxShape.circle),
              child: const Icon(Icons.card_giftcard, size: 7, color: Colors.black))),
          // Show eval if revealed
          if (seat.tpStatus == TPStatus.winner && seat.eval != null)
            Positioned(bottom: -22,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(color: AppColors.goldPrimary, borderRadius: BorderRadius.circular(5)),
                child: Text(seat.eval!.label.split(' ')[0], style: GoogleFonts.poppins(color: Colors.black, fontSize: 7, fontWeight: FontWeight.bold)))),
        ]),
        const SizedBox(height: 2),
        Text(seat.name, style: GoogleFonts.poppins(color: isPacked ? AppColors.textDisabled : AppColors.textPrimary, fontSize: 9, fontWeight: FontWeight.bold)),
        // Real chip value from seat
        Text(seat.formattedChips, style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 9)),
        // Status badge
        if (seat.tpStatus != TPStatus.waiting)
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: _statusColor(seat.tpStatus).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _statusColor(seat.tpStatus))),
            child: Text(_statusLabel(seat.tpStatus),
              style: GoogleFonts.poppins(color: _statusColor(seat.tpStatus), fontSize: 7, fontWeight: FontWeight.bold))),
      ]),
    );
  }

  // ── Self seat (real player) ───────────────────────────────────────────────
  Widget _buildSelfSeat(BuildContext ctx, TeenPattiGameState gs) {
    final player = ctx.watch<PlayerState>();
    final your = gs.yourSeat;
    final hasSeen = your?.tpStatus == TPStatus.seen;
    final isPacked = your?.tpStatus == TPStatus.packed;
    final isWinner = your?.tpStatus == TPStatus.winner;
    final isTurn = gs.isYourTurn && gs.phase == TPPhase.playing;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      // Real card hand
      Row(mainAxisSize: MainAxisSize.min,
        children: (your?.hand ?? []).asMap().entries.map((e) {
          final card = e.value;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: hasSeen
              ? _faceCard(card, key: ValueKey('face_${e.key}'))
              : _backCard(key: ValueKey('back_${e.key}')),
          );
        }).toList()),
      const SizedBox(height: 6),
      // Player badge
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          gradient: isWinner
            ? const LinearGradient(colors: [AppColors.goldLight, AppColors.goldPrimary])
            : isPacked
              ? const LinearGradient(colors: [Colors.grey, Colors.blueGrey])
              : const LinearGradient(colors: [AppColors.goldDark, AppColors.goldPrimary]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isTurn ? AppColors.goldGlowShadow : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('🌟', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Real player name & chips
            Text(player.name.isEmpty ? 'You' : player.name,
              style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 10)),
            Text('🪙 ${player.formattedChips}',
              style: GoogleFonts.poppins(color: Colors.black54, fontSize: 9)),
          ]),
        ]),
      ),
      // Turn timer
      if (isTurn) ...[
        const SizedBox(height: 3),
        AnimatedBuilder(animation: _pulseCtrl, builder: (_, __) {
          final secs = gs.turnSecondsLeft;
          return Text('$secs s', style: GoogleFonts.poppins(
            color: secs < 10 ? Colors.red : AppColors.goldPrimary,
            fontWeight: FontWeight.bold, fontSize: 11));
        }),
      ],
      // Win eval
      if (isWinner && your?.eval != null)
        Text(your!.eval!.label, style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 10)),
    ]);
  }

  Widget _buildEmptySeat(BuildContext ctx, TeenPattiGameState gs, TPSeat seat) {
    return GestureDetector(
      onTap: () => _showInviteDialog(ctx, gs, seatId: seat.seatId),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.cardSurfaceDark,
            border: Border.all(color: Colors.white24, width: 1.5)),
          child: const Icon(Icons.add, color: Colors.white38, size: 22)),
        const SizedBox(height: 2),
        Text('Invite', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 9)),
      ]),
    );
  }

  Widget _faceCard(Card card, {Key? key}) => Container(
    key: key,
    width: 44, height: 60,
    margin: const EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColors.goldPrimary, width: 1.5),
      boxShadow: AppColors.cardGlowShadow,
    ),
    child: Padding(padding: const EdgeInsets.all(3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(card.rank, style: TextStyle(color: card.isRed ? Colors.red : Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
        Text(Card.suitSymbol(card.suit), style: TextStyle(color: card.isRed ? Colors.red : Colors.black87, fontSize: 13)),
      ])),
  );

  Widget _backCard({Key? key}) => Container(
    key: key,
    width: 44, height: 60,
    margin: const EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF8B0000), Color(0xFF4A0000)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColors.goldPrimary, width: 1.5),
      boxShadow: AppColors.cardGlowShadow,
    ),
    child: Center(child: Transform.rotate(angle: 0.4,
      child: const Icon(Icons.style, color: AppColors.goldPrimary, size: 22))),
  );

  // ── ACTION PANEL ──────────────────────────────────────────────────────────
  Widget _buildActionPanel(BuildContext ctx, TeenPattiGameState gs) {
    final your = gs.yourSeat;
    final hasSeen = your?.tpStatus == TPStatus.seen;
    final isPacked = your?.tpStatus == TPStatus.packed;
    final isOver = gs.phase == TPPhase.roundResult;
    final player = ctx.watch<PlayerState>();

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.88),
        border: const Border(top: BorderSide(color: AppColors.goldBorder, width: 1))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        // ── Chat quick row ──────────────────────────────────────────────
        Row(children: [
          Expanded(child: TextField(
            controller: _chatCtrl,
            style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 10),
            onSubmitted: (_) { gs.sendChat(_chatCtrl.text); _chatCtrl.clear(); },
            decoration: InputDecoration(
              hintText: 'Chat...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 9),
              isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              filled: true, fillColor: AppColors.cardSurfaceDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
          )),
          const SizedBox(width: 6),
          Text(player.formattedChips, style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 11)),
        ]),
        const SizedBox(height: 6),

        // ── Bet slider ──────────────────────────────────────────────────
        if (!isPacked && !isOver) Row(children: [
          Text('Bet: ', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 10)),
          Expanded(child: SliderTheme(
            data: SliderTheme.of(ctx).copyWith(
              activeTrackColor: AppColors.goldPrimary,
              inactiveTrackColor: Colors.white12,
              thumbColor: AppColors.goldPrimary,
              overlayColor: AppColors.goldGlow.withOpacity(0.3),
              trackHeight: 3),
            child: Slider(
              value: _selectedBet.toDouble(),
              min: 100,
              max: (player.chips > 0 ? player.chips.toDouble().clamp(100, 10000) : 100),
              onChanged: (v) => setState(() => _selectedBet = v.round()),
            ),
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(7), border: Border.all(color: AppColors.goldBorder)),
            child: Text('🪙 ${_fmt(_selectedBet)}', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 11))),
        ]),
        const SizedBox(height: 6),

        // ── Game action buttons ─────────────────────────────────────────
        if (isOver)
          _fullBtn('NEW ROUND 🃏', AppColors.goldPrimary, Colors.black87, () => gs._startRound()) // triggers internally
        else if (isPacked)
          Container(padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
            child: Center(child: Text('You packed this round.', style: GoogleFonts.poppins(color: AppColors.textMuted))))
        else Row(children: [
          // PACK
          Expanded(child: _actionBtn('PACK', 'Fold', const Color(0xFF7F0000), Icons.close, onTap: gs.pack)),
          const SizedBox(width: 6),
          // BLIND / CHAAL
          Expanded(flex: 2, child: _actionBtn(
            hasSeen ? 'CHAAL' : 'BLIND',
            hasSeen ? '🪙 ${_fmt(_selectedBet)}' : '🪙 ${_fmt(_selectedBet ~/ 2)}',
            hasSeen ? const Color(0xFF1B5E20) : const Color(0xFF0D47A1),
            hasSeen ? Icons.casino : Icons.visibility_off,
            onTap: () {
              String? err;
              if (hasSeen) err = gs.chaal(_selectedBet);
              else err = gs.blind();
              if (err != null && ctx.mounted) _showError(ctx, err);
            },
          )),
          const SizedBox(width: 6),
          // SEE CARDS (if blind)
          if (!hasSeen)
            Expanded(child: _actionBtn('SEE', 'Cards', const Color(0xFF4A0072), Icons.visibility, onTap: gs.seeCards, isGold: true)),
          if (!hasSeen) const SizedBox(width: 6),
          // SIDE SHOW / SHOW
          Expanded(child: hasSeen
            ? _actionBtn('SIDE', 'Show', const Color(0xFF4A3000), Icons.compare_arrows,
                onTap: () {
                  final ok = gs.requestSideShow();
                  if (!ok && ctx.mounted) _showError(ctx, 'Side Show not available');
                })
            : _actionBtn('SHOW', 'Reveal', const Color(0xFF0D47A1), Icons.emoji_events,
                onTap: gs.show)),
        ]),
      ]),
    );
  }

  Widget _actionBtn(String label, String subLabel, Color color, IconData icon, {required VoidCallback onTap, bool isGold = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isGold
            ? const LinearGradient(colors: [AppColors.goldLight, AppColors.goldDark])
            : LinearGradient(colors: [color, color.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isGold ? AppColors.goldPrimary : color.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: isGold ? Colors.black : Colors.white, size: 18),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.poppins(color: isGold ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          Text(subLabel, style: GoogleFonts.poppins(color: isGold ? Colors.black54 : Colors.white60, fontSize: 9)),
        ]),
      ),
    );
  }

  Widget _fullBtn(String label, Color bg, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), boxShadow: AppColors.goldGlowShadow),
        child: Center(child: Text(label, style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.bold, fontSize: 15))),
      ),
    );
  }

  // ── Invite Dialog ─────────────────────────────────────────────────────────
  void _showInviteDialog(BuildContext ctx, TeenPattiGameState gs, {String? seatId}) {
    final ctrl = TextEditingController();
    showDialog(context: ctx, builder: (_) => Dialog(
      backgroundColor: AppColors.cardSurfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.goldBorder)),
      child: Padding(padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Invite to Table', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Friend name (optional)',
              hintStyle: GoogleFonts.poppins(color: AppColors.textMuted),
              filled: true, fillColor: AppColors.backgroundDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: GestureDetector(onTap: () => Navigator.pop(ctx),
              child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white24)),
                child: Center(child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textMuted)))))),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                final targetSeat = seatId ?? gs.seats.firstWhere((s) => s.isEmpty, orElse: () => TPSeat.empty('none')).seatId;
                if (targetSeat != 'none') {
                  gs.inviteToSeat(targetSeat, friendName: ctrl.text.trim().isEmpty ? null : ctrl.text.trim());
                }
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

  // ── Helpers ───────────────────────────────────────────────────────────────
  Color _statusColor(TPStatus s) {
    switch (s) {
      case TPStatus.blind:   return Colors.blueAccent;
      case TPStatus.seen:    return AppColors.emeraldGreen;
      case TPStatus.packed:  return Colors.grey;
      case TPStatus.winner:  return AppColors.goldPrimary;
      default:               return AppColors.goldBorder;
    }
  }

  String _statusLabel(TPStatus s) {
    switch (s) {
      case TPStatus.blind:   return 'BLIND';
      case TPStatus.seen:    return 'SEEN';
      case TPStatus.packed:  return 'PACKED';
      case TPStatus.winner:  return 'WINNER';
      default:               return '';
    }
  }

  String _fmt(int v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000)   return '${(v / 1000).toStringAsFixed(0)}K';
    return '$v';
  }
}
