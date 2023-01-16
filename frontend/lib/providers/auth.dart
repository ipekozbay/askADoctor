import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doktora_sor/models/http_exceptions.dart';
import 'package:doktora_sor/models/hasta.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/doktor.dart';

class Auth extends ChangeNotifier {
  String userEmail = '';
  String kullaniciAdi = '';
  String userGender = '';
  String user = '';

  get isAuth {
    if (userEmail.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<void> hasta_SignUp(String email, String password, Hasta hasta) async {
    try {
      final url = Uri.parse(
          'http://10.0.2.2:8080/api/hastalar/hastaEkle'); // 10.0.2.2 for android emulator
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'ad': hasta.ad,
          'soyad': hasta.soyad,
          'cinsiyet': hasta.cinsiyet,
          'yas': hasta.yas,
          'boy': hasta.boy,
          'kilo': hasta.kilo,
          'kanGrubu': hasta.kanGrubu,
          'kronikHastalik': hasta.kronikHastalik,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      //print(json.decode(response.body));

      Map<String, dynamic>? userData =
          (json.decode(response.body) as Map<String, dynamic>) != null
              ? json.decode(response.body) as Map<String, dynamic>
              : null;
      if (userData == null) {
        return;
      }
      userEmail = userData['email'];
      kullaniciAdi = "${userData['ad']} ${userData['soyad']}";
      userGender = userData['cinsiyet'];
      user = 'Hasta';
      await Firebase.initializeApp().then((_) {
        FirebaseFirestore.instance
            .collection('/UsersProfileImages')
            .doc(userEmail)
            .set({
          'image': '',
          'status': 'online',
        });
        FirebaseMessaging.instance.getToken().then((token) {
          FirebaseFirestore.instance
              .collection('UsersTokens')
              .doc(userEmail)
              .set({'token': token});
        });
      });

      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> doktor_SignUp(
      String email, String password, Doktor doktor) async {
    try {
      final url = Uri.parse(
          'http://10.0.2.2:8080/api/doktorlar/doktorEkle'); // 10.0.2.2 for android emulator
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'ad': doktor.ad,
          'soyad': doktor.soyad,
          'cinsiyet': doktor.cinsiyet,
          'mezuniyetUni': doktor.mezuniyetUni,
          'bilimDali': doktor.bilimDali,
          'uzmanlikAlani': doktor.uzmanlikAlani,
          'hastaneTuru': doktor.hastaneTuru,
          'hastaneAdi': doktor.hastaneAdi,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      //print(json.decode(response.body));

      Map<String, dynamic>? userData =
          (json.decode(response.body) as Map<String, dynamic>) != null
              ? json.decode(response.body) as Map<String, dynamic>
              : null;
      if (userData == null) {
        return;
      }
      userEmail = userData['email'];
      kullaniciAdi = "${userData['ad']} ${userData['soyad']}";
      userGender = userData['cinsiyet'];
      user = 'Doktor';
      await Firebase.initializeApp().then((_) {
        FirebaseFirestore.instance
            .collection('/UsersProfileImages')
            .doc(userEmail)
            .set({
          'image': '',
          'status': 'online',
        });
        FirebaseMessaging.instance.getToken().then((token) {
          FirebaseFirestore.instance
              .collection('UsersTokens')
              .doc(userEmail)
              .set({'token': token});
        });
      });

      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> Login(String email, String password, String apiName) async {
    try {
      final url = Uri.parse(
          'http://10.0.2.2:8080/api/$apiName/$email'); // 10.0.2.2 for android emulator
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.body.isEmpty) {
        throw HttpException(
            'bu hesap bizim sistemizde kayıtlı değildir. Yeni hesap oluşturunuz');
      }
      //print(json.decode(response.body));

      Map<String, dynamic>? userData =
          json.decode(response.body) as Map<String, dynamic>;

      if (password != userData['password']) {
        throw HttpException('Girdiğiniz şifre yanlış. Tekrar deneyiniz');
      }
      userEmail = userData['email'];
      kullaniciAdi = "${userData['ad']} ${userData['soyad']}";
      userGender = userData['cinsiyet'];
      if (apiName == 'hastalar') {
        user = 'Hasta';
      } else {
        user = 'Doktor';
      }
      await Firebase.initializeApp().then((_) {
        FirebaseFirestore.instance
            .collection('/UsersProfileImages')
            .doc(userEmail)
            .update({
          'status': 'online',
        });
        FirebaseMessaging.instance.getToken().then((token) {
          FirebaseFirestore.instance
              .collection('UsersTokens')
              .doc(userEmail)
              .set({'token': token});
        });
      });
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> Check_emailAvailability(String email, String apiName) async {
    try {
      final url = Uri.parse(
          'http://10.0.2.2:8080/api/$apiName/$email'); // 10.0.2.2 for android emulator
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.body.isEmpty) {
        return false;
      }
      return true;
    } catch (_) {
      rethrow;
    }
  }

  void logOut(BuildContext context) async {
    bool Cikis_yap = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emin misiniz?'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            child: const Text('Hayır'),
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
          ),
          TextButton(
            child: const Text('Evet'),
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
          ),
        ],
      ),
    );

    if (!Cikis_yap) {
      return;
    }
    await Firebase.initializeApp().then((_) {
      FirebaseFirestore.instance
          .collection('/UsersProfileImages')
          .doc(userEmail)
          .update({
        'status': 'offline',
      });
    });
    Navigator.of(context).pushReplacementNamed('/');
    userEmail = '';
    notifyListeners();
  }
}
