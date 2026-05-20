import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  final String username;
  final String email;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.email,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _currentUsername;
  bool _isNotifEnabled = true;

  @override
  void initState() {
    super.initState();
    _currentUsername = widget.username;
    _loadNotifSetting();
  }

  Future<void> _loadNotifSetting() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _isNotifEnabled = prefs.getBool('is_notif_enabled') ?? true;
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Keluar Aplikasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey),
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                    (route) => false,
              );
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(
      text: _currentUsername,
    );

    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Edit Profil',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving
                    ? null
                    : () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                  if (nameController.text.trim().isEmpty) return;

                  setStateDialog(() => isSaving = true);

                  final newName =
                  nameController.text.trim();

                  final response =
                  await ApiService.updateProfile(
                    widget.userId,
                    newName,
                  );

                  if (!context.mounted) return;

                  Navigator.pop(context);

                  if (response['message'] ==
                      'Profil berhasil diperbarui') {
                    setState(() {
                      _currentUsername = newName;
                    });

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Profil berhasil diperbarui!',
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          response['message'] ??
                              'Gagal memperbarui',
                        ),
                      ),
                    );
                  }
                },
                child: isSaving
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();

    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Ubah Password',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPassController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password Lama',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: newPassController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving
                    ? null
                    : () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                  if (oldPassController.text.isEmpty ||
                      newPassController.text.isEmpty) {
                    return;
                  }

                  if (newPassController.text.length < 6) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password baru minimal 6 karakter',
                        ),
                      ),
                    );
                    return;
                  }

                  setStateDialog(() => isSaving = true);

                  final response =
                  await ApiService.updatePassword(
                    widget.userId,
                    oldPassController.text,
                    newPassController.text,
                  );

                  if (!context.mounted) return;

                  setStateDialog(() => isSaving = false);

                  if (response['message'] ==
                      'Password berhasil diubah') {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password berhasil diubah!',
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          response['message'] ??
                              'Gagal mengubah password',
                        ),
                      ),
                    );
                  }
                },
                child: isSaving
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _currentUsername);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.cardBackground,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Profil Saya',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
            onPressed: () =>
                Navigator.pop(context, _currentUsername),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                    AppColors.primary.withOpacity(0.1),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                _currentUsername,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              _buildMenuTile(
                icon: Icons.edit_outlined,
                title: 'Edit Profil',
                onTap: _showEditProfileDialog,
              ),

              _buildMenuTile(
                icon: Icons.lock_outline,
                title: 'Ubah Password',
                onTap: _showChangePasswordDialog,
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Pengaturan Notifikasi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: Switch(
                    value: _isNotifEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (value) async {
                      setState(() {
                        _isNotifEnabled = value;
                      });

                      final prefs =
                      await SharedPreferences
                          .getInstance();

                      await prefs.setBool(
                        'is_notif_enabled',
                        value,
                      );

                      if (value) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content:
                            Text('Notifikasi dihidupkan'),
                            duration: Duration(seconds: 1),
                          ),
                        );

                        NotificationService
                            .showDeadlineNotification(
                          title: 'Notifikasi Aktif 🔔',
                          body:
                          'Kami akan mengingatkan tugas yang mepet hari ini dan besok!',
                        );
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content:
                            Text('Notifikasi dimatikan'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(
                      color: Colors.redAccent,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Keluar Akun',
                    style:
                    TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () =>
                      _showLogoutDialog(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}