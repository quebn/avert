import "package:avert/accounting/documents/account/default.dart";
import "package:avert/core/core.dart";
import "package:forui/forui.dart";

import "documents/account/document.dart";

// IMPORTANT: TODO for accounting module.
// - create a company tab view. for create accounting master documents related to company.
// - create dashboard number cards for accounting dashboard heading.
class Accounting implements Module, CompanyTabView {
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
    return SizedBox(
      child: Center(),
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

  Widget companyTab() {
    return SizedBox(
      child: Column(),
    );
  }

  void createDefaultCOA(Company company) {
    chartOfAccounts["Assets"]       = createAssets(company);
    chartOfAccounts["Liabilities"]  = createLiabilities(company);
    chartOfAccounts["Equity"]       = createEquity(company);
    chartOfAccounts["Income"]       = createIncome(company);
    chartOfAccounts["Expenses"]     = createExpenses(company);
  }

  @override
  Widget getCompanyTabView(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Hello from Accounting Module"),
        ],
      ),
    );
  }
}
