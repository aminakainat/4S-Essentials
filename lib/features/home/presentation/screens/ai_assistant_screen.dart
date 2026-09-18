import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_4sessentials/core/theme.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      'isBot': true,
      'text': 'Hello! I am your AI Jewelry Stylist. Ask me anything about gold purity, diamond ratings, ring sizing, or how to style jewelry for your next special occasion!',
    }
  ];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'isBot': false, 'text': text});
      _controller.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Mock AI intelligent replies
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      String response = "That's a great question! For high-quality, long-lasting jewelry, we recommend 22K Gold or Platinum. They retain their luster beautifully and hold gem mounts securely.";
      
      final query = text.toLowerCase();
      
      // Keywords for available items
      bool asksAvailable = query.contains('available') || 
                           query.contains('stock') || 
                           query.contains('collection') || 
                           query.contains('catalog') || 
                           query.contains('items') || 
                           query.contains('product') || 
                           query.contains('show') || 
                           query.contains('buy') || 
                           query.contains('list') || 
                           query.contains('shop') ||
                           query.contains('kia ha') || 
                           query.contains('kia hai') || 
                           query.contains('milay ga') || 
                           query.contains('milega') || 
                           query.contains('dikhao') || 
                           query.contains('dikhayein');
                           
      // Keywords for customization / design ideas
      bool asksCustom = query.contains('custom') || 
                        query.contains('bespoke') || 
                        query.contains('design') || 
                        query.contains('make') || 
                        query.contains('idea') || 
                        query.contains('ideas') || 
                        query.contains('personal') || 
                        query.contains('khud') || 
                        query.contains('apna') || 
                        query.contains('tahfa') || 
                        query.contains('gift') ||
                        query.contains('banwana') ||
                        query.contains('tarika') ||
                        query.contains('tareeqa');

      if (asksAvailable) {
        bool inUrdu = query.contains('kia') || query.contains('ha') || query.contains('hai') || query.contains('dikhao') || query.contains('milega') || query.contains('milay');
        if (inUrdu) {
          response = "Hamare paas bohot hi premium aur customized jewelry collection available hai! Yeh items aap abhi dekh sakte hain:\n\n"
              "💍 **Rings (Angothiyan):**\n"
              "• *Diamond Band* — \$850.00 (Pure luxury selection)\n"
              "• *Stainless Steel Ring* — \$45.00 (Daily wear ke liye)\n\n"
              "✨ **Earrings (Jhumkay):**\n"
              "• *Pearl Drop Earrings* — \$2,500.00 (Elegant design)\n"
              "• *Silver Studs* — \$85.00 (Minimalist style)\n"
              "• *Rose Gold Hoop* — \$150.00 (Modern look)\n\n"
              "💫 **Bangles (Kangan):**\n"
              "• *Small Gold Bangle* — \$120.00 (Classy gold look)\n\n"
              "📿 **Necklace (Haar):**\n"
              "• *Floral Necklace* — \$3,200.00 (Masterpiece collection)\n\n"
              "Aap in sab ko seedha Home Screen par dekh kar cart mein add kar sakte hain! Aapko in mein se kya dekhna hai?";
        } else {
          response = "We have an exquisite collection of fine jewelry available in our store! Here is a summary of our catalog:\n\n"
              "💍 **Rings:**\n"
              "• *Diamond Band* — \$850.00\n"
              "• *Stainless Steel Ring* — \$45.00\n\n"
              "✨ **Earrings:**\n"
              "• *Pearl Drop Earrings* — \$2,500.00\n"
              "• *Silver Studs* — \$85.00\n"
              "• *Rose Gold Hoop* — \$150.00\n\n"
              "💫 **Bangles:**\n"
              "• *Small Gold Bangle* — \$120.00\n\n"
              "📿 **Necklaces:**\n"
              "• *Floral Necklace* — \$3,200.00\n"
              "\n"
              "All these pieces are fully available for ordering on the Home Screen. Let me know if you need styling advice for any of these!";
        }
      } else if (asksCustom) {
        bool inUrdu = query.contains('kia') || query.contains('ha') || query.contains('hai') || query.contains('khud') || query.contains('apna') || query.contains('tarika') || query.contains('tareeqa') || query.contains('banwana');
        if (inUrdu) {
          response = "Ji bilkul! Aap apni marzi ki customized jewelry design karwa sakte hain. Hamare paas **Bespoke Custom Orders** ki facility hai. Kuch unique ideas yeh hain:\n\n"
              "1. **Bespoke Engagement Ring:** Apni marzi ka metal base (22K Gold ya Platinum) aur precious gemstone (Diamond, Ruby, Emerald) choose karein. Angoothi ke andar apna naam ya special date engrave karwayein.\n"
              "2. **Name Necklace:** Gold ya Silver mein apna naam ya initials 3D script design mein banwayein.\n"
              "3. **Birthstone Jewelry:** Apni ya kisi loved one ki birthstone (jaise Sapphire ya Pearl) ring ya bangle mein add karwayein.\n"
              "4. **Recreate from Sketch:** Agar aapke paas koi sketch ya picture hai, toh use upload karke humse banwa sakte hain!\n\n"
              "**Order kaise karein?**\n"
              "Home screen par **'Bespoke Custom Orders'** banner par tap karein. Wahan metal type, gemstone, size select karein, design details likhein, aur apna sketch upload karke submit kar dein. Hamare master craftsmen aapse contact karenge!";
        } else {
          response = "Absolutely! Customizing jewelry is a beautiful way to create a personal masterpiece. We offer **Bespoke Custom Orders** with master craftsmanship. Here are some custom design ideas:\n\n"
              "1. **Bespoke Engagement Rings:** Choose your metal base (22K Gold, 18K Rose Gold, or Platinum) and set it with a certified Diamond, Ruby, Emerald, or Sapphire. You can add personalized engraving inside the band.\n"
              "2. **3D Monogram & Name Necklaces:** Order a custom pendant featuring your name, monogram, or special initials in luxurious Gold or Silver.\n"
              "3. **Birthstone Accents:** Add personal birthstone highlights to bracelets, bangles, or rings (e.g., Emerald for May, Pearl for June) for meaningful gifts.\n"
              "4. **Replicate from Reference / Sketch:** Have a custom sketch or photo of a historical piece? Upload it directly!\n\n"
              "**How to request custom design:**\n"
              "Tap the **'Bespoke Custom Orders'** banner on the Home Screen. Fill out the metal base, gemstone, size, describe your design pattern, and upload an inspiration image/sketch. Our team of master craftsmen will review it and guide you within 24-48 hours!";
        }
      } else if (query.contains('ring') || query.contains('size')) {
        response = "To find your perfect ring size, check out our **Ring Size Guide** on the product detail page! You can measure your finger circumference in millimeters, and we'll translate it to US standard sizes (5 to 9).";
      } else if (query.contains('wedding') || query.contains('bride') || query.contains('engagement')) {
        response = "For weddings and engagements, Solitaire Diamond Rings and Rose Gold Bands are the top choices. Consider VVS1 clarity or GIA certified diamonds for maximum sparkle and luxury appeal!";
      } else if (query.contains('purity') || query.contains('certificate') || query.contains('karat')) {
        response = "All our jewelry comes with official Hallmarked Gold and Diamond Certificates. 24K is 99.9% pure gold, 22K is 91.6% pure, and 18K is 75% pure (ideal for delicate diamond studding).";
      } else if (query.contains('price') || query.contains('discount') || query.contains('coupon')) {
        response = "You can create coupons in the Coupon Management portal if you are an Admin! For regular customers, checkout rewards or referrals can get you up to 10% off using code 'GOLD10'.";
      }

      setState(() {
        _isTyping = false;
        _messages.add({'isBot': true, 'text': response});
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryRose.withValues(alpha: 0.1),
              child: Icon(Icons.psychology, color: AppTheme.primaryRose, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Jewelry Assistant',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.sp, color: context.textColor),
                ),
                Text(
                  'Active Stylist Bot',
                  style: GoogleFonts.outfit(fontSize: 10.sp, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: context.surfaceColor,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: context.textColor),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isBot = msg['isBot'] as bool;
                final text = msg['text'] as String;

                return Align(
                  alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h, left: isBot ? 0 : 50.w, right: isBot ? 50.w : 0),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isBot ? context.surfaceColor : AppTheme.primaryRose,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        topRight: Radius.circular(16.r),
                        bottomLeft: isBot ? Radius.zero : Radius.circular(16.r),
                        bottomRight: isBot ? Radius.circular(16.r) : Radius.zero,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.01),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      text,
                      style: GoogleFonts.outfit(
                        color: isBot ? context.textColor : Colors.white,
                        fontSize: 13.sp,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'AI Stylist is thinking...',
                  style: GoogleFonts.outfit(fontSize: 11.sp, color: context.subtextColor, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.outfit(color: context.textColor, fontSize: 13.sp),
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask about matching, styling, gold purity...',
                      hintStyle: GoogleFonts.outfit(color: context.subtextColor, fontSize: 13.sp),
                      fillColor: context.scaffoldBg,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryRose,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
