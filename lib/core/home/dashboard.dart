import "package:avert/core/core.dart";

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key,
    required this.company,
    required this.module,
  });

  final Company company;
  final Module module;

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<HomeDashboard> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          headerContent(),
          SizedBox(
          ),
        ]
      ),
    );
  }

  Widget headerContent() {
    return  Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: [
        Container(
          padding: EdgeInsets.only(top: kToolbarHeight),
          width: MediaQuery.sizeOf(context).width,
          height: 300,
          color: Colors.black,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: const Text("Dashboard",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            //padding: EdgeInsets.symmetric(top:)
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20)
            ),
          ),
          height: 24,
        )
      ],
    );
  }
}
