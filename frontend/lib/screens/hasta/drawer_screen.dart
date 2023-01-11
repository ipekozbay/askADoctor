import '../../providers/auth.dart';
import '../../providers/hasta_user.dart';
import '../hasta/profil_duzenleme_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'favori_doktorlar_screen.dart';

class HastaDrawerScreen extends StatelessWidget {
  const HastaDrawerScreen({Key? key}) : super(key: key);

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
                Consumer<HastaUser>(
                  builder: (context,hasta,_) => Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      hasta.kullaniciAdi,
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
            Icons.home_filled,
            color: Colors.blue,
          ),
          title: const Text('Ana sayfa'),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context)
                .pushNamed(HastaProfilDuzenleme.HastaProfilDuzenlemeRoute);
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
            Navigator.of(context)
                .pushNamed(FavoriDoktotlar.favoriDoktorlarRoute);
          },
          leading: const Icon(
            Icons.favorite,
            color: Colors.blue,
          ),
          title: const Text('Favori doktorlar'),
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
