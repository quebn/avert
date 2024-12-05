import "package:avert/core/core.dart";

class Accounting implements Module {
  const Accounting(this.company);

  @override
  final Company company;

  @override
  IconData get iconData => Icons.account_balance;

  @override
  String get name => "Accounting";

  @override
  Widget dashboardHeader() {
    return SizedBox(
      child: Text(name,
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
}
