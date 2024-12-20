import "package:avert/accounting/documents/account/default.dart";
import "package:avert/core/core.dart";
import "package:forui/forui.dart";

import "documents/account/document.dart";

class Accounting implements Module {
  const Accounting();

  @override
  Widget get icon => FIcon(FAssets.icons.handCoins);

  @override
  String get name => "Accounting";

  final Map<String, List<Account>> chartOfAccounts = const {
    "Assets": [],
    "Liabilities": [],
    "Equity": [],
    "Income": [],
    "Expenses": [],
  };

  @override
  Widget dashboardHeader(BuildContext context) {
    return FCard.raw(
      child: const Text("Accounting",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget dashboardBody() {
    return SizedBox();
  }

  @override
  Widget documents() {
    // TODO: implement viewDocuments
    throw UnimplementedError();
  }

  @override
  Widget reports() {
    // TODO: implement viewReport
    throw UnimplementedError();
  }

  @override
  Widget settings() {
    // TODO: implement viewSettings
    throw UnimplementedError();
  }

  void createDefaultCOA(Company company) {
    chartOfAccounts["Assets"]       = createAssets(company);
    chartOfAccounts["Liabilities"]  = createLiabilities(company);
    chartOfAccounts["Equity"]       = createEquity(company);
    chartOfAccounts["Income"]       = createIncome(company);
    chartOfAccounts["Expenses"]     = createExpenses(company);
  }

  //List<Account> createRootAccounts(Company company) {
  //  return [
  //    Account.asset(
  //      id: 100,
  //      company: company,
  //      name: "Assets",
  //    ),
  //    Account.liability(
  //      id: 200,
  //      company: company,
  //      name: "Liabilities",
  //    ),
  //    Account.asset(
  //      id: 300,
  //      company: company,
  //      name: "Owner's Equity",
  //    ),
  //    Account.asset(
  //      id: 400,
  //      company: company,
  //      name: "Revenue",
  //    ),
  //    Account.asset(
  //      id: 500,
  //      company: company,
  //      name: "Expenses",
  //    ),
  //  ];
  //}
}
