import "package:avert/core/core.dart";

class Dashboard extends StatelessWidget {
  const Dashboard({super.key,
    required this.module,
  });

  final Module module;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          headerContent(context),
          Container(
            padding: EdgeInsets.all(8),
            child: module.dashboardBody(),
          ),
        ]
      ),
    );
  }

  Widget headerContent(BuildContext context) {
    return  Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: [
        Container(
          width: MediaQuery.sizeOf(context).width,
          height: 300,
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: module.dashboardHeader(),
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
