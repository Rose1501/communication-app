
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// هذه القائمة تحدد المفوضيات المسؤولة عن تحميل وتوفير الموارد المحلية
/// للتطبيق لدعم الترجمة والتوطين.
/// [GlobalMaterialLocalizations.delegate]: يوترجم عناصر واجهة Material Design
/// [GlobalWidgetsLocalizations.delegate]: يوفر اتجاه النص (RTL/LTR) للويدجات
/// [GlobalCupertinoLocalizations.delegate]: يترجم عناصر واجهة iOS (Cupertino)
const List<LocalizationsDelegate> localizationDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
/// Locale('ar'): تدعم اللغة العربية مع اتجاه النص من اليمين لليسار (RTL)
const List<Locale> supportedLocales = [
  Locale('ar'),
];
/// توفر مسارات ثابتة للملفات المختلفة في مجلد assets
class Assets {
  static const String images = 'assets/images/';
  static const String icons = 'assets/icons/';
  static const String animation = 'assets/animation/';
}
