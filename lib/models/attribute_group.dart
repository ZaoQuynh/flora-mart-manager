import 'package:flora_manager/models/attribute.dart';

class AttributeGroupDTO {
  final int? id;
  final String? name;
  final String? icon;
  final List<Attribute> attributes;

  AttributeGroupDTO({
    this.id,
    this.name,
    this.icon,
    this.attributes = const [],
  });

  factory AttributeGroupDTO.fromJson(Map<String, dynamic> json) {
    return AttributeGroupDTO(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((e) => Attribute.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'attributes': attributes.map((e) => e.toJson()).toList(),
      };
}