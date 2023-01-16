import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/hasta.dart';
import 'package:http/http.dart' as http;
import '../models/http_exceptions.dart';


class HastaUser extends ChangeNotifier{
  final String userEmail;
  String kullaniciAdi;
  String cinsiyet;

  HastaUser(this.userEmail, this.kullaniciAdi, this.cinsiyet);

  Hasta hasta = Hasta(
    ad: '',
    soyad: '',
    cinsiyet: '',
    yas: '',
    boy: '',
    kilo: '',
    kanGrubu: '',
    kronikHastalik: '',
  );

  Future<void> ProfilBilgileriniGuncelle(Hasta hasta) async {
    try {
      var url = Uri.parse(
          'http://10.0.2.2:8080/api/hastalar/profilGuncelle/$userEmail'); // 10.0.2.2 for android emulator
      await http.patch(
        url,
        body: json.encode({
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
      await fetch_hasta_bilgileri();
      throw HttpException('Bilgileriniz güncellendi');
    } catch (_) {
      rethrow;
    }
  }

  Future<void> fetch_hasta_bilgileri() async {
    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/hastalar/$userEmail');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      Map<String, dynamic>? userData;
      if (response.body.isNotEmpty) {
        userData = (json.decode(response.body) as Map<String, dynamic>) != null
            ? json.decode(response.body) as Map<String, dynamic>
            : null;
        if (userData == null) {
          return;
        }
        kullaniciAdi = "${userData['ad']} ${userData['soyad']}";
        cinsiyet = userData['cinsiyet'];
        hasta.ad = userData['ad'];
        hasta.soyad = userData['soyad'];
        hasta.yas = userData['yas'];
        hasta.cinsiyet = userData['cinsiyet'];
        hasta.boy = userData['boy'];
        hasta.kilo = userData['kilo'];
        hasta.kanGrubu = userData['kanGrubu'];
        hasta.kronikHastalik = userData['kronikHastalik'];
        notifyListeners();
      }
    } catch (_) {
      rethrow;
    }
  }


  Future<void> get_hasta_bilgileri(String email) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/hastalar/$email');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      Map<String, dynamic>? userData;
      if (response.body.isNotEmpty) {
        userData = (json.decode(response.body) as Map<String, dynamic>) != null
            ? json.decode(response.body) as Map<String, dynamic>
            : null;
        if (userData == null) {
          return;
        }
        hasta.ad = userData['ad'];
        hasta.soyad = userData['soyad'];
        hasta.yas = userData['yas'];
        hasta.cinsiyet = userData['cinsiyet'];
        hasta.boy = userData['boy'];
        hasta.kilo = userData['kilo'];
        hasta.kanGrubu = userData['kanGrubu'];
        hasta.kronikHastalik = userData['kronikHastalik'];
        notifyListeners();
      }
    } catch (_) {
      rethrow;
    }
  }

}