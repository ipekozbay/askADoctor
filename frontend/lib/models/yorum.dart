class Yorum {
  String gonderenKullaniciAdi;
  String gonderenEmail;
  String gonderenKullanicininCinsiyeti;
  String alici;
  String icerik;
  DateTime createdAt;


  Yorum({
    required this.gonderenKullaniciAdi,
    required this.gonderenEmail,
    required this.gonderenKullanicininCinsiyeti,
    required this.alici,
    required this.icerik,
    required this.createdAt,

  });
}