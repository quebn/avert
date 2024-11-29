import "package:avert/core/core.dart";

class AccountingPeriod implements Document {
  AccountingPeriod({
    this.id = 0,
    this.name = "",
    required int durationInDays,
    required this.start,
  }):createdAt = DateTime.now(), end = start.add(Duration(days: durationInDays));

  final DateTime start, end;

  @override
  DateTime createdAt;

  @override
  int id;

  @override
  String name;

  static String getTableQuery() => """
    CREATE TABLE accounting_periods(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      createdAt INTEGER NOT NULL,
      start INTEGER NOT NULL,
      end INTEGER NOT NULL,
    )
  """;

  @override
  Future<bool> delete() async {
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
    DateTime now = DateTime.now();
    Map<String, Object?> values = {
      "name": name,
      "createdAt": now.millisecondsSinceEpoch,
      "start": start.millisecondsSinceEpoch,
      "end": end.millisecondsSinceEpoch,
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
    printWarn("update with values of: ${values.toString()} on company with id of: $id!");
    int r = await Core.database!.update("companies", values,
      where: "id = ?",
      whereArgs: [id],
    );
    return r == 1;
  }

  bool valuesNotValid() {
    return name.isEmpty;
  }

}

class CompanyPeriod {
  CompanyPeriod({
    this.id = 0,
    required this.accountingPeriod,
    required this.company,
  });

  int id;
  Company company;
  AccountingPeriod accountingPeriod;

  static String getTableQuery() => """
    CREATE TABLE company_period(
      id INTEGER PRIMARY KEY,
      company INTEGER NOT NULL,
      accounting_period NOT NULL,
    )
  """;

  Future<bool> delete() async {
    int result =  await Core.database!.delete("accounting_period",
      where: "id = ?",
      whereArgs: [id],
    );
    return result == id;
  }

  Future<bool> insert() {
    // TODO: implement insert
    throw UnimplementedError();
  }

  Future<bool> update() {
    // TODO: implement update
    throw UnimplementedError();
  }

}
