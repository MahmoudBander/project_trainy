import 'package:flutter/material.dart';
import 'package:project_bander/features/auth/presention/pages/login_screen.dart';
import '../layout/home.dart';

class OnboardingScreen extends StatefulWidget {
  static const route = "Onboarding";

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // قائمة محتويات صفحات الترحيب
  final List<Map<String, String>> _screens = [
    {
      "title": "ابحث واحجز رحلتك",
      "desc": "اعثر بسهولة على أفضل مسارات القطارات والأسعار لمغامراتك القادمة",
      "image": "assets/images/onboarding_img/Rectangle 2.png",
    },
    {
      "title": "اختر مقعدك",
      "desc": "اختر مكانك المثالي. استمتع بإطلالة من النافذة أو بمساحة إضافية للساقين لرحلة أكثر راحة",
      "image": "assets/images/onboarding_img/Rectangle 2 (1).png",
    },
    {
      "title": "ادفع بأمان وسافر براحة",
      "desc": "احجز رحلتك بثقة باستخدام نظام الدفع المشفر الخاص بنا",
      "image": "assets/images/onboarding_img/Rectangle 2 (2).png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // الهوية البصرية (اللوجو)
            Positioned(
                top: 30,
                left: 0,
                right: 0,
                child: Image.asset("assets/images/email_img/Frame 48.png",width: 60,)

            ),

            // زر التخطي (يظهر في أول صفحتين فقط)
// زر التخطي (يظهر في الصفحة الثانية والثالثة فقط)
            if (_currentIndex > 0)
              Positioned(
                top: 5,
                left: 5,
                child: TextButton(
                  onPressed: () {
                    // الانتقال لآخر صفحة مباشرة (Index 2)
                    _pageController.animateToPage(
                        2,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut
                    );
                  },
                  child: const Text(
                    "تخطي",
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // عرض الصفحات الرئيسي
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: _screens.length,
                itemBuilder: (context, index) {
                  return SingleChildScrollView( // لتجنب مشاكل المساحة في الشاشات الصغيرة
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // عرض الصورة بتنسيق منحني مع ظل
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 25),
                          height: MediaQuery.of(context).size.height * 0.42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              _screens[index]["image"]!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        // نصوص العناوين والوصف
                        Text(
                          _screens[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            _screens[index]["desc"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              color: Colors.grey,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // التحكم السفلي (مؤشر الصفحات والزر)
            Positioned(
              bottom: 40,
              left: 25,
              right: 25,
              child: Column(
                children: [
                  // مؤشر النقاط (Indicator)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_screens.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 24 : 10, // عرض تفاعلي للنقطة النشطة
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _currentIndex == index
                              ? const Color(0xFFF8FC0F)
                              : Colors.grey.shade300,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 35),
                  // زر المتابعة
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(59),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        if (_currentIndex < 2) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else {
                         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>LoginScreen() ));
                        }
                      },
                      child: Text(
                        _currentIndex == 2 ? "ابدأ الآن" : "التالي",
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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