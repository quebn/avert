import "package:avert/core/core.dart";
import "package:forui/forui.dart";

import "documents/account/document.dart";

class Accounting implements Module {
  const Accounting();

  @override
  Widget get icon => FIcon(FAssets.icons.handCoins);

  @override
  String get name => "Accounting";

  @override
  Widget dashboardHeader(BuildContext context) {
    return SizedBox(
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

  List<Account> createLiabilities(Company company) {
    return [
      Account.liability(
        company: company,
        name: "Accounts Payable",
        type: AccountType.payable,
      ),
      Account.liability(
        company: company,
        name: "Input",
        type: AccountType.payable,
      ),
      Account.liability(
        company: company,
        name: "Accounts Payable",
        type: AccountType.payable,
      ),
    ];
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
