import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/core/controller/home_controller.dart';
import 'package:group_chat/src/screens/home/all_group_lists.dart';
import 'package:group_chat/src/screens/home/home_page.dart';
import 'package:group_chat/src/screens/home/profile/profile_page.dart';
import 'package:group_chat/src/screens/home/search_page.dart';

class HomeScreen extends StatelessWidget {
  static const route_name = "home_screen";
  final HomeController _homeController = Get.put(HomeController());
  final pages = [
    HomePage(),
    SearchPage(),
    AllGroupLists(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: _homeController,
      builder: (_) {
        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.black,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              _.updateCurrentIndex(index);
            },
            currentIndex: _.currentIndex,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                ),
                title: Text(
                  "Home",
                  style: GoogleFonts.asap(),
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                ),
                title: Text(
                  "Search",
                  style: GoogleFonts.asap(),
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.group,
                ),
                title: Text(
                  "Groups",
                  style: GoogleFonts.asap(),
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                ),
                title: Text(
                  "Person",
                  style: GoogleFonts.asap(),
                ),
              ),
            ],
          ),
          body: pages[_.currentIndex],
        );
      },
    );
  }
}
