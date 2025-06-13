import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tourguideapp/core/services/gemini_service.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAITyping = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
      return;
    }

    final userMessage = _messageController.text;
    _messageController.clear();
    setState(() {
      _isLoading = true;
      _isAITyping = true;
    });

    try {
      // Lưu tin nhắn của người dùng vào Firebase
      await _firestore.collection('chats').add({
        'userId': _auth.currentUser?.uid,
        'message': userMessage,
        'isUser': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Gọi GeminiService để lấy phản hồi AI
      final aiResponse = await _geminiService.askGemini(userMessage);

      // Lưu phản hồi của AI vào Firebase
      await _firestore.collection('chats').add({
        'userId': _auth.currentUser?.uid,
        'message': aiResponse,
        'isUser': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isAITyping = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    ScreenUtil.init(context, designSize: const Size(375, 812));
    
    if (_errorMessage != null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate("Chat Screen"),
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _errorMessage = null);
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate("Chat Screen"),
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Container(
        color: AppColors.white,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .where('userId', isEqualTo: _auth.currentUser?.uid)
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  if (snapshot.hasError) {
                    final error = snapshot.error.toString();
                    if (error.contains('FAILED_PRECONDITION') && error.contains('index')) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Cần tạo index cho Firestore',
                              style: TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Vui lòng truy cập Firebase Console để tạo index',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                final url = Uri.parse(
                                  'https://console.firebase.google.com/v1/r/project/tour-guide-app-50140/firestore/indexes?create_composite=ClJwcm9qZWN0cy90b3VyLWd1aWRlLWFwcC01MDE0MC9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvY2hhdHMvaW5kZXhlcy9fEAEaCgoGdXNlcklkEAEaDQoJdGltZXN0YW1wEAEaDAoIX19uYW1lX18QAQ',
                                );
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Không thể mở trình duyệt')),
                                  );
                                }
                              },
                              child: const Text('Tạo Index'),
                            ),
                          ],
                        ),
                      );
                    }
                    return Center(child: Text('Đã xảy ra lỗi: \\${snapshot.error}'));
                  }
        
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
        
                  final docs = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    itemCount: docs.length + (_isAITyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isAITyping && index == docs.length) {
                        // Hiệu ứng typing của AI
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildAvatar(false),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const SizedBox(
                                  width: 36,
                                  child: Row(
                                    children: [
                                      _TypingDot(), _TypingDot(delay: 200), _TypingDot(delay: 400),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final isUser = data['isUser'] as bool;
                      final timestamp = (data['timestamp'] as Timestamp?);
                      final timeString = timestamp != null
                          ? DateFormat('HH:mm').format(timestamp.toDate())
                          : '';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment:
                              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isUser) _buildAvatar(false),
                            if (!isUser) const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                                constraints: const BoxConstraints(maxWidth: 320),
                                decoration: BoxDecoration(
                                  gradient: isUser
                                      ? const LinearGradient(
                                          colors: [Color(0xFF4F8FFF), Color(0xFF1CB5E0)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isUser ? null : Colors.grey[200],
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(isUser ? 16 : 4),
                                    topRight: Radius.circular(isUser ? 4 : 16),
                                    bottomLeft: const Radius.circular(16),
                                    bottomRight: const Radius.circular(16),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: isUser
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['message'] as String,
                                      style: TextStyle(
                                        color: isUser ? Colors.white : Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      timeString,
                                      style: TextStyle(
                                        color: isUser
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isUser) const SizedBox(width: 8),
                            if (isUser) _buildAvatar(true),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: TextField(
                          controller: _messageController,
                          enabled: !_isLoading,
                          decoration: const InputDecoration(
                            hintText: 'Nhập tin nhắn... ',
                            border: InputBorder.none,
                          ),
                          minLines: 1,
                          maxLines: 4,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send_rounded,
                          color: _isLoading ? Colors.grey : const Color(0xFF4F8FFF), size: 28),
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: isUser ? const Color(0xFF4F8FFF) : Colors.grey[300],
      child: isUser
          ? const Icon(Icons.person, color: Colors.white)
          : const Icon(Icons.smart_toy, color: Color(0xFF4F8FFF)),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({this.delay = 0});
  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1).animate(_controller);
    if (widget.delay > 0) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.5),
        child: Text(
          '.',
          style: TextStyle(fontSize: 28, color: Colors.black54, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}