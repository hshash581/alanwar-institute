import 'package:flutter/material.dart';
import 'package:al_anwar_institute/core/constants/app_colors.dart';

class RoleScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> bottomNavItems;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const RoleScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentIndex,
    required this.onTap,
    required this.bottomNavItems,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primary,
          centerTitle: true,
          actions: actions,
        ),
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: bottomNavItems,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
