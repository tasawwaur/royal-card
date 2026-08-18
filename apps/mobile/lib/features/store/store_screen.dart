import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
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
        title: Text('Store', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundDark2,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary), onPressed: () => Navigator.pop(context)),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.goldPrimary,
          labelColor: AppColors.goldPrimary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11),
          tabs: const [
            Tab(text: 'Items'),
            Tab(text: 'Avatars'),
            Tab(text: 'Frames'),
            Tab(text: 'Gifts'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: TabBarView(
          controller: _tabs,
          children: [
            _buildGrid(_virtualItems),
            _buildGrid(_avatars),
            _buildGrid(_frames),
            _buildGrid(_gifts),
          ],
        ),
      ),
    );
  }

  final _virtualItems = [
    _StoreItem('Gold Shield', '💠', '500 Gems'),
    _StoreItem('Crown', '👑', '1,000 Gems'),
    _StoreItem('Fire Aura', '🔥', '750 Gems'),
    _StoreItem('Star Trail', '⭐', '300 Gems'),
  ];
  final _avatars = [
    _StoreItem('Maharaja', '🤴', '2,000 Gems'),
    _StoreItem('Queen', '👸', '2,000 Gems'),
    _StoreItem('VIP Suit', '🕴', '1,500 Gems'),
    _StoreItem('Ninja', '🥷', '1,200 Gems'),
  ];
  final _frames = [
    _StoreItem('Gold Frame', '🖼', '800 Gems'),
    _StoreItem('Diamond Frame', '💎', '1,200 Gems'),
    _StoreItem('Fire Frame', '🔥', '950 Gems'),
    _StoreItem('Royal Frame', '⚜', '1,500 Gems'),
  ];
  final _gifts = [
    _StoreItem('Rose', '🌹', '10 Gems'),
    _StoreItem('Sports Car', '🏎', '500 Gems'),
    _StoreItem('Rocket', '🚀', '200 Gems'),
    _StoreItem('Diamond Ring', '💍', '1,000 Gems'),
    _StoreItem('Bomb', '💣', '50 Gems'),
    _StoreItem('Trophy', '🏆', '300 Gems'),
  ];

  Widget _buildGrid(List<_StoreItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildItemCard(items[i]),
    );
  }

  Widget _buildItemCard(_StoreItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(item.name, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(item.price, style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 11)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.goldDark]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Buy', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _StoreItem {
  final String name, emoji, price;
  const _StoreItem(this.name, this.emoji, this.price);
}
