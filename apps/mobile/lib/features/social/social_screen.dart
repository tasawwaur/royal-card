import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Social', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundDark2,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary), onPressed: () => Navigator.pop(context)),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.goldPrimary,
          labelColor: AppColors.goldPrimary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11),
          tabs: const [
            Tab(text: 'Friends'),
            Tab(text: 'Messages'),
            Tab(text: 'Voice Rooms'),
            Tab(text: 'Notifications'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: TabBarView(
          controller: _tabs,
          children: [
            _buildFriends(),
            _buildMessages(),
            _buildVoiceRooms(),
            _buildNotifications(),
          ],
        ),
      ),
    );
  }

  Widget _buildFriends() {
    final friends = ['Fahad', 'Bahar', 'HODAYATSOP', 'LuckyShot', 'AceKing'];
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search friends...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.cardSurfaceDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        // Invite
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.maharajaGradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.goldBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_add, color: AppColors.goldPrimary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Invite Friends & Earn', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Get 50K chips for each friend who joins!', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 10)),
                  ]),
                ),
                const Icon(Icons.share, color: AppColors.goldPrimary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: friends.length,
            itemBuilder: (_, i) => _buildFriendTile(friends[i], i < 3),
          ),
        ),
      ],
    );
  }

  Widget _buildFriendTile(String name, bool isOnline) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(radius: 20, backgroundColor: AppColors.backgroundDark, child: const Icon(Icons.person, color: AppColors.goldPrimary, size: 22)),
              if (isOnline) Positioned(
                right: 0, bottom: 0,
                child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.onlineGreen, shape: BoxShape.circle)),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(isOnline ? 'Online' : 'Offline', style: GoogleFonts.poppins(color: isOnline ? AppColors.onlineGreen : AppColors.textMuted, fontSize: 10)),
            ]),
          ),
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.goldBorder),
              ),
              child: Text('Invite', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.chat_bubble_outline, color: AppColors.textMuted, size: 64),
      const SizedBox(height: 12),
      Text('No messages yet', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14)),
      Text('Start chatting with friends!', style: GoogleFonts.poppins(color: AppColors.textDisabled, fontSize: 12)),
    ]));
  }

  Widget _buildVoiceRooms() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildVoiceRoom('Fahad\'s Room', 12, true),
        _buildVoiceRoom('High Rollers Club', 8, false),
        _buildVoiceRoom('Teen Patti Talk', 25, false),
      ],
    );
  }

  Widget _buildVoiceRoom(String name, int users, bool isLive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isLive ? AppColors.maharajaGradient : const LinearGradient(colors: [AppColors.cardSurfaceDark, AppColors.surfaceElevated]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isLive ? AppColors.goldBorder : Colors.white10, width: isLive ? 1.5 : 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic, color: AppColors.goldPrimary, size: 32),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
            Row(children: [
              const Icon(Icons.people, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('$users listeners', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 10)),
              if (isLive) ...[const SizedBox(width: 8), Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                child: Text('LIVE', style: GoogleFonts.poppins(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              )],
            ]),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.goldDark]), borderRadius: BorderRadius.circular(8)),
            child: Text('Join', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifications() {
    final notifs = [
      'Fahad sent you a gift! 🎁',
      'Your chest opens in 16h 13m ⏰',
      'Daily Target reset! New challenges available 🎯',
      'HODAYATSOP challenged you to a game! 🃏',
      'You have a new friend request from LuckyShot 👥',
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: notifs.length,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardSurfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications, color: AppColors.goldPrimary, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(notifs[i], style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 12))),
          ],
        ),
      ),
    );
  }
}
