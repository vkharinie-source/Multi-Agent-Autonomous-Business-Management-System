import 'dart:async';

import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool isTyping = false;

  final List<ChatMessage> messages = [
    const ChatMessage(
      text:
          "Hello Harinie! I am your Autonomous Business AI Assistant. How can I help you today?",
      isUser: false,
      time: "Now",
    ),
  ];

  final List<String> quickQuestions = [
    "Show today's attendance",
    "Check low stock products",
    "Give sales summary",
    "Show late employees",
  ];

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void sendMessage([String? selectedMessage]) {
    final text = selectedMessage ?? messageController.text.trim();

    if (text.isEmpty || isTyping) {
      return;
    }

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true, time: _currentTime()));

      messageController.clear();
      isTyping = true;
    });

    _scrollToBottom();

    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      setState(() {
        messages.add(
          ChatMessage(
            text: generateResponse(text),
            isUser: false,
            time: _currentTime(),
          ),
        );

        isTyping = false;
      });

      _scrollToBottom();
    });
  }

  String generateResponse(String message) {
    final text = message.toLowerCase();

    if (text.contains("attendance")) {
      return "Today's attendance summary:\n"
          "• Present: 42 employees\n"
          "• Absent: 4 employees\n"
          "• Late arrivals: 6 employees\n"
          "• Attendance rate: 91%";
    }

    if (text.contains("late")) {
      return "6 employees arrived late today. Priya S and Arun K recorded the highest delay. You can open the Late Arrival Detection module for details.";
    }

    if (text.contains("stock") || text.contains("inventory")) {
      return "5 products are currently low in stock. The most urgent items are Wireless Mouse, Keyboard, Printer Ink, USB Cable, and Office Paper.";
    }

    if (text.contains("sales") || text.contains("revenue")) {
      return "Today's sales are ₹24,850. Current revenue is ₹3.2 lakh, with an estimated growth of 12% compared with the previous period.";
    }

    if (text.contains("employee")) {
      return "The employee module currently contains employee profiles, departments, designations, salaries, attendance, leave, and performance details.";
    }

    if (text.contains("leave")) {
      return "There are 3 pending leave requests. You can review, approve, or reject them from the Leave Management module.";
    }

    if (text.contains("profit")) {
      return "The estimated profit is ₹86,000. AI analysis indicates that controlling inventory expenses may improve the profit margin.";
    }

    if (text.contains("hello") || text.contains("hi") || text.contains("hey")) {
      return "Hello! You can ask me about attendance, employees, inventory, sales, revenue, profit, or leave requests.";
    }

    if (text.contains("help")) {
      return "I can currently help with:\n"
          "• Employee details\n"
          "• Attendance information\n"
          "• Late arrivals\n"
          "• Inventory and low-stock alerts\n"
          "• Sales and revenue summaries\n"
          "• Leave requests";
    }

    return "I understood your question. This development version uses predefined business responses. Later, it can be connected to a real AI backend for dynamic answers.";
  }

  String _currentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, "0");
    final period = now.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $period";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  void clearChat() {
    setState(() {
      messages
        ..clear()
        ..add(
          const ChatMessage(
            text:
                "Chat cleared. How can I help you with your business operations?",
            isUser: false,
            time: "Now",
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FE),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;

          return Column(
            children: [
              buildHeader(context, isMobile),
              Expanded(
                child: isMobile ? buildMobileLayout() : buildDesktopLayout(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildHeader(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 8 : 22,
        isMobile ? 16 : 28,
        isMobile ? 12 : 28,
        isMobile ? 18 : 28,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff020A3D), Color(0xff2563EB), Color(0xff9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(isMobile ? 24 : 32),
          bottomRight: Radius.circular(isMobile ? 24 : 32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            SizedBox(width: isMobile ? 2 : 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 27),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Business AI Assistant",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 20 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        height: 8,
                        width: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xff4ADE80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Online • Development mode",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isMobile ? 11 : 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: "Clear chat",
              onPressed: clearChat,
              icon: const Icon(Icons.delete_outline, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 310, child: buildAssistantPanel()),
          const SizedBox(width: 22),
          Expanded(child: buildChatPanel()),
        ],
      ),
    );
  }

  Widget buildMobileLayout() {
    return Padding(padding: const EdgeInsets.all(12), child: buildChatPanel());
  }

  Widget buildAssistantPanel() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 38,
            backgroundColor: Color(0xffEEF4FF),
            child: Icon(Icons.smart_toy, color: Color(0xff2563EB), size: 40),
          ),
          const SizedBox(height: 18),
          const Text(
            "AI Business Assistant",
            style: TextStyle(
              color: Color(0xff081A63),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Ask questions about your employees, attendance, inventory, sales and business performance.",
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 26),
          const Text(
            "Quick questions",
            style: TextStyle(
              color: Color(0xff081A63),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...quickQuestions.map(
            (question) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                onPressed: () => sendMessage(question),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 15,
                  ),
                  side: const BorderSide(color: Color(0xffD8E2FF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  question,
                  style: const TextStyle(color: Color(0xff2563EB)),
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xffFFF7ED),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xffF59E0B)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "This version uses mock AI responses. Real AI can be connected later.",
                    style: TextStyle(
                      color: Color(0xff92400E),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChatPanel() {
    return Container(
      decoration: cardDecoration(),
      child: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? buildEmptyState()
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(18),
                    itemCount: messages.length + (isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (isTyping && index == messages.length) {
                        return buildTypingIndicator();
                      }

                      return buildMessageBubble(messages[index]);
                    },
                  ),
          ),
          buildMobileQuickQuestions(),
          buildMessageInput(),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forum_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 14),
          Text(
            "Start a conversation",
            style: TextStyle(
              color: Color(0xff081A63),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMobileQuickQuestions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 700) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: quickQuestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return ActionChip(
                label: Text(
                  quickQuestions[index],
                  style: const TextStyle(fontSize: 11),
                ),
                onPressed: () => sendMessage(quickQuestions[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xff2563EB), Color(0xff4F46E5)],
                )
              : null,
          color: isUser ? null : const Color(0xffF1F5FF),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(19),
            topRight: const Radius.circular(19),
            bottomLeft: Radius.circular(isUser ? 19 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 19),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  "AI Assistant",
                  style: TextStyle(
                    color: Color(0xff2563EB),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xff081A63),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                message.time,
                style: TextStyle(
                  color: isUser ? Colors.white70 : Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xffF1F5FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 15,
              width: 15,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text(
              "AI is typing...",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xffE8EAF2))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => sendMessage(),
                decoration: InputDecoration(
                  hintText: "Ask about your business...",
                  filled: true,
                  fillColor: const Color(0xffF7F9FF),
                  prefixIcon: const Icon(Icons.chat_bubble_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 52,
              width: 52,
              child: ElevatedButton(
                onPressed: isTyping ? null : () => sendMessage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2563EB),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: const Icon(Icons.send_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 22,
          offset: const Offset(0, 9),
        ),
      ],
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

