import "package:avert/core/core.dart";

enum FinancialYearType {
  calendar,
  fiscal,
}
class FinancialYear implements Document {
  FinancialYear({
    this.id = 0,
    this.name = "",
    int durationInDays = 0,
    this.start,
    this.end,
  }):createdAt = DateTime.now();

  DateTime? start;
  DateTime? end;
  List<Company> companies = [];

  @override
  DateTime createdAt;

  @override
  int id;

  @override
  String name;

  static List<String> getTableQueries() => [
  """ CREATE TABLE financial_years(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    createdAt INTEGER NOT NULL,
    start INTEGER NOT NULL,
    end INTEGER NOT NULL,
    type INTEGER NOT NULL
  )""",
  """ CREATE TABLE financial_year_companies(
    id INTEGER PRIMARY KEY,
    accounting_period INTEGER NOT NULL,
    company INTEGER NOT NULL
  )""",
  ];

  @override
  Future<bool> delete() async {
    int rowsAffected = await Core.database!.delete("accounting_period_companies",
      where: "accounting_period = ?",
      whereArgs: [id],
    );
    printSuccess("Deleted Table rows: $rowsAffected");
    int result =  await Core.database!.delete("accounting_periods",
      where: "id = ?",
      whereArgs: [id],
    );
    return result == id;
  }

  @override
  Future<bool> insert() async {
    if (!isNew(this)) {
      printInfo("Document is should already be in database with id of '$id'");
      return false;
    }
    if (start == null || end == null) {
      printInfo("start date and end date is null!");
      return false;
    }
    printAssert(start != null && end != null, "start and end date are null");
    DateTime now = DateTime.now();
    Map<String, Object?> values = {
      "name": name,
      "createdAt": now.millisecondsSinceEpoch,
      "start": start!.millisecondsSinceEpoch,
      "end": end!.millisecondsSinceEpoch,
    };
    id = await Core.database!.insert("accounting_periods", values);
    printSuccess("company created with id of $id");
    return id != 0;
  }

  @override
  Future<bool> update() async {
    if (valuesNotValid() || isNew(this)) return false;
    Map<String, Object?> values = {
      "name": name,
    };
    printSuccess("update with values of: ${values.toString()} on company with id of: $id!");
    bool success = await Core.database!.update("companies", values,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    return success;
  }

  bool valuesNotValid() {
    return name.isEmpty;
  }
}
