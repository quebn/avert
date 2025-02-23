import "package:avert/accounting/documents/account/default.dart";
import "package:avert/core/core.dart";
import "package:forui/forui.dart";

import "documents/account/document.dart";

class Accounting implements Module {
  @override
  Widget get icon => FIcon(FAssets.icons.handCoins);

  @override
  String get name => "Accounting";

  final List<Account> chartOfAccounts = [];

  bool get isCompleteEmpty {
    return chartOfAccounts.isEmpty;
  }

  @override
  Widget dashboardHeader(BuildContext context) {
    // TODO: check for chart of accounts.
    return SizedBox(
      child: Center(
        child: isCompleteEmpty ? FButton(
          onPress: null,
          label: const Text("Generate Chart of Accounts"),
        ) : null,
      ),
    );
  }

  @override
  Widget dashboardBody(BuildContext context) {
    return SizedBox();
  }

  @override
  List<Widget> documents(BuildContext context, Profile profile) {
    return [
      FTileGroup(
        label: const Text("Master"),
        divider: FTileDivider.full,
        children: [
          FTile(
            onPress: () => Account.listScreen(context, profile),
            title: const Text("Accounts"),
            prefixIcon: FIcon(FAssets.icons.fileChartColumn),
          ),
        ],
      ),
    ];
  }

  @override
  Widget reports(BuildContext context) {
    // TODO: implement viewReport
    throw UnimplementedError();
  }

  @override
  Widget settings(BuildContext context) {
    // TODO: implement viewSettings
    throw UnimplementedError();
  }

  Widget companyTab() {
    return SizedBox(
      child: Column(),
    );
  }

  void createCOA(Profile profile) {
    chartOfAccounts.add(createAssets(profile));
    chartOfAccounts.add(createLiabilities(profile));
    chartOfAccounts.add(createEquity(profile));
    chartOfAccounts.add(createIncome(profile));
    chartOfAccounts.add(createExpenses(profile));
  }
}
