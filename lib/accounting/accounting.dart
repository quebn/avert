import "package:avert/core/core.dart";
import "package:forui/forui.dart";

class Accounting implements Module {
  const Accounting();

  @override
  Widget get icon => FIcon(FAssets.icons.handCoins);

  @override
  String get name => "Accounting";

  // IMPORTANT: implement dashboard stuff.
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

  Widget createFinancialYear(BuildContext context) {
    return Column(
      children: [
        const Text("No Financial Year Found!",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(
          child: TextButton(
            onPressed: null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                Text("Create Financial Year",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ]
            ),
          )
        )
      ]
    );
  }
}
