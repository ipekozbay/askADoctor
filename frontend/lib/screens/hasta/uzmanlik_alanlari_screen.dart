import 'package:flutter/material.dart';

import 'doktorlar_screen.dart';

class UzmanlikAlanlari extends StatelessWidget {
  static String uzmanlikAlanlariRoute = 'uzmanlikAlanlariRoute';

  @override
  Widget build(BuildContext context) {
    List<String> tumUzmanlikAlanlari =
        ModalRoute.of(context)!.settings.arguments as List<String>;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uzmanlık Alanları'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: tumUzmanlikAlanlari
              .map(
                (uzmanlikAlan) => Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            DoktorlarScreen.DoktorlarScreenRoute,
                            arguments: uzmanlikAlan);
                      },
                      title: Text(
                        uzmanlikAlan,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.lightBlueAccent),
                    ),
                    if (tumUzmanlikAlanlari.last != uzmanlikAlan)
                      const Divider(color: Colors.lightBlueAccent),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
