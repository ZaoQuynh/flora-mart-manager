// lib/models/description_group.dart

class DescriptionDTO {
  final int? id;
  final String? name;

  DescriptionDTO({this.id, this.name});

  factory DescriptionDTO.fromJson(Map<String, dynamic> json) {
    return DescriptionDTO(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class DescriptionGroupDTO {
  final int? id;
  final String? name;
  final String? icon;
  final List<DescriptionDTO> descriptions;

  DescriptionGroupDTO({
    this.id,
    this.name,
    this.icon,
    this.descriptions = const [],
  });

  factory DescriptionGroupDTO.fromJson(Map<String, dynamic> json) {
    return DescriptionGroupDTO(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      descriptions: (json['descriptions'] as List<dynamic>?)
              ?.map((e) => DescriptionDTO.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'descriptions': descriptions.map((e) => e.toJson()).toList(),
      };
}
