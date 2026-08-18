import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  bool _friendRequestsEnabled = true;
  bool _privateProfileEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundDark2,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary), onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Account ──────────────────────────────────────────────────
            _sectionHeader('Account'),
            _settingsTile(Icons.person, 'Edit Profile', trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted)),
            _settingsTile(Icons.phone, 'Mobile Number', trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted)),
            _settingsTile(Icons.lock_outline, 'Change PIN', trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted)),
            const SizedBox(height: 16),

            // ── Sound ─────────────────────────────────────────────────────
            _sectionHeader('Sound & Music'),
            _settingsTile(Icons.volume_up, 'Sound Effects', trailing: Switch(
              value: _soundEnabled,
              onChanged: (v) => setState(() => _soundEnabled = v),
              activeColor: AppColors.goldPrimary,
            )),
            _settingsTile(Icons.music_note, 'Background Music', trailing: Switch(
              value: _musicEnabled,
              onChanged: (v) => setState(() => _musicEnabled = v),
              activeColor: AppColors.goldPrimary,
            )),
            _settingsTile(Icons.vibration, 'Vibration', trailing: Switch(
              value: _vibrationEnabled,
              onChanged: (v) => setState(() => _vibrationEnabled = v),
              activeColor: AppColors.goldPrimary,
            )),
            const SizedBox(height: 16),

            // ── Notifications ─────────────────────────────────────────────
            _sectionHeader('Notifications'),
            _settingsTile(Icons.notifications, 'Push Notifications', trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
              activeColor: AppColors.goldPrimary,
            )),
            _settingsTile(Icons.person_add, 'Friend Requests', trailing: Switch(
              value: _friendRequestsEnabled,
              onChanged: (v) => setState(() => _friendRequestsEnabled = v),
              activeColor: AppColors.goldPrimary,
            )),
            const SizedBox(height: 16),

            // ── Privacy ───────────────────────────────────────────────────
            _sectionHeader('Privacy'),
            _settingsTile(Icons.visibility_off, 'Private Profile', trailing: Switch(
              value: _privateProfileEnabled,
              onChanged: (v) => setState(() => _privateProfileEnabled = v),
              activeColor: AppColors.goldPrimary,
            )),
            _settingsTile(Icons.block, 'Blocked Players', trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted)),
            const SizedBox(height: 16),

            // ── Help & About ──────────────────────────────────────────────
            _sectionHeader('Help & About'),
            _settingsTile(Icons.help_outline, 'Help & Support', trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted)),
            _settingsTile(Icons.info_outline, 'About Teen Patti Gold', trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted)),
            _settingsTile(Icons.gavel, 'Terms of Service', trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted)),
            _settingsTile(Icons.privacy_tip_outlined, 'Privacy Policy', trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted)),
            const SizedBox(height: 20),

            // ── Logout ────────────────────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.rubyRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.rubyRed, width: 1.5),
                ),
                child: Center(child: Text('Logout', style: GoogleFonts.poppins(color: AppColors.rubyRed, fontWeight: FontWeight.bold, fontSize: 15))),
              ),
            ),
            const SizedBox(height: 12),

            // Version
            Center(child: Text('Teen Patti Gold v5.4.2', style: GoogleFonts.poppins(color: AppColors.textDisabled, fontSize: 11))),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: GoogleFonts.poppins(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
    );
  }

  Widget _settingsTile(IconData icon, String title, {required Widget trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.goldSecondary, size: 22),
        title: Text(title, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13)),
        trailing: trailing,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      ),
    );
  }
}
