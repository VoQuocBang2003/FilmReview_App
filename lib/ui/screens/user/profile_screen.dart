import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:review_film_app/models/user.dart';
import 'package:review_film_app/ui/providers/user_provider.dart';
import 'package:review_film_app/ui/widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser!;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser!;

    try {
      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      final success = await userProvider.updateProfile(updatedUser);

      if (success) {
        setState(() {
          _isEditing = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
        );
      } else {
        setState(() {
          _errorMessage = 'Cập nhật hồ sơ thất bại';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi: $e';
      });
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isPasswordVisible = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Đổi Mật Khẩu'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: currentPasswordController,
                        decoration: getInputDecoration(
                          labelText: 'Mật Khẩu Hiện Tại',
                          hintText: 'Nhập mật khẩu hiện tại của bạn',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !isPasswordVisible,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: newPasswordController,
                        decoration: getInputDecoration(
                          labelText: 'Mật Khẩu Mới',
                          hintText: 'Nhập mật khẩu mới của bạn',
                          prefixIcon: Icons.lock,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !isPasswordVisible,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmPasswordController,
                        decoration: getInputDecoration(
                          labelText: 'Xác Nhận Mật Khẩu Mới',
                          hintText: 'Xác nhận mật khẩu mới của bạn',
                          prefixIcon: Icons.lock,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !isPasswordVisible,
                      ),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Validate inputs
                      if (currentPasswordController.text.isEmpty ||
                          newPasswordController.text.isEmpty ||
                          confirmPasswordController.text.isEmpty) {
                        setState(() {
                          errorMessage = 'Tất cả các trường đều bắt buộc';
                        });
                        return;
                      }

                      if (newPasswordController.text.length < 6) {
                        setState(() {
                          errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự';
                        });
                        return;
                      }

                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        setState(() {
                          errorMessage = 'Mật khẩu không khớp';
                        });
                        return;
                      }

                      // Change password
                      final userProvider = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      );
                      try {
                        final success = await userProvider.changePassword(
                          userProvider.currentUser!.id!,
                          currentPasswordController.text,
                          newPasswordController.text,
                        );

                        if (success) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đổi mật khẩu thành công'),
                            ),
                          );
                        } else {
                          setState(() {
                            errorMessage = 'Mật khẩu hiện tại không chính xác';
                          });
                        }
                      } catch (e) {
                        setState(() {
                          errorMessage = 'Đã xảy ra lỗi: $e';
                        });
                      }
                    },
                    child: const Text('Đổi Mật Khẩu'),
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ Sơ Của Tôi'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Chỉnh Sửa Hồ Sơ',
            )
          else
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _nameController.text = user.name;
                  _emailController.text = user.email;
                  _phoneController.text = user.phone;
                  _errorMessage = null;
                });
              },
              tooltip: 'Hủy',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
              child:
                  user.profileImageUrl == null
                      ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      )
                      : null,
            ),
            const SizedBox(height: 24),

            // User Info Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: getInputDecoration(
                      labelText: 'Họ Tên',
                      hintText: 'Nhập họ tên đầy đủ của bạn',
                      prefixIcon: Icons.person,
                    ),
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập họ tên của bạn';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: getInputDecoration(
                      labelText: 'Email',
                      hintText: 'Nhập email của bạn',
                      prefixIcon: Icons.email,
                    ),
                    enabled: _isEditing,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email của bạn';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Vui lòng nhập email hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    decoration: getInputDecoration(
                      labelText: 'Số Điện Thoại',
                      hintText: 'Nhập số điện thoại của bạn',
                      prefixIcon: Icons.phone,
                    ),
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số điện thoại của bạn';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Error Message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Update Button
                  if (_isEditing)
                    ElevatedButton(
                      onPressed: userProvider.isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          userProvider.isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                'Cập Nhật Hồ Sơ',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),

                  const SizedBox(height: 16),

                  // Change Pwd Button
                  OutlinedButton.icon(
                    onPressed: _showChangePasswordDialog,
                    icon: const Icon(Icons.lock),
                    label: const Text('Đổi Mật Khẩu'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
