import "package:avert/core/core.dart";
import "package:shared_preferences/shared_preferences.dart";

class User implements Document {
  User({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  User.fromQuery({
    required Object id,
    required Object name,
    required Object createdAt,
  }): id = id as int, name = name as String, createdAt =  DateTime.fromMillisecondsSinceEpoch(createdAt as int);

  @override
  int id;

  @override
  String name;

  @override
  DateTime createdAt;


  static String getTableQuery() => """
    CREATE TABLE users(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      password TEXT NOT NULL,
      createdAt INTEGER NOT NULL
    )
  """;

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

  void remember() {
    final SharedPreferencesAsync sp = SharedPreferencesAsync();
    sp.setInt("user_id", id);
  }

  void forget() {
    final SharedPreferencesAsync sp = SharedPreferencesAsync();
    sp.remove("user_id");
  }
}

class UserView extends StatefulWidget  {
  const UserView({super.key});

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<UserView> implements DocumentView {

  @override
  Future<void> deleteDocument() {
    // TODO: implement deleteDocument
    throw UnimplementedError();
  }

  @override
  Future<void> popDocument(bool didPop, Object? value) {
    // TODO: implement popDocument
    throw UnimplementedError();
  }

  @override
  void saveDocument() {
    // TODO: implement saveDocument
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
