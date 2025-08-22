
import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/extension.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/features/splash/view/splash_data.dart';
import 'package:myproject/features/splash/view/widget/page_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late PageController _page;
  int _currentPage = 0;
  bool _isAutoScrolling = true;
  @override
  void initState() {
    super.initState();
    _page = PageController();
    // تحريك الصفحات تلقائياً كل 4 ثواني
    _startAutoScroll();
  }
    void _startAutoScroll() {
      Future.delayed(const Duration(seconds: 4), () {
        if (_isAutoScrolling && mounted) {
          if (_currentPage < SplashData.title.length - 1) {
            _currentPage++;
            _page.animateToPage(
              _currentPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
          _startAutoScroll();
        }
      });
    }

    @override
    void dispose() {
      _isAutoScrolling = false;
      _page.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      var media = MediaQuery.of(context).size;
      return Scaffold(
        body: Container(
          decoration: imageBackground(SplashData.imageBackground),
          child: Column(
            children: [
              SizedBox(
                height: media.height * .70,
                child: PageView.builder(
                  controller: _page,
                  itemCount: SplashData.title.length,
                  itemBuilder: (context, index) {
                    return PageViewScreen(
                      image: SplashData.image[index],
                      title: SplashData.title[index],
                      subtitle: SplashData.subtitle[index],
                    );
                  },
                ),
              ),
              getHeight(20),
              SmoothPageIndicator(
                effect: JumpingDotEffect(
                  dotHeight: 20,
                  dotWidth: 30,
                  spacing: 5,
                  activeDotColor: ColorsApp.primaryColor,
                  dotColor: ColorsApp.greylight,
                  jumpScale: 2,
                ),
                controller: _page,
                count: SplashData.title.length,
              ),
              getHeight(20),
              ButtonApp(textData: SplashData.startNow, onTop: (){ context.pushAndRemoveUntil(Routes.onboarding);},) ,
              
            ],
          ),
        ),
      );
    }
  }

