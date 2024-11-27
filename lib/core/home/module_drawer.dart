import "package:avert/core/core.dart";

class HomeModuleDrawer extends StatefulWidget {
  const HomeModuleDrawer({super.key,
    required this.moduleNames,
  });

  final List<String> moduleNames;

  @override
  State<StatefulWidget> createState() => _ModuleDrawerState();
}

class _ModuleDrawerState extends State<HomeModuleDrawer> {
  // TODO: have a variable that will update the users picture if changed.
  List<Widget> drawerTiles = [
    const Divider(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building Home Module Drawer!");
    return Drawer(
      width: 250,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.viewPaddingOf(context).top),
        child: Column(
          children: drawerTiles
        )
      )
    );
  }
}

