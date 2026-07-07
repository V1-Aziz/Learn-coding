import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'cards_screen.dart';
import 'profile_screen.dart';
import 'vehicles_screen.dart';
import 'subscriptions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMediumScreen = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 26),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMediumScreen ? 30.0 : 20.0,
            vertical: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Quick Action'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                children: [
                  _buildSettingsItem(Icons.language, 'Language',
                      value: 'English'),
                  _buildDivider(),
                  _buildSettingsItem(Icons.brightness_6, 'Theme',
                      value: 'Light'),
                  _buildDivider(),
                  _buildSettingsItem(Icons.text_fields, 'Font Size',
                      value: 'Medium'),
                  _buildDivider(),
                  _buildSettingsItem(
                      Icons.notifications_outlined, 'Notifications'),
                ],
              ),
              const SizedBox(height: 28),
              _buildSectionTitle('Security'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                children: [
                  _buildSettingsItem(Icons.fingerprint, 'Biometric Authentication',
                      value: 'Enabled'),
                  _buildDivider(),
                  _buildSettingsItem(Icons.lock_outline, 'MPIN',
                      value: 'Activated'),
                  _buildDivider(),
                  _buildSettingsItem(Icons.vpn_key, 'Change Password'),
                ],
              ),
              const SizedBox(height: 28),
              _buildSectionTitle('My Information'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                children: [
                  _buildSettingsItem(
                    Icons.person_outline,
                    'Profile Information',
                    onTap: () => _navigateToPage(const ProfileScreen()),
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    Icons.directions_car_outlined,
                    'Vehicle Information',
                    onTap: () => _navigateToPage(const VehiclesScreen()),
                  ),
                  _buildDivider(),
                  _buildSettingsItem(Icons.add_circle_outline, 'Add Vehicle'),
                  _buildDivider(),
                  _buildSettingsItem(
                    Icons.credit_card,
                    'My Cards',
                    onTap: () => _navigateToPage(const CardsScreen()),
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    Icons.card_giftcard,
                    'Subscription Plans',
                    onTap: () => _navigateToPage(const SubscriptionsScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(height: 1, color: Colors.grey.shade300),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title, {
    String? value,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (value != null) ...[const SizedBox(width: 8)],
              if (value != null)
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
