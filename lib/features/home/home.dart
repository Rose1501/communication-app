import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  String userName = "مستخدم";
  String userRole = "طالب";
  String userAvatar = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['Name'] ?? "مستخدم";
          userRole = userDoc['Role'] ?? "طالب";
          userAvatar = userDoc['url_img'] ?? "";
        });
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة المستخدم
            _buildUserCard(),
            const SizedBox(height: 24),
            
            // العنوان الرئيسي
            const Text(
              'الخدمات المتاحة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 16),
            
            // شبكة الخدمات
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildServiceCard(
                    icon: Icons.school,
                    title: 'الكورسات',
                    color: Colors.blue,
                    onTap: () {},
                  ),
                  _buildServiceCard(
                    icon: Icons.assignment,
                    title: 'الواجبات',
                    color: Colors.green,
                    onTap: () {},
                  ),
                  _buildServiceCard(
                    icon: Icons.quiz,
                    title: 'الاختبارات',
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  _buildServiceCard(
                    icon: Icons.calendar_today,
                    title: 'الجدول',
                    color: Colors.purple,
                    onTap: () {},
                  ),
                  _buildServiceCard(
                    icon: Icons.groups,
                    title: 'المجموعات',
                    color: Colors.red,
                    onTap: () {},
                  ),
                  _buildServiceCard(
                    icon: Icons.settings,
                    title: 'الإعدادات',
                    color: Colors.teal,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة المستخدم
  Widget _buildUserCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // صورة المستخدم
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              backgroundImage: userAvatar.isNotEmpty 
                  ? NetworkImage(userAvatar) as ImageProvider
                  : const AssetImage('assets/default_avatar.png'),
              child: userAvatar.isEmpty
                  ? const Icon(Icons.person, size: 30, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            
            // معلومات المستخدم
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userRole,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'لا يوجد بريد إلكتروني',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة الخدمة
  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}