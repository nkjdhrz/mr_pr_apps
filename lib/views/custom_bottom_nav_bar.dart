import 'package:flutter/material.dart';
import 'package:my_pr/views/home_page.dart';
import 'package:my_pr/views/draft_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabTapped;

  CustomBottomNavBar({
    required this.selectedIndex,
    required this.onTabTapped,
  });

  void _onTabTapped(BuildContext context, int index) {
    onTabTapped(index);  // update the selected index
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DraftPage()),
        );
        break;
      // ... handle other indices
    }
  }

  Widget buildTabIcon({required IconData icon, required int index, required BuildContext context}) {
    return IconButton(
      icon: Icon(
        icon,
        size: 25.0,
        color: selectedIndex == index
            ? const Color.fromRGBO(91, 103, 202, 1)
            : const Color.fromRGBO(198, 206, 221, 1),
      ),
      onPressed: () => _onTabTapped(context, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Padding(
        padding: const EdgeInsets.all(9.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildTabIcon(icon: Icons.home, index: 0, context: context),
            buildTabIcon(icon: Icons.notifications, index: 2, context: context),
            SizedBox(width: 20.0),
            SizedBox(width: 50.0),  // To account for the floating action button
            SizedBox(width: 20.0),
            buildTabIcon(icon: Icons.description, index: 3, context: context),
            buildTabIcon(icon: Icons.person, index: 1, context: context),
          ],
        ),
      ),
    );
  }
}
