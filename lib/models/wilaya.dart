class Wilaya {
  final int id;
  final String code;
  final String nameFr;
  final String nameEn;

  Wilaya({
    required this.id,
    required this.code,
    required this.nameFr,
    required this.nameEn,
  });
}

class Commune {
  final int id;
  final String nameFr;
  final String nameAr;
  final int postalCode;

  Commune({
    required this.id,
    required this.nameFr,
    required this.nameAr,
    required this.postalCode,
  });
}
