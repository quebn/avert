import "package:avert/accounting/documents/account/document.dart";
import "package:avert/core/core.dart";

void createAccountingTables(Batch batch) {
  List<String> queries = [
    Account.tableQuery
  ];

  for (String query in queries) {
    batch.execute(query);
  }
}

//Future<List<Account>> fetchAccounts(Profile profile, {Database? database, List<String>? columns}) async {
//  List<Map<String, Object?>> values = await (database ?? Core.database!).query(Account.tableName,
//    columns: [],
//  );
//
//  List<Account> list = [];
//  throw UnimplementedError();
//
//  //if (values.isNotEmpty) {
//  //  for (Map<String, Object?> v in values) {
//  //    list.add(Account.map(
//  //      id: v["id"]!,
//  //      name: v["name"]!,
//  //      createdAt: v["createdAt"]!,
//  //    ));
//  //  }
//  //}
//
//  //return list;
//}
