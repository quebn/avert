import "package:avert/core/core.dart";

class HomeDashboard extends StatefulWidget {
  const HomeDashboard(this.company, {super.key});

  final Company company;

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<HomeDashboard> {


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: Text("Dashboard: ${widget.company.name}"),
          ),
        ]
      ),
    );
  }
}
