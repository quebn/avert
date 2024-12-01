import "package:avert/accounting/documents/financial_year/document.dart";
import "package:sqflite/sqflite.dart";

void tablesInitAccounting(Batch batch) {
  List<String> queries = [
  ];
  queries.addAll(FinancialYear.getTableQueries());

  for (String query in queries) {
    batch.execute(query);
  }
}
