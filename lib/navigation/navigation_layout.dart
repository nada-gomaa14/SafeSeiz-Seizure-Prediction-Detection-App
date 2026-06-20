import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/responsive.dart';
import 'package:safeseiz/screens/HomePage.dart';
import 'package:safeseiz/screens/SummaryPage.dart';
import 'package:safeseiz/screens/MedicationPage.dart';


class NavigationLayout extends StatefulWidget {
  const NavigationLayout({super.key});

  @override
  State<NavigationLayout> createState() => _NavigationLayoutState();
}

class _NavigationLayoutState extends State<NavigationLayout> {
  int currentIndex = 0;
  final List<Widget> screens = const[
    HomePage(),
    SummaryPage(),
    MedicationPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          currentIndex = index;
          setState(() {});
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.tertiary,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp * Responsive.scale(context),
          fontWeight: FontWeight.bold
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp * Responsive.scale(context),
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 25.sp * Responsive.scale(context),
            ),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.summarize,
              size: 25.sp * Responsive.scale(context),
            ),
            label: 'Summary'
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.medication,
              size: 25.sp * Responsive.scale(context),
            ),
            label: 'Medication'
          )
        ],
      )
    );
  }
}