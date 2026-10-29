enum Continent {
  africa('africa', 'África'),
  america('america', 'América'),
  asia('asia', 'Ásia'),
  europe('europe', 'Europa'),
  oceania('oceania', 'Oceania');

  const Continent(this.id, this.label);
  final String id;
  final String label;

  static Continent fromId(String id) =>
      values.firstWhere((continent) => continent.id == id);
}

class Country {
  const Country({
    required this.code,
    required this.name,
    required this.continent,
    required this.easy,
    required this.flag,
  });

  final String code;
  final String name;
  final Continent continent;
  final bool easy;
  final String flag;

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    code: json['code'] as String,
    name: json['name'] as String,
    continent: Continent.fromId(json['continent'] as String),
    easy: json['easy'] as bool,
    flag: json['flag'] as String,
  );
}
