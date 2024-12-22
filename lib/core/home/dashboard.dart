import "package:avert/core/core.dart";
import "package:forui/forui.dart";

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
    return Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: [
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: 300,
          child: FCard.raw(
            child: module.dashboardHeader(context),
          ),
        ),
      ],
    );
  }
}
