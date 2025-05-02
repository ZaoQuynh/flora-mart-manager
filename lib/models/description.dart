class Description {
  int? id;
  String? name;

  Description({this.id, this.name});

  factory Description.fromJson(Map<String, dynamic> json) {
    return Description(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}