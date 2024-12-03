import "package:avert/core/core.dart";

class AccountingDashboardHeader extends StatefulWidget {
  const AccountingDashboardHeader({super.key,
    required this.company,
  });

  final Company company;

  @override
  State<StatefulWidget> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<AccountingDashboardHeader> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}

