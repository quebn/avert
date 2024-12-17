import "package:avert/accounting/accounting.dart";
import "package:avert/core/core.dart";
import "package:forui/forui.dart";

class HomeModuleDrawer extends StatelessWidget {
  const HomeModuleDrawer({super.key,
    required this.currentModule,
    required this.onModuleSelect,
  });


  final List<Module> modules = const [
    Accounting(),
  ];
  final Module currentModule;
  final void Function(Module selected) onModuleSelect;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: drawerWidgets(context),
        )
      )
    );
  }

  List<Widget> drawerWidgets(BuildContext context) {
    final List<Widget> widgets = [
      const FDivider(),
      Padding(
        padding: EdgeInsets.only(left: 8, bottom: 8),
        child: Text("Modules",
          style: context.theme.typography.lg,
        ),
      ),
    ];
    if (modules.isEmpty) return widgets;
    for (final Module module in modules) {
      widgets.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: FButton(
            style: module == currentModule ? FButtonStyle.primary : FButtonStyle.ghost,
            onPress: () {},//module.drawerSelect,
            label: Text(module.name),
            prefix: module.icon,
          )
        ),
      );
    }
    return widgets;
  }
}

