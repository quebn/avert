import "package:sqflite/sqflite.dart";

void createAccountingTables(Batch batch) {
  List<String> queries = [
  ];

  for (String query in queries) {
    batch.execute(query);
  }
}
