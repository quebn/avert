import "package:avert/core/core.dart";

class HomeModuleDrawer extends StatefulWidget {
  const HomeModuleDrawer({super.key,
    required this.modules,
  });

  final List<Module> modules;

  @override
  State<StatefulWidget> createState() => _ModuleDrawerState();
}

class _ModuleDrawerState extends State<HomeModuleDrawer> {
  // TODO: have a variable that will update the users picture if changed.

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: drawerWidgets,
        )
      )
    );
  }

  List<Widget> get drawerWidgets {
    final List<Widget> widgets = [
      const Divider(),
      const Padding(
        padding: EdgeInsets.only(left: 12, top: 8),
        child: Text("Modules",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
    if (widget.modules.isEmpty) return widgets;
    for (Module module in widget.modules) {
      printInfo(module.name);
      List<Widget> tiles = [
        ListTile(
          leading: Icon(module.iconData),
          title: Text(module.name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          onTap: () {
            printInfo("Pressed Module:${module.name}");
          }
        ),
      ];
      widgets.addAll(tiles);
    }
    return widgets;
  }
}

