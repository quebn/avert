import "package:avert/core/core.dart";

class HomeModuleDrawer extends StatelessWidget {
  const HomeModuleDrawer({super.key,
    required this.modules,
    required this.currentIndex,
    required this.onModuleSelect,
  });

  final List<Module> modules;
  final int currentIndex;
  final void Function(int index) onModuleSelect;

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
    if (modules.isEmpty) return widgets;
    for (final (int index, Module module) in modules.indexed) {
      List<Widget> tiles = [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: ListTile(
            selected: modules[currentIndex] == module,
            selectedColor: Colors.white,
            selectedTileColor: Colors.black,
            leading: Icon(module.iconData),
            title: Text(module.name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            onTap: () {
              printInfo("Pressed Module:${module.name} with index of: $index");
            }
          ),
        ),
      ];
      widgets.addAll(tiles);
    }
    return widgets;
  }
}

