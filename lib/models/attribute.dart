class Attribute {
  int? id;
  String? name;
  String? icon;

  Attribute({this.id, this.name, this.icon});

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
}