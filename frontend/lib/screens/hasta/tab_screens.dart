import 'package:doktora_sor/screens/hasta/drawer_screen.dart';
import '../messages_screen.dart';
import 'package:flutter/material.dart';

import 'hasta_home_screen.dart';

class TabsScreen extends StatefulWidget {

  @override
  _TabsScreenState createState() => _TabsScreenState();

}

class _TabsScreenState extends State<TabsScreen> {
  List<Map<String, Object>> pages = [];
  int selectedIndex = 0;

  void selectPage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    pages = [
      {
        'page': const HastaHomeScreen(),
        'title': 'Doktor bulunuz',
      },
      {
        'page': const Mesajlar(),
        'title': 'Mesajlar',
      },
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pages[selectedIndex]['title'] as String),
        centerTitle: true,
      ),
      drawer: const Drawer(
        child: HastaDrawerScreen(),
      ),
      body: pages[selectedIndex]['page'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white,
        currentIndex: selectedIndex,
        onTap: selectPage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Keşfet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_sharp),
            label: 'Mesaj kutusu',
          ),
        ],
      ),
    );
  }
}
