import 'package:flutter/material.dart';
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
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.summarize,
            ),
            label: 'Summary'
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.medication,
            ),
            label: 'Medication'
          )
        ],
      )
    );
  }
}