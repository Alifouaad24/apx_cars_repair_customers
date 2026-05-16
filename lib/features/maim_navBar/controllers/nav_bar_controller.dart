import 'package:apx_cars_repair/features/cases/presentation/pages/addEditCase_view.dart';
import 'package:apx_cars_repair/features/cases/presentation/pages/showCases_view.dart';
import 'package:apx_cars_repair/features/customers/presentation/pages/map_view.dart';
import 'package:apx_cars_repair/features/customers/presentation/pages/showCustomers_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class MainNavBarController extends GetxController {
  int currentIndex = 0;

  bool get fromNavBar => currentIndex == 3;

  final List<MainNavBarItem> items = [
    MainNavBarItem(
      page: const ShowCases(),
      icon: Icons.home_outlined,
      label: 'Cases',
    ),
    MainNavBarItem(
      page: const AddeditCaseView(),
      icon: Icons.add_box_outlined,
      label: 'Add Case',
    ),
    MainNavBarItem(
      page: const ShowCustomers(),
      icon: Icons.people_outline,
      label: 'Customers',
    ),
    MainNavBarItem(
      page: MapPage(),
      icon: Icons.map_outlined,
      label: 'Map',
    ),
  ];

  void changeIndex(int index) {
    currentIndex = index;
    update();
  }
}

class MainNavBarItem {
  final Widget page;
  final IconData icon;
  final String label;

  MainNavBarItem({required this.page, required this.icon, required this.label});
}
