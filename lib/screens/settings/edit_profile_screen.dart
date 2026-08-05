import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController(
    text: 'Harini VK',
  );

  final TextEditingController _emailController = TextEditingController(
    text: 'harini@gmail.com',
  );

  final TextEditingController _phoneController = TextEditingController(
    text: '+91 9876543210',
  );

  final TextEditingController _departmentController = TextEditingController(
    text: 'Administration',
  );

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Profile updated successfully'),
      ),
    );

    Navigator.pop(context);
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffe4e8f0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xff4169e1), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),

                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 58,
                      backgroundColor: Color(0xff4169e1),
                      child: Icon(Icons.person, size: 64, color: Colors.white),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff6c63ff),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Profile photo upload will be connected later',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  validator: (value) {
                    final name = value?.trim() ?? '';

                    if (name.isEmpty) {
                      return 'Enter your full name';
                    }

                    if (name.length < 3) {
                      return 'Name must contain at least 3 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Enter your email address';
                    }

                    final emailPattern = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

                    if (!emailPattern.hasMatch(email)) {
                      return 'Enter a valid email address';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                  ),
                  validator: (value) {
                    final phone = value?.trim() ?? '';

                    if (phone.isEmpty) {
                      return 'Enter your phone number';
                    }

                    if (phone.length < 10) {
                      return 'Enter a valid phone number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _departmentController,
                  textInputAction: TextInputAction.done,
                  decoration: _inputDecoration(
                    label: 'Department',
                    icon: Icons.business_outlined,
                  ),
                  validator: (value) {
                    final department = value?.trim() ?? '';

                    if (department.isEmpty) {
                      return 'Enter your department';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveProfile,
                    icon: _isLoading
                        ? const SizedBox.shrink()
                        : const Icon(Icons.save_outlined),
                    label: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
