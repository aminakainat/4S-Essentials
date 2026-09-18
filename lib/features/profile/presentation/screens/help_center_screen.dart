import 'package:flutter/material.dart';
import 'package:flutter_4sessentials/core/theme.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(
          'Help Center',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search for help...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.textLight),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primaryRose,
            labelColor: AppTheme.primaryRose,
            unselectedLabelColor: AppTheme.textLight,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'FAQ'),
              Tab(text: 'Contact Us'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFAQSection(),
                _buildContactUsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {'q': 'How to track my order?', 'a': 'You can track your order in the "Orders" section of your profile.'},
      {'q': 'What is the return policy?', 'a': 'Returns are accepted within 30 days of purchase for unused items.'},
      {'q': 'Are all products authentic?', 'a': 'Yes, all products from 4S Essentials are 100% authentic jewelry.'},
      {'q': 'How to apply coupons?', 'a': 'Enter the coupon code at the checkout screen before final payment.'},
      {'q': 'Is shipping worldwide?', 'a': 'Currently, we ship to selected regions. Check availability at checkout.'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ExpansionTile(
            title: Text(
              faqs[index]['q']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            childrenPadding: const EdgeInsets.all(20).copyWith(top: 0),
            backgroundColor: Colors.transparent,
            collapsedIconColor: AppTheme.primaryRose,
            iconColor: AppTheme.primaryRose,
            shape: const RoundedRectangleBorder(side: BorderSide.none),
            children: [
              Text(
                faqs[index]['a']!,
                style: const TextStyle(color: AppTheme.textLight),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactUsSection() {
    final contactOptions = [
      {'name': '24/7 Live Chat', 'icon': Icons.chat_bubble_outline, 'val': 'Speak with an agent now'},
      {'name': 'WhatsApp', 'icon': Icons.phone_android_outlined, 'val': '+1 234 567 890'},
      {'name': 'Customer Support', 'icon': Icons.headset_mic_outlined, 'val': 'Toll-free: 1-800-456-789'},
      {'name': 'Email Us', 'icon': Icons.email_outlined, 'val': 'support@4sessentials.com'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: contactOptions.length,
      itemBuilder: (context, index) {
        final option = contactOptions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRose.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(option['icon'] as IconData, color: AppTheme.primaryRose),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      option['val'] as String,
                      style: const TextStyle(color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textLight),
            ],
          ),
        );
      },
    );
  }
}

