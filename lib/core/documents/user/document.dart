import "package:avert/core/core.dart";
import "package:crypto/crypto.dart";
import "package:shared_preferences/shared_preferences.dart";

class User implements Document {
  User({
    this.id = 0,
    this.name = "",
    int createdAt = 0,
  }): createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  User.fromQuery({
    required Object id,
    required Object name,
    required Object createdAt,
  }):
    id = id as int,
    name = name as String,
    createdAt =  DateTime.fromMillisecondsSinceEpoch(createdAt as int)
  ;


  @override
  int id;

  @override
  String name;

  @override
  DateTime createdAt;

  String _password = "";
  bool get isAdmin => id == 1;

  set password(Digest value) => _password = value.toString();

  static String getTableQuery() => """
    CREATE TABLE users(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      password TEXT NOT NULL,
      createdAt INTEGER NOT NULL
    )
  """;

  Future<bool> valuesNotValid() async {
    List<Map<String, Object?>> values = await Core.database!.query("users",
      columns: ["id"],
      where: "name = ?",
      whereArgs: [name],
    );
    return name.isEmpty || values.isNotEmpty;
  }

  Future<bool> nameExist() async {
    List<Map<String, Object?>> results = await Core.database!.query("users",
      where:"name = ?",
      whereArgs: [name],
    );
    return results.isNotEmpty;
  }

  @override
  Future<bool> delete() async {
    int result =  await Core.database!.delete("users",
      where: "id = ?",
      whereArgs: [id],
    );
    return result == id;
  }

  @override
  Future<bool> insert() async {
    if (_password.isEmpty) return false;
    var values = {
      "name"      : name,
      "password"  : _password,
      "createdAt" : DateTime.now().millisecondsSinceEpoch,
    };
    printInfo("Inserting to users table values: ${values.toString()}");
    bool success = await Core.database!.insert("users", values) > 0 ;
    if (success) _password = "";
    return success;
  }

  @override
  Future<bool> update() async {
    if (await valuesNotValid() ) return false;
    Map<String, Object?> values = {
      "name": name,
    };
    printWarn("update with values of: ${values.toString()} on user with id of: $id!");
    int r = await Core.database!.update("users", values,
      where: "id = ?",
      whereArgs: [id],
    );
    return r == 1;
  }

  // TODO: add some params later for specific checking.
  static Future<bool> checkUsers() async {
    List<Map<String, Object?>> result = await Core.database!.query("users",
      columns: ["id"],
    );
    return result.isNotEmpty;
  }

  void remember() {
    final SharedPreferencesAsync sp = SharedPreferencesAsync();
    sp.setInt("user_id", id);
    printInfo("saving user: '$name's ID in cache with value of:[$id]!");
  }

  void forget() {
    final SharedPreferencesAsync sp = SharedPreferencesAsync();
    sp.remove("user_id");
  }
}

