import "package:avert/core/core.dart";
import "package:forui/forui.dart";

class HomeModuleDrawer extends StatelessWidget {
  const HomeModuleDrawer({super.key,
    required this.currentModule,
    required this.onModuleSelect,
  });

  final Module currentModule;
  final void Function(bool selected, Module module) onModuleSelect;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = FTheme.of(context);
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
            SizedBox(height: 24),
            FSelectTileGroup<Module>(
              style: theme.tileGroupStyle.copyWith(
                tileStyle: theme.tileGroupStyle.tileStyle.copyWith(
                  focusedBorder: Border.all(style: BorderStyle.none),
                  border: Border.all(style: BorderStyle.none),
                  enabledBackgroundColor: theme.colorScheme.secondary
                ),
              ),
              groupController: FRadioSelectGroupController(value: currentModule),
              divider: FTileDivider.full,
              label: const Text("Modules"),
              children: drawerModuleTiles,
            )
          ]
        )
      )
    );
  }

  List<FSelectTile<Module>> get drawerModuleTiles {
    final List<Module> modules = Core.modules;
    final List<FSelectTile<Module>> items = [];
    if (modules.isEmpty) return items;
    for (final Module m in modules) {
      items.add(
        FSelectTile<Module>.suffix(
          value: m,
          prefixIcon: m.icon,
          title: Text(m.name),
          onFocusChange: (selected) => onModuleSelect(selected, m),
          checkedIcon: SizedBox(),
        ),
      );
    }
    return items;
  }
}

