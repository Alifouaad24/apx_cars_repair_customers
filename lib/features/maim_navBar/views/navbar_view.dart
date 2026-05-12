import 'package:apx_cars_repair/features/maim_navBar/controllers/nav_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class MainNavBarView extends StatefulWidget {
  const MainNavBarView({super.key});

  @override
  State<MainNavBarView> createState() => _MainNavBarViewState();
}

class _MainNavBarViewState extends State<MainNavBarView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainNavBarController>(
      builder: (controller) {
        return Scaffold(
          body: controller.items[controller.currentIndex].page,

          bottomNavigationBar: Container(
            margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: NavigationBar(
                height: 70,
                selectedIndex: controller.currentIndex,
                backgroundColor: Colors.white,
                indicatorColor: const Color(0xFF0E7490).withOpacity(0.12),
                onDestinationSelected: (index) {
                  controller.changeIndex(index);
                },
                destinations: controller.items.map((item) {
                  return NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(
                      item.icon,
                      color: const Color(0xFF0E7490),
                    ),
                    label: item.label,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
