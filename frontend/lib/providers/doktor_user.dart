import 'dart:convert';
import '../models/doktor.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exceptions.dart';

class DoktorUser extends ChangeNotifier {
  final String userEmail;
  String kullaniciAdi;

  DoktorUser(this.userEmail, this.kullaniciAdi);

  List<Doktor> doktorlar = []; // belirli bir uzmanlik alani icin doktorlarin listesi

  List<Doktor> tumDoktorlar = []; // tum doktorlar icin doktorlarin listesi

  Doktor doktor = Doktor(
    email: '',
    ad: '',
    soyad: '',
    cinsiyet: '',
    mezuniyetUni: '',
    bilimDali: '',
    uzmanlikAlani: '',
    hastaneTuru: '',
    hastaneAdi: '',
  );

  Future<void> ProfilBilgileriniGuncelle(Doktor doktor) async {
    try {
      var url = Uri.parse(
          'http://10.0.2.2:8080/api/doktorlar/profilGuncelle/$userEmail'); // 10.0.2.2 for android emulator
      await http.patch(
        url,
        body: json.encode({
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

      await fetch_doktor_bilgileri();
      throw HttpException('Bilgileriniz güncellendi');
    } catch (_) {
      rethrow;
    }
  }

  Future<void> fetch_doktor_bilgileri() async {
    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/doktorlar/$userEmail');
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
        kullaniciAdi =
            "${userData['ad'] as String} ${userData['soyad'] as String}";
        doktor.ad = userData['ad'] as String;
        doktor.soyad = userData['soyad'] as String;
        doktor.cinsiyet = userData['cinsiyet'] as String;
        doktor.hastaneAdi = userData['hastaneAdi'] as String;
        doktor.mezuniyetUni = userData['mezuniyetUni'] as String;
        doktor.bilimDali = userData['bilimDali'] as String;
        doktor.uzmanlikAlani = userData['uzmanlikAlani'] as String;
        doktor.hastaneTuru = userData['hastaneTuru'] as String;
        notifyListeners();
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<void> GetOneDoctorData(String email) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/doktorlar/$email');
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
        kullaniciAdi =
            "${userData['ad'] as String} ${userData['soyad'] as String}";
        doktor.email = userData['email'] as String;
        doktor.ad = userData['ad'] as String;
        doktor.soyad = userData['soyad'] as String;
        doktor.cinsiyet = userData['cinsiyet'] as String;
        doktor.hastaneAdi = userData['hastaneAdi'] as String;
        doktor.mezuniyetUni = userData['mezuniyetUni'] as String;
        doktor.bilimDali = userData['bilimDali'] as String;
        doktor.uzmanlikAlani = userData['uzmanlikAlani'] as String;
        doktor.hastaneTuru = userData['hastaneTuru'] as String;
        notifyListeners();
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<void> filter_doktors_byUzmanlikAlani(String uzmanlikAlani) async {
    try {
      final url =
          Uri.parse('http://10.0.2.2:8080/api/doktorlar/filter/$uzmanlikAlani');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      List<dynamic> usersData;
      if (response.body.isNotEmpty) {
        usersData = json.decode(response.body) as List<dynamic>;
        doktorlar.clear();
        Doktor doktor;
        for (int i = 0; i < usersData.length; i++) {
          doktor = Doktor(
            email: usersData[i]['email'] as String,
            ad: usersData[i]['ad'] as String,
            soyad: usersData[i]['soyad'] as String,
            cinsiyet: usersData[i]['cinsiyet'] as String,
            mezuniyetUni: usersData[i]['mezuniyetUni'] as String,
            bilimDali: usersData[i]['bilimDali'] as String,
            uzmanlikAlani: usersData[i]['uzmanlikAlani'] as String,
            hastaneTuru: usersData[i]['hastaneTuru'] as String,
            hastaneAdi: usersData[i]['hastaneAdi'] as String,
          );
          doktorlar.add(doktor);
        }
        notifyListeners();
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<void> get_tumDoktorlar() async {
    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/doktorlar/');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      List<dynamic> usersData;
      if (response.body.isNotEmpty) {
        usersData = json.decode(response.body) as List<dynamic>;
        tumDoktorlar.clear();
        Doktor doktor;
        for (int i = 0; i < usersData.length; i++) {
          doktor = Doktor(
            email: usersData[i]['email'] as String,
            ad: usersData[i]['ad'] as String,
            soyad: usersData[i]['soyad'] as String,
            cinsiyet: usersData[i]['cinsiyet'] as String,
            mezuniyetUni: usersData[i]['mezuniyetUni'] as String,
            bilimDali: usersData[i]['bilimDali'] as String,
            uzmanlikAlani: usersData[i]['uzmanlikAlani'] as String,
            hastaneTuru: usersData[i]['hastaneTuru'] as String,
            hastaneAdi: usersData[i]['hastaneAdi'] as String,
          );
          tumDoktorlar.add(doktor);
        }
        notifyListeners();
      }
    } catch (_) {
      rethrow;
    }
  }
}
