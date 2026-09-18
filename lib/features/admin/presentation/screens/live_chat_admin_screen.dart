import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_4sessentials/core/theme.dart';

class LiveChatAdminScreen extends StatefulWidget {
  const LiveChatAdminScreen({super.key});

  @override
  State<LiveChatAdminScreen> createState() => _LiveChatAdminScreenState();
}

class _LiveChatAdminScreenState extends State<LiveChatAdminScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'CUSTOMER SUPPORT PORTAL',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.sp, color: context.textColor, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: context.textColor),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('chats').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRose));
          }

          final chats = snapshot.data?.docs ?? [];
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 60.sp, color: context.subtextColor),
                  SizedBox(height: 15.h),
                  Text('No active customer inquiries.', style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 13.sp)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final data = chats[index].data() as Map<String, dynamic>;
              final chatId = data['chatId'] ?? '';
              final userName = data['userName'] ?? 'Customer';
              final lastMsg = data['lastMessage'] ?? '';

              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.01), blurRadius: 10)
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryRose.withValues(alpha: 0.1),
                    child: Icon(Icons.person, color: AppTheme.primaryRose),
                  ),
                  title: Text(userName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: context.textColor)),
                  subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 12.sp)),
                  trailing: Icon(Icons.arrow_forward_ios, size: 14.sp, color: context.subtextColor.withValues(alpha: 0.3)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminChatDetailScreen(chatId: chatId, customerName: userName),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String customerName;
  const AdminChatDetailScreen({super.key, required this.chatId, required this.customerName});

  @override
  State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    try {
      // Send message as 'admin'
      await _db.collection('messages').add({
        'chatId': widget.chatId,
        'senderId': 'admin',
        'senderName': 'Support Agent',
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update last message in active chats listing
      await _db.collection('chats').doc(widget.chatId).set({
        'chatId': widget.chatId,
        'userName': widget.customerName,
        'lastMessage': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error sending message from admin: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          widget.customerName,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp, color: context.textColor),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('messages')
                  .where('chatId', isEqualTo: widget.chatId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRose));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isAdmin = data['senderId'] == 'admin';
                    final messageText = data['message'] ?? '';

                    return Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h, left: isAdmin ? 50.w : 0, right: isAdmin ? 0 : 50.w),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isAdmin ? AppTheme.primaryRose : context.surfaceColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                            bottomLeft: isAdmin ? Radius.circular(16.r) : Radius.zero,
                            bottomRight: isAdmin ? Radius.zero : Radius.circular(16.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.01),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          messageText,
                          style: GoogleFonts.outfit(
                            color: isAdmin ? Colors.white : context.textColor,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
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
                    controller: _messageController,
                    style: GoogleFonts.outfit(color: context.textColor, fontSize: 13.sp),
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Type response to customer...',
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
