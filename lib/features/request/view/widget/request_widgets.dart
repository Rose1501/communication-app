import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/features/home/view/home_data.dart';
import 'package:myproject/features/request/view/widget/request_utils.dart';
import 'package:user_repository/user_repository.dart';

class RequestWidgets {
  // 🔥 بطاقة معلومات الطالب
  static Widget buildStudentInfoCard(UserModels user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildUserAvatar(user),
              getWidth(10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  getHeight(5),
                  Text(
                    'رقم القيد: ${user.userID}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 بطاقة الطلب الفردي
  static Widget buildRequestCard({
    required dynamic request,
    required VoidCallback onDelete,
    required bool showDelete,
  }) {
  print('🎴 بناء بطاقة الطلب: ${request.id}');
  print('   - حالة الحذف: ${showDelete ? "مفعل" : "غير مفعل"}');
  print('   - حالة الطلب: ${request.status}');
  final hasAdminReply = request.adminReply != null && request.adminReply!.isNotEmpty;
    return Card(
      key: ValueKey(request.id),
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // نوع الطلب وحالته في نفس السطر
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // حالة الطلب مع اللون
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: RequestUtils.getStatusColor(request.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: RequestUtils.getStatusColor(request.status),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        RequestUtils.getStatusIcon(request.status),
                        size: 16,
                        color: RequestUtils.getStatusColor(request.status),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        request.status,
                        style: TextStyle(
                          color: RequestUtils.getStatusColor(request.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // نوع الطلب
                Text(
                  request.requestType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            getHeight(10),
            // وصف الطلب
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                request.description,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            getHeight(10),
            // 🔥 قسم رد الإدمن (إذا وجد)
            if (hasAdminReply) ...[
              _buildAdminReplySection(request),
              getHeight(10),
            ],
            // توقيت الطلب 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      RequestUtils.formatDate(request.dateTime),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  ],
                ),
                if (showDelete && request.isWaiting)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 بناء قسم رد الإدمن
  static Widget _buildAdminReplySection(dynamic request) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان رد الإدمن
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                color: Colors.blue[700],
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'رد الإدارة:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // نص رد الإدمن
          Text(
            request.adminReply!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  // 🔥 صورة المستخدم
  static Widget _buildUserAvatar(UserModels user) {
    return Builder(
      builder: (context) => Container(
        width: MediaQuery.of(context).size.height * 0.08, 
        height: MediaQuery.of(context).size.height * 0.08,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ColorsApp.primaryColor, width: 2),
        ),
        child: _buildProfileImage(user),
      ),
    );
  }

  static Widget _buildProfileImage(UserModels user) {
    // تحقق من وجود صورة Base64
    if (user.urlImg != null && user.urlImg!.isNotEmpty) {
      print('🖼️ تحميل صورة Base64 للمستخدم في PublisherInfoBar: ${user.name}');
      print('📊 طول بيانات الصورة: ${user.urlImg!.length}');
      return _buildBase64Image(user.urlImg!);
      }
    
    // استخدام الصورة الافتراضية
    return _buildDefaultImage(user);
  }

  static Widget _buildBase64Image(String base64Data) {
    print('🔍 فحص بيانات Base64 في PublisherInfoBar:');
    print('📏 الطول: ${base64Data.length}');
    print('🔗 يبدأ بـ: ${base64Data.substring(0, min(50, base64Data.length))}');
    
    try {
      String cleanBase64 = _cleanBase64Data(base64Data);
      print('📊 طول البيانات بعد التنظيف: ${cleanBase64.length}');
      
      // التحقق من أن البيانات صالحة
      if (cleanBase64.length > 100) {
        return ClipOval(
          child: Image.memory(
            base64Decode(cleanBase64),
            width: 24, // أصغر قليلاً من الحاوية
            height: 24,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('❌ خطأ في تحميل صورة Base64 في PublisherInfoBar: $error');
              return _buildDefaultImage(UserModels.empty);
            },
          ),
        );
      } else {
        print('⚠️ بيانات الصورة قصيرة جداً في PublisherInfoBar: ${cleanBase64.length} حرف');
        return _buildDefaultImage(UserModels.empty);
      }
    } catch (e) {
      print('❌ خطأ في معالجة صورة Base64 في PublisherInfoBar: $e');
      return _buildDefaultImage(UserModels.empty);
    }
  }

  static String _cleanBase64Data(String base64Data) {
    // إذا كانت البيانات تحتوي على prefix مثل data:image/jpeg;base64,
    if (base64Data.contains(',')) {
      return base64Data.split(',').last;
    }
    return base64Data;
  }

  static Widget _buildDefaultImage(UserModels user) {
    return CircleAvatar(
      radius: 13,
      backgroundColor: ColorsApp.white,
      backgroundImage: user.gender == "male"|| user.gender  == "Male"
          ? const AssetImage(HomeData.man)
          : const AssetImage(HomeData.woman),
    );
  }

  // 🔥 شاشة لا توجد طلبات
  static Widget buildEmptyRequests() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'لا توجد طلبات',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'انقر على + لإضافة طلب جديد',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 🔥 شاشة خطأ قابلة للسحب
  static Widget buildErrorWidget(String error, VoidCallback onRetry) {
    return Container(
      height: 300, // ارتفاع مناسب للسحب
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 50),
            SizedBox(height: 16),
            Text('حدث خطأ: $error'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
  // 🔥 شاشة لا توجد طلبات قابلة للسحب
  static Widget buildEmptyRequestsDraggable() {
    return Container(
      height: 300, // ارتفاع مناسب للسحب
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 100, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد طلبات',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'انقر على + لإضافة طلب جديد',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              'اسحب لأسفل للتحديث',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}