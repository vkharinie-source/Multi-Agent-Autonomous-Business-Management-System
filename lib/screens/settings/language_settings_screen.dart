import 'package:flutter/material.dart';
import '../../core/services/settings_service.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'English';

  final List<Map<String, dynamic>> _languages = [
    {'name': 'English', 'subtitle': 'Default language', 'icon': Icons.language},
    {'name': 'தமிழ்', 'subtitle': 'Tamil', 'icon': Icons.translate},
    {'name': 'हिन्दी', 'subtitle': 'Hindi', 'icon': Icons.translate},
    {'name': 'తెలుగు', 'subtitle': 'Telugu', 'icon': Icons.translate},
    {'name': 'ಕನ್ನಡ', 'subtitle': 'Kannada', 'icon': Icons.translate},
    {'name': 'മലയാളം', 'subtitle': 'Malayalam', 'icon': Icons.translate},
  ];

  bool _isSaving = false;
  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final language = await SettingsService.getLanguage();

    if (!mounted) return;

    setState(() {
      _selectedLanguage = language;
    });
  }

  Future<void> _saveLanguage() async {
    setState(() {
      _isSaving = true;
    });

    await SettingsService.saveLanguage(_selectedLanguage);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text('Language changed to $_selectedLanguage'),
      ),
    );
  }

  Widget _languageTile(Map<String, dynamic> language) {
    final selected = _selectedLanguage == language['name'];

    return Card(
      elevation: selected ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? const Color(0xff4169E1) : Colors.transparent,
          width: 2,
        ),
      ),
      child: RadioListTile<String>(
        value: language['name'],
        groupValue: _selectedLanguage,
        activeColor: const Color(0xff4169E1),
        secondary: CircleAvatar(
          backgroundColor: const Color(0xffe8efff),
          child: Icon(language['icon'], color: const Color(0xff4169E1)),
        ),
        title: Text(
          language['name'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(language['subtitle']),
        onChanged: (value) {
          setState(() {
            _selectedLanguage = value!;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(title: const Text("Language"), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff4169E1), Color(0xff6C63FF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.language, color: Colors.white, size: 45),
                    SizedBox(height: 12),
                    Text(
                      "Choose Your Language",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Select the language you prefer for the application.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: ListView.builder(
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    return _languageTile(_languages[index]);
                  },
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveLanguage,
                  icon: _isSaving ? const SizedBox() : const Icon(Icons.save),
                  label: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Save Language",
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
