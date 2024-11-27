import "package:avert/core/core.dart";

class FiscalYear implements Document {
   FiscalYear({
    this.id = 0,
    this.name = "",
  }):createdAt = DateTime.now() ;

  @override
  DateTime createdAt;

  @override
  int id;

  @override
  String name;


  @override
  Future<bool> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<bool> insert() {
    // TODO: implement insert
    throw UnimplementedError();
  }

  @override
  Future<bool> update() {
    // TODO: implement update
    throw UnimplementedError();
  }
}
