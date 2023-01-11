import '../../providers/auth.dart';
import '../../providers/doktor_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'profil_duzenleme_screen.dart';
import 'yorumlar_screen.dart';

class DoktorDrawerScreen extends StatelessWidget {
  const DoktorDrawerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          color: Colors.blue,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    '',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Consumer<DoktorUser>(
                  builder: (context,doktor,_) => Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      doktor.kullaniciAdi,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
          leading: const Icon(
            Icons.email,
            color: Colors.blue,
          ),
          title: const Text('Mesajlar'),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).pushNamed(DoktorProfilDuzenleme.DoktorProfilDuzenlemeRoute);
          },
          leading: const Icon(
            Icons.person,
            color: Colors.blue,
          ),
          title: const Text('Profil düzenleme'),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).pushNamed(Yorumlar.yorumlarRoute);
          },
          leading: const Icon(
            Icons.comment_sharp,
            color: Colors.blue,
          ),
          title: const Text('Yorumlar'),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
          ),
        ),
        const Spacer(),
        ListTile(
          onTap: () {
            Provider.of<Auth>(context, listen: false).logOut(context);
          },
          leading: const Icon(
            Icons.logout,
            color: Colors.blue,
          ),
          title: const Text('Çıkış'),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
