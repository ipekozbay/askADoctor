import 'package:doktora_sor/screens/hasta/drawer_screen.dart';
import 'package:flutter/material.dart';

class FavoriDoktotlar extends StatefulWidget {
  const FavoriDoktotlar({Key? key}) : super(key: key);

  static String favoriDoktorlarRoute = 'favoriDoktorlarRoute';

  @override
  _FavoriDoktotlarState createState() => _FavoriDoktotlarState();
}

class _FavoriDoktotlarState extends State<FavoriDoktotlar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favori Doktorlar'),
        centerTitle: true,
      ),
      drawer: const Drawer(
        child: HastaDrawerScreen(),
      ),
      body: const Center(
        child: Text('Favori doktor yoktur'),
      ),
    );
  }
}
