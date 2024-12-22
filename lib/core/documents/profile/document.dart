import "package:avert/core/core.dart";
import "package:shared_preferences/shared_preferences.dart";

class Profile implements Document {
  Profile({
    this.id = 0,
    this.name = "",
    int createdAt = 0,
  }): createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  Profile.map({
    required Object id,
    required Object name,
    required Object createdAt,
  }): this(
    id: id as int,
    name: name as String,
    createdAt: createdAt as int
  );

  @override
  int id;

  @override
  String name;

  @override
  final DateTime createdAt;

  static String get tableName => "profiles";

  static String get tableQuery => """
    CREATE TABLE $tableName(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      createdAt INTEGER NOT NULL
    )
  """;

  Future<bool> valuesNotValid() async {
    bool hasDuplicates = await exists();
    return name.isEmpty || hasDuplicates;
  }

  Future<bool> exists() async {
    List<Map<String, Object?>> values = await Core.database!.query(tableName,
      columns: ["id"],
      where: "name = ?",
      whereArgs: [name],
    );
    return values.isNotEmpty;
  }

  void remember() {
    SharedPreferencesAsync sp = SharedPreferencesAsync();
    sp.setInt("profile_id", id);
  }

  @override
  Future<bool> update() async {
    if (await valuesNotValid() || isNew(this)) return false;
    Map<String, Object?> values = {
      "name": name,
    };
    printWarn("update with values of: ${values.toString()} on profile with id of: $id!");
    int r = await Core.database!.update(tableName, values,
      where: "id = ?",
      whereArgs: [id],
    );
    return r == 1;
  }

  @override
  Future<bool> insert() async {
    if (!isNew(this)) {
      printInfo("Document is already be in database with id of '$id'");
      return false;
    }
    if (await valuesNotValid()) return false;
    int now = DateTime.now().millisecondsSinceEpoch;
    Map<String, Object?> values = {
      "name": name,
      "createdAt": now,
    };
    printWarn("creating profile with values of: ${values.toString()}");
    id = await Core.database!.insert(tableName, values);
    printSuccess("profile created with id of $id");
    return id != 0;
  }

  @override
  Future<bool> delete() async {
    int result =  await Core.database!.delete(tableName,
      where: "id = ?",
      whereArgs: [id],
    );
    return result == id;
  }

  static Future<Profile?> fetchDefault(Database db, SharedPreferencesWithCache sp) async {
    List<Map<String, Object?>> results = await db.query(tableName,
      columns: ["id", "name", "createdAt",]
    );

    if (results.isEmpty) {
      return null;
    }

    printInfo("${results.length} $tableName found with values of: ${results.toString()}");
    int profileID = sp.getInt("profile_id") ?? 0;
    if (profileID == 0) {
      return Profile(
        id: results[0]['id']! as int,
        name: results[0]['name']! as String,
        createdAt: results[0]['createdAt']! as int,
      );
    }

    for (Map<String, Object?> data in results) {
      if (profileID == data['id']) {
        return Profile(
          id: data['id']! as int,
          name: data['name']! as String,
          createdAt: data['createdAt']! as int,
        );
      }
      break;
    }
    return null;
  }
}

abstract class ProfileTabView {
  Widget getProfileTabView(BuildContext context);
}
