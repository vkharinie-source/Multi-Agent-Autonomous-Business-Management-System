import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();

  final TextEditingController _newPasswordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Future<void> _changePassword() async {
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
        content: Text("Password changed successfully"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xff4169E1),
                child: Icon(Icons.lock_outline, color: Colors.white, size: 45),
              ),

              const SizedBox(height: 25),

              TextFormField(
                controller: _currentPasswordController,
                obscureText: _hideCurrentPassword,
                decoration: _inputDecoration(
                  label: "Current Password",
                  icon: Icons.lock_outline,
                  obscure: _hideCurrentPassword,
                  onToggle: () {
                    setState(() {
                      _hideCurrentPassword = !_hideCurrentPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter current password";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _newPasswordController,
                obscureText: _hideNewPassword,
                decoration: _inputDecoration(
                  label: "New Password",
                  icon: Icons.lock_reset,
                  obscure: _hideNewPassword,
                  onToggle: () {
                    setState(() {
                      _hideNewPassword = !_hideNewPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter new password";
                  }

                  if (value.length < 8) {
                    return "Minimum 8 characters";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _hideConfirmPassword,
                decoration: _inputDecoration(
                  label: "Confirm Password",
                  icon: Icons.lock,
                  obscure: _hideConfirmPassword,
                  onToggle: () {
                    setState(() {
                      _hideConfirmPassword = !_hideConfirmPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Update Password",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
