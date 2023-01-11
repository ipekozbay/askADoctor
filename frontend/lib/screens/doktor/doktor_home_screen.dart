import 'package:doktora_sor/screens/doktor/dawer_screen.dart';
import 'package:flutter/material.dart';
import '../messages_screen.dart';

class DoktorHomeScreen extends StatefulWidget {
  const DoktorHomeScreen({Key? key}) : super(key: key);

  @override
  _DoktorHomeScreenState createState() => _DoktorHomeScreenState();
}

class _DoktorHomeScreenState extends State<DoktorHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlar'),
        centerTitle: true,
      ),
      drawer: const Drawer(
        child: DoktorDrawerScreen(),
      ),
      body: const Mesajlar(),
    );
  }
}
