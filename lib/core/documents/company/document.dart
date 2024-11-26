import "package:avert/core/core.dart";
import "package:shared_preferences/shared_preferences.dart";

class Company implements Document {
  Company({
    this.id = 0,
    this.name = "",
    int createdAt = 0,
  }): createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  @override
  int id;

  @override
  String name;

  @override
  DateTime createdAt;

  static String getTableQuery() => """
    CREATE TABLE companies(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      createdAt INTEGER NOT NULL
    )
  """;

  bool get isNew => id == 0;

  Future<bool> valuesNotValid() async {
    bool hasDuplicates = await checkIfExist();
    return name.isEmpty || hasDuplicates;
  }

  Future<bool> checkIfExist() async {
    List<Map<String, Object?>> values = await Core.database!.query("companies",
      columns: ["id"],
      where: "name = ?",
      whereArgs: [name],
    );
    return values.isNotEmpty;
  }

  void remember() {
    SharedPreferencesAsync sp = SharedPreferencesAsync();
    sp.setInt("company_id", id);
  }

  @override
  Future<bool> update() async {
    if (await valuesNotValid() || isNew) return false;
    Map<String, Object?> values = {
      "name": name,
    };
    printWarn("update with values of: ${values.toString()} on company with id of: $id!");
    int r = await Core.database!.update("companies", values,
      where: "id = ?",
      whereArgs: [id],
    );
    return r == 1;
  }

  @override
  Future<bool> insert() async {
    if (!isNew) {
      printInfo("Document is should already be in database with id of '$id'");
      return false;
    }
    if (await valuesNotValid()) return false;
    int now = DateTime.now().millisecondsSinceEpoch;
    Map<String, Object?> values = {
      "name": name,
      "createdAt": now,
    };
    printWarn("creating company with values of: ${values.toString()}");
    id = await Core.database!.insert("companies", values);
    printWarn("company created with id of $id");
    return id != 0;
  }

  @override
  Future<bool> delete() async {
    int result =  await Core.database!.delete("companies",
      where: "id = ?",
      whereArgs: [id],
    );
    return result == id;
  }

  static Future<Company?> fetchDefault(Database db, SharedPreferencesWithCache sp) async {
    List<Map<String, Object?>> results = await db.query("companies",
      columns: ["id", "name", "createdAt",]
    );

    if (results.isEmpty) {
      return null;
    }

    printInfo("${results.length} companies found with values of: ${results.toString()}");
    int companyID = sp.getInt("company_id") ?? 0;
    if (companyID == 0) {
      return Company(
        id: results[0]['id']! as int,
        name: results[0]['name']! as String,
        createdAt: results[0]['createdAt']! as int,
      );
    }

    for (Map<String, Object?> data in results) {
      if (companyID == data['id']) {
        return Company(
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

