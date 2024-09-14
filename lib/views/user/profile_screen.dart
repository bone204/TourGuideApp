import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
    @override
  Widget build(BuildContext context) {
    // Truy cập ProfileViewModel từ Provider
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    // Kiểm tra xem người dùng có đang đăng nhập hay không
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Nếu không đăng nhập, chuyển hướng đến màn hình đăng nhập
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
      return const SizedBox.shrink(); // Trả về widget trống trong khi chuyển hướng
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconButton(Icons.chevron_left, () {
                    Navigator.of(context).pop();
                  }),
                  const Text(
                    'Profile',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  _buildIconButton(Icons.edit, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nút chỉnh sửa đã được bấm')),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(30, 16, 30, 16),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1639628735078-ed2f038a193e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  profileViewModel.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  profileViewModel.email,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                _buildStatsRow(),
                const SizedBox(height: 20),
                _buildInteractiveRow(Icons.location_pin, 'Favourite Destinations', Icons.chevron_right, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications clicked')),
                  );
                }),
                const SizedBox(height: 5),
                _buildInteractiveRow(Icons.history, 'Travel History', Icons.chevron_right, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications clicked')),
                  );
                }),
                const SizedBox(height: 5),
                _buildInteractiveRow(Icons.car_crash, 'Vehicle Rental Registration', Icons.chevron_right, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications clicked')),
                  );
                }),
                const SizedBox(height: 5),
                _buildInteractiveRow(Icons.feedback, 'Feedback', Icons.chevron_right, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications clicked')),
                  );
                }),
                const SizedBox(height: 5),
                _buildInteractiveRow(Icons.settings, 'Settings', Icons.chevron_right, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings clicked')),
                  );
                }),
                // const SizedBox(height: 20),
                // ElevatedButton.icon(
                //   onPressed: () async {
                //     await FirebaseAuth.instance.signOut(); // Đăng xuất người dùng
                //     Navigator.pushReplacement(
                //       context,
                //       MaterialPageRoute(builder: (context) => LoginScreen()),
                //     );
                //   },
                //   icon: const Icon(Icons.logout),
                //   label: const Text('Đăng Xuất'),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.redAccent,
                //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                //     textStyle: const TextStyle(
                //       fontSize: 18,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveRow(IconData leadingIcon, String title, IconData trailingIcon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 23, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0.5,
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(leadingIcon, color: Colors.black),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Icon(trailingIcon, color: Colors.grey),
          ],
        ),
      ),
      
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F7F9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.black, size: 25),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0.5,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatsColumn('Reward Points', '360'),
          const SizedBox(width: 30),
          _buildStatsColumn('Travel Trips', '238'),
          const SizedBox(width: 30),
          _buildStatsColumn('Bucket Lists', '473'),
        ],
      ),
    );
  }

  Widget _buildStatsColumn(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFFF7029),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
