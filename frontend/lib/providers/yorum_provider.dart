import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/yorum.dart';

class YorumProvider extends ChangeNotifier {
  List<Yorum> yorumlar = [];

  Future<void> yorumEkle(Yorum yorumBilgileri) async {
    try {
      final url = Uri.parse(
          'http://10.0.2.2:8080/api/yorumlar/yorumEkle'); // 10.0.2.2 for android emulator
      final response = await http.post(
        url,
        body: json.encode({
          'gonderenKullaniciAdi': yorumBilgileri.gonderenKullaniciAdi,
          'gonderenEmail': yorumBilgileri.gonderenEmail,
          'alici': yorumBilgileri.alici,
          'icerik': yorumBilgileri.icerik,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      //print(json.decode(response.body));

      Map<String, dynamic>? yorumData =
          (json.decode(response.body) as Map<String, dynamic>) != null
              ? json.decode(response.body) as Map<String, dynamic>
              : null;
      if (yorumData == null) {
        return;
      }

      yorumlar.add(Yorum(
        alici: yorumData['alici'],
        gonderenKullaniciAdi: yorumData['gonderenKullaniciAdi'],
        gonderenEmail: yorumData['gonderenEmail'],
        icerik: yorumData['icerik'],
      ));
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> fetch_yorumlar(String alici) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/yorumlar/$alici');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );


      List<dynamic> yorumlarData;
      if (response.body.isNotEmpty) {
        yorumlarData = json.decode(response.body) as List<dynamic>;
        yorumlar.clear();
        Yorum yorum;
        for (int i = 0; i < yorumlarData.length; i++) {
          yorum = Yorum(
            gonderenKullaniciAdi: yorumlarData[i]['gonderenKullaniciAdi'] as String,
            gonderenEmail: yorumlarData[i]['gonderenEmail'] as String,
            alici: yorumlarData[i]['alici'] as String,
            icerik: yorumlarData[i]['icerik'] as String,
          );
          yorumlar.add(yorum);
        }
        notifyListeners();
      }
    } catch (_) {
      rethrow;
    }
  }
}
