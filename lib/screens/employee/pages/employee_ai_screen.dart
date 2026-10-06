import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';

class EmployeeAiChatScreen extends StatefulWidget {
  const EmployeeAiChatScreen({super.key});

  @override
  State<EmployeeAiChatScreen> createState() => _EmployeeAiChatScreenState();
}

class _EmployeeAiChatScreenState extends State<EmployeeAiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          "Hello! I am your AI Workplace Assistant. You can ask me anything about your attendance, leave policies, salary, tasks, shift guidelines, or company procedures. How can I help you today?",
      isUser: false,
      time: "Now",
    ),
  ];

  final List<String> _quickPrompts = [
    "How to apply for leave?",
    "How do I scan attendance QR?",
    "When is salary paid?",
    "What are the shift timings?",
    "How to improve my performance?",
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? selectedText]) async {
    final text = selectedText ?? _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true, time: _currentTime()));
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    String reply = '';

    try {
      final response = await http
          .post(
            ApiConfig.uri(ApiConfig.aiChatEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'message': text,
              'role': 'employee',
              'user_name': 'Team Member',
            }),
          )
          .timeout(const Duration(seconds: 16));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        reply = (data['reply'] as String?)?.trim() ?? '';
      }
    } catch (_) {
      // Local fallback
    }

    if (reply.isEmpty) {
      reply = _generateLocalReply(text);
    }

    if (!mounted) return;

    setState(() {
      _messages.add(_ChatMessage(text: reply, isUser: false, time: _currentTime()));
      _isTyping = false;
    });

    _scrollToBottom();
  }

  String _generateLocalReply(String query) {
    final lower = query.toLowerCase();

    if (lower.contains("leave") || lower.contains("apply leave") || lower.contains("holiday")) {
      return "To apply for time-off:\n\n"
          "1. Open **Apply Leave** from your Employee Dashboard.\n"
          "2. Choose your leave type (Casual, Sick, Personal, or Emergency).\n"
          "3. Select your Start & End dates.\n"
          "4. Fill in your reason and tap **Submit Leave Request**.\n\n"
          "Your manager will receive the request for review immediately.";
    }

    if (lower.contains("qr") || lower.contains("attendance") || lower.contains("clock in") || lower.contains("scan")) {
      return "To mark attendance:\n\n"
          "1. First ensure your phone is registered & approved under **Attendance Device**.\n"
          "2. Be present within the campus boundary.\n"
          "3. Open **Scan Attendance QR**.\n"
          "4. Point your camera at the manager's active QR screen to clock in securely.";
    }

    if (lower.contains("salary") || lower.contains("pay") || lower.contains("payslip")) {
      return "Salary & Compensation Information:\n\n"
          "• **Payout Date**: 1st working day of each calendar month.\n"
          "• **Payslip Downloads**: Head to **My Salary** to view and download your monthly payslips in PDF format.\n"
          "• **Queries**: For deductions or tax queries, reach out to the Finance desk.";
    }

    if (lower.contains("shift") || lower.contains("timing") || lower.contains("hours")) {
      return "Standard Working Hours:\n\n"
          "• **General Shift**: 09:00 AM – 06:00 PM (Monday to Friday)\n"
          "• **Lunch Break**: 01:00 PM – 02:00 PM\n"
          "• **Grace Period**: 15 minutes for check-in; after 09:15 AM check-ins are recorded as late arrival.";
    }

    if (lower.contains("performance") || lower.contains("score") || lower.contains("rating")) {
      return "Performance & KPIs:\n\n"
          "• **Key Metrics**: Punctuality, sprint milestone delivery, code quality, peer collaboration.\n"
          "• **Track Score**: View your current KPI rating & milestone analytics in **My Performance**.";
    }

    return "Thank you for asking! I am your AI Workplace Assistant. You can ask me questions regarding company procedures, shifts, attendance, leaves, payroll, or career tips. Let me know how else I can support you!";
  }

  String _currentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, "0");
    final period = now.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _clearChat() {
    setState(() {
      _messages
        ..clear()
        ..add(
          const _ChatMessage(
            text: "Chat cleared! How can I assist you with your work today?",
            isUser: false,
            time: "Now",
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FC),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _glowCircle(
                size: 260,
                color: const Color(0xFF7B61FF).withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: _glowCircle(
                size: 280,
                color: const Color(0xFFB66DFF).withValues(alpha: 0.10),
              ),
            ),
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == _messages.length) {
                        return _buildTypingBubble();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
                ),
                _buildQuickPromptsBar(),
                _buildMessageInput(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFEBE6F8), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3EEFF),
              foregroundColor: const Color(0xFF4C3F91),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF8E5BEF)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI Workplace Assistant',
                  style: TextStyle(
                    color: Color(0xFF201A3D),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                    SizedBox(width: 5),
                    Text(
                      'Live AI Support • 24/7',
                      style: TextStyle(color: Color(0xFF756E8A), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Clear Chat',
            onPressed: _clearChat,
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF756E8A)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPromptsBar() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: _quickPrompts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = _quickPrompts[index];
          return ActionChip(
            label: Text(
              prompt,
              style: const TextStyle(
                color: Color(0xFF6C5CE7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: const Color(0xFFF3EEFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE0D7F8)),
            ),
            onPressed: () => _sendMessage(prompt),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final bool isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF8E5BEF)],
                )
              : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5D4BB7).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF6C5CE7), size: 12),
                  SizedBox(width: 4),
                  Text(
                    'AI Assistant',
                    style: TextStyle(
                      color: Color(0xFF6C5CE7),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
            ],
            Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF201A3D),
                fontSize: 13.5,
                height: 1.45,
                fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                message.time,
                style: TextStyle(
                  color: isUser ? Colors.white70 : const Color(0xFFA59EB5),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5D4BB7).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF6C5CE7),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Thinking...',
              style: TextStyle(
                color: Color(0xFF756E8A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFEBE6F8))),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4BB7).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              style: const TextStyle(fontSize: 14, color: Color(0xFF201A3D)),
              decoration: InputDecoration(
                hintText: 'Ask anything about work, leave, salary...',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFA59EB5)),
                filled: true,
                fillColor: const Color(0xFFF9F7FD),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFECE7F6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFECE7F6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF8E5BEF)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _isTyping ? null : () => _sendMessage(),
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}
