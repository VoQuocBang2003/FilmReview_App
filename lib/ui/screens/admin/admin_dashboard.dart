import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:review_film_app/ui/providers/user_provider.dart';
import 'package:review_film_app/ui/screens/login_screen.dart';
import 'package:review_film_app/ui/screens/admin/movie_management.dart';
import 'package:review_film_app/ui/screens/admin/user_management.dart';
import 'package:review_film_app/ui/screens/admin/category_management.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    // Ktra huong man hinh portrait or landscape
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng Điều Khiển Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              userProvider.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isLandscape = orientation == Orientation.landscape;
            final padding = isSmallScreen ? 16.0 : 24.0;

            // Adjust layout for landscape mode on small screens
            if (isLandscape && isSmallScreen) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column with profile
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            // Profile Card
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(padding),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.blue.shade100,
                                      child: Icon(
                                        Icons.person,
                                        size: 30,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Hi, ${currentUser?.name ?? 'Admin'}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Email: ${currentUser?.email ?? ''}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Quản Lý Hệ Thống',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right column with management cards
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildManagementCard(
                              context,
                              'Quản Lý Phim',
                              Icons.movie,
                              Colors.red.shade400,
                              Colors.red.shade50,
                              'Thêm, sửa, xóa thông tin phim',
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const MovieManagement(),
                                ),
                              ),
                              isCompact: true,
                            ),
                            const SizedBox(height: 8),
                            _buildManagementCard(
                              context,
                              'Quản Lý Người Dùng',
                              Icons.people,
                              Colors.blue.shade400,
                              Colors.blue.shade50,
                              'Quản lý tài khoản người dùng',
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const UserManagement(),
                                ),
                              ),
                              isCompact: true,
                            ),
                            const SizedBox(height: 8),
                            _buildManagementCard(
                              context,
                              'Quản Lý Thể Loại',
                              Icons.category,
                              Colors.green.shade400,
                              Colors.green.shade50,
                              'Thêm, sửa, xóa thể loại phim',
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CategoryManagement(),
                                ),
                              ),
                              isCompact: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Original layout for portrait mode or larger screens
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flex(
                              direction:
                                  isSmallScreen
                                      ? Axis.vertical
                                      : Axis.horizontal,
                              crossAxisAlignment:
                                  isSmallScreen
                                      ? CrossAxisAlignment.center
                                      : CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: isSmallScreen ? 40 : 30,
                                  backgroundColor: Colors.blue.shade100,
                                  child: Icon(
                                    Icons.person,
                                    size: isSmallScreen ? 45 : 35,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                SizedBox(
                                  width: isSmallScreen ? 0 : 16,
                                  height: isSmallScreen ? 16 : 0,
                                ),
                                Column(
                                  crossAxisAlignment:
                                      isSmallScreen
                                          ? CrossAxisAlignment.center
                                          : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hi, ${currentUser?.name ?? 'Admin'}',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 20 : 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign:
                                          isSmallScreen
                                              ? TextAlign.center
                                              : TextAlign.start,
                                    ),
                                    Text(
                                      'Email: ${currentUser?.email ?? ''}',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 30),
                    const Text(
                      'Quản Lý Hệ Thống',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    // Management Cards Grid
                    if (!isSmallScreen)
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: constraints.maxWidth > 900 ? 3 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          _buildManagementCard(
                            context,
                            'Quản Lý Phim',
                            Icons.movie,
                            Colors.red.shade400,
                            Colors.red.shade50,
                            'Thêm, sửa, xóa thông tin phim',
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MovieManagement(),
                              ),
                            ),
                          ),
                          _buildManagementCard(
                            context,
                            'Quản Lý Người Dùng',
                            Icons.people,
                            Colors.blue.shade400,
                            Colors.blue.shade50,
                            'Quản lý tài khoản người dùng',
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const UserManagement(),
                              ),
                            ),
                          ),
                          _buildManagementCard(
                            context,
                            'Quản Lý Thể Loại',
                            Icons.category,
                            Colors.green.shade400,
                            Colors.green.shade50,
                            'Thêm, sửa, xóa thể loại phim',
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CategoryManagement(),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildManagementCard(
                            context,
                            'Quản Lý Phim',
                            Icons.movie,
                            Colors.red.shade400,
                            Colors.red.shade50,
                            'Thêm, sửa, xóa thông tin phim',
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MovieManagement(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildManagementCard(
                            context,
                            'Quản Lý Người Dùng',
                            Icons.people,
                            Colors.blue.shade400,
                            Colors.blue.shade50,
                            'Quản lý tài khoản người dùng',
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const UserManagement(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildManagementCard(
                            context,
                            'Quản Lý Thể Loại',
                            Icons.category,
                            Colors.green.shade400,
                            Colors.green.shade50,
                            'Thêm, sửa, xóa thể loại phim',
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CategoryManagement(),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    Color backgroundColor,
    String description,
    VoidCallback onTap, {
    bool isCompact = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: backgroundColor,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isCompact ? 8 : 12),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: isCompact ? 24 : 30,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: isCompact ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isCompact ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isCompact ? 2 : 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: isCompact ? 12 : 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: isCompact ? 16 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
