import 'package:flutter/material.dart';

extension NavigatorExtension on BuildContext {
///pushNamed(): تنتقل لصفحة جديدة مع بقاء الصفحة الحالية في المكدس
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }
///pushReplacementNamed(): تستبدل الصفحة الحالية بصفحة جديدة
  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    return Navigator.of(
      this,
    ).pushReplacementNamed(routeName, arguments: arguments);
  }
///pushAndRemoveUntil(): تنتقل لصفحة جديدة بعد مسح كل الصفحات السابقة
  Future<dynamic> pushAndRemoveUntil(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }
}
