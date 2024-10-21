import "package:flutter/material.dart";

class Document {
  Document({required this.name,}): createdAt = DateTime.now();

  String name;
  final DateTime createdAt;
  //final User owner;
  //final DateTime modifiedAt;

}
