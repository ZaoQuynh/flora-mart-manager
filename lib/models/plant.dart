import 'package:flora_manager/models/attribute.dart';
import 'package:flora_manager/models/description.dart';

class Plant {
  int? id;
  String? name;
  List<Description> descriptions;
  List<Attribute> attributes;
  String? img;

  Plant({
    this.id,
    this.name,
    this.descriptions = const [],
    this.attributes = const [],
    this.img,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    List<Description> descriptionsList = [];
    if (json['descriptions'] != null) {
      descriptionsList = List<Description>.from(
          json['descriptions'].map((x) => Description.fromJson(x)));
    }

    List<Attribute> attributesList = [];
    if (json['attributes'] != null) {
      attributesList = List<Attribute>.from(
          json['attributes'].map((x) => Attribute.fromJson(x)));
    }

    return Plant(
      id: json['id'],
      name: json['name'],
      descriptions: descriptionsList,
      attributes: attributesList,
      img: json['img'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'descriptions': descriptions.map((e) => e.toJson()).toList(),
      'attributes': attributes.map((e) => e.toJson()).toList(),
      'img': img,
    };
  }
}