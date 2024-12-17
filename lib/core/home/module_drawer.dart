import "package:avert/accounting/accounting.dart";
import "package:avert/core/core.dart";
import "package:forui/forui.dart";

class HomeModuleDrawer extends StatelessWidget {
  const HomeModuleDrawer({super.key,
    required this.currentModule,
    required this.onModuleSelect,
  });

  final Module currentModule;
  final void Function(bool selected, Module module) onModuleSelect;
  final List<Module> modules = const [
    Accounting(),
  ];

  @override
  Widget build(BuildContext context) {
    FThemeData theme = context.theme;
    printTrack("Building Home Module Drawer!");
    return Drawer(
      backgroundColor: theme.colorScheme.background,
      width: 200,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.viewPaddingOf(context).top,
          left: 8,
          right: 8,
        ),
        child: Column(
          children: [
            SizedBox(height: 16),
            FSelectTileGroup<Module>(
              style: theme.tileGroupStyle.copyWith(
                tileStyle: theme.tileGroupStyle.tileStyle.copyWith(
                  border: Border.all(width: 0),
                  enabledBackgroundColor: theme.colorScheme.secondary
                ),
              ),
              controller: FRadioSelectGroupController(value: currentModule),
              divider: FTileDivider.none,
              label: const Text("Modules"),
              children: drawerModuleTiles,
            )
          ]
        )
      )
    );
  }

  List<FSelectTile<Module>> get drawerModuleTiles {
    final List<FSelectTile<Module>> items = [];
    if (modules.isEmpty) return items;
    for (final Module module in modules) {
      items.add(
        FSelectTile<Module>.suffix(
          value: module,
          prefixIcon: module.icon,
          title: Text(module.name),
          onChange: (selected) => onModuleSelect(selected, module),
        ),
      );
    }
    return items;
  }
}

