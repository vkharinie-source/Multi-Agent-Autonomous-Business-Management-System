import 'package:flutter/material.dart';

import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xff4169E1),
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),

                Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Harini VK",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            const Text(
              "harini@gmail.com",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text("Full Name"),
                    subtitle: const Text("Harini VK"),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text("Email"),
                    subtitle: const Text("harini@gmail.com"),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text("Phone"),
                    subtitle: const Text("+91 9876543210"),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text("Role"),
                    subtitle: const Text("Administrator"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 17),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
