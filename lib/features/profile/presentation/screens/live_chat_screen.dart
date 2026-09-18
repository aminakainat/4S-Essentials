import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_4sessentials/core/theme.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? _userId;
  String? _userName;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      _userName = user.displayName ?? user.email?.split('@').first ?? 'Customer';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _userId == null) return;

    _messageController.clear();
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    try {
      await _db.collection('messages').add({
        'chatId': _userId,
        'senderId': _userId,
        'senderName': _userName,
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Update custom chat index for admin
      await _db.collection('chats').doc(_userId).set({
        'chatId': _userId,
        'userName': _userName,
        'lastMessage': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        body: Center(
          child: Text('Please log in to chat with support', style: GoogleFonts.outfit(color: context.textColor)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryRose.withValues(alpha: 0.1),
              child: Icon(Icons.support_agent, color: AppTheme.primaryRose, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support Agent',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.sp, color: context.textColor),
                ),
                Text(
                  'Online • Ready to Help',
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
            child: StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('messages')
                  .where('chatId', isEqualTo: _userId)
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
                    final isMe = data['senderId'] == _userId;
                    final messageText = data['message'] ?? '';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h, left: isMe ? 50.w : 0, right: isMe ? 0 : 50.w),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isMe ? AppTheme.primaryRose : context.surfaceColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                            bottomLeft: isMe ? Radius.circular(16.r) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : Radius.circular(16.r),
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
                            color: isMe ? Colors.white : context.textColor,
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
                    decoration: InputDecoration(
                      hintText: 'Type your message here...',
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
