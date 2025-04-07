enum DocAction {
  none,
  insert,
  update,
  delete,
  invalid,
}

abstract class Document {
  Document({
    required this.id,
    required this.name,
    required this.createdAt,
  }): action = DocAction.none;

  int id;
  String name;
  final DateTime createdAt;
  DocAction action;

  Future<bool> update();
  Future<bool> insert();
  Future<bool> delete();

  @override
  String toString() => name;
}
