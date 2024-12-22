import "package:avert/core/core.dart";

void createCoreTables(Batch batch) {
  List<String> queries = [
    Profile.tableQuery,
    // Task.getTableQuery() // NOTE: Not planned.
  ];

  for (String query in queries) {
    batch.execute(query);
  }
}
