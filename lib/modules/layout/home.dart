import 'package:flutter/material.dart';
import 'package:project_bander/modules/layout/tabs/home_tab.dart';
import 'package:project_bander/modules/layout/tabs/notiflcations_tab.dart';
import 'package:project_bander/modules/layout/tabs/profile_tab.dart';
import 'package:project_bander/modules/layout/tabs/subscriptions_tab.dart';
import 'package:project_bander/modules/layout/tabs/tickts_tab.dart';
import 'package:svg_flutter/svg.dart';
import '../../core/theme/app_color.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  static const route = "home";

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  bool _isFirstRun = true;

  List<Widget> tabs = const [
    ProfileTab(),
    NotiflcationsTab(),
    SubscriptionsTab(),
    TicktsTab(),
    HomeTab(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isFirstRun) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        currentIndex = args;
      }
      _isFirstRun = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColor.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            print(index);
          });
        },
        unselectedItemColor: AppColor.white,
        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
        ),
        showUnselectedLabels: true,
        fixedColor: AppColor.white,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/images/icon_img/vector_open.svg"),
            activeIcon: SvgPicture.asset("assets/images/icon_img/Vector.svg"),
            label: "الملف الشخصي",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/icon_img/notifications-outline.svg",
            ),
            activeIcon: SvgPicture.asset(
              "assets/images/icon_img/notification-fill.svg",
            ),
            label: "الاشعارات",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/icon_img/subscriptions-outline.svg",
            ),
            activeIcon: SvgPicture.asset(
              "assets/images/icon_img/subscriptions.svg",
            ),
            label: "الاشتراكات",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/images/icon_img/ticket_opne.svg"),
            activeIcon: SvgPicture.asset("assets/images/icon_img/ticket.svg"),
            label: "تذاكري",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/images/icon_img/home-outline.svg"),
            activeIcon: SvgPicture.asset("assets/images/icon_img/home.svg"),
            label: "الرئيسية",
          ),
        ],
      ),

      body: tabs[currentIndex],
    );
  }
}