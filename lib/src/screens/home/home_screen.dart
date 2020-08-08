import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/core/controller/home_controller.dart';
import 'package:group_chat/src/screens/home/profile_page.dart';

class HomeScreen extends StatelessWidget {
  static const route_name = "home_screen";
  final pages = [
    Container(),
    Container(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
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
