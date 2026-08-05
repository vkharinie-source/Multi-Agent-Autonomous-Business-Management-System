import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget _infoTile(IconData icon, Color color, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(title: const Text("About"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff4169E1), Color(0xff6C63FF)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.business_center,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),

                  SizedBox(height: 18),

                  Text(
                    "Autonomous Business AI",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Enterprise AI Powered Business Management Platform",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _infoTile(Icons.info_outline, Colors.blue, "Version", "1.0.0"),

            _infoTile(Icons.code, Colors.deepPurple, "Framework", "Flutter"),

            _infoTile(
              Icons.storage,
              Colors.orange,
              "Backend",
              "FastAPI + MongoDB",
            ),

            _infoTile(
              Icons.smart_toy_outlined,
              Colors.green,
              "Artificial Intelligence",
              "Business AI Recommendation Engine",
            ),

            _infoTile(
              Icons.security,
              Colors.red,
              "Security",
              "JWT Authentication & Role Based Access",
            ),

            _infoTile(
              Icons.support_agent,
              Colors.teal,
              "Support",
              "support@autonomousbusinessai.com",
            ),

            const SizedBox(height: 25),

            const Text(
              "Autonomous Business AI helps organizations manage employees, inventory, sales, attendance, finance, reports, and AI-powered business insights through one intelligent platform.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 12),

            const Text(
              "© 2026 Autonomous Business AI",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            const Text(
              "All Rights Reserved",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
