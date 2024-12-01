import "package:avert/core/core.dart";

void tablesInitCore(Batch batch) {
  List<String> queries = [
    User.getTableQuery(),
    Company.getTableQuery(),
    // Task.getTableQuery() // NOTE: Not planned.
  ];

  for (String query in queries) {
    batch.execute(query);
  }
}
