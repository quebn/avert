import "package:avert/accounting/accounting.dart";
import "package:avert/core/core.dart";
import "package:avert/core/auth/screen.dart";
import "package:avert/core/documents/company/form.dart";
import "package:avert/core/documents/company/view.dart";
import "package:avert/core/home/module_drawer.dart";
import "package:forui/forui.dart";
import "dashboard.dart";
import "profile_drawer.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key,
    required this.title,
    required this.user,
    required this.company,
  });

  final String title;
  final User user;
  final Company? company;

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Module currentModule = const Accounting();
  int currentIndex = 0;
  bool lastStatus = true;

  final double height = 390;

  late Company? company = widget.company;
  late List<Widget> pages = [
    Dashboard(module: currentModule),
    const Center(child: Text("Documents")),
    const Center(child: Text("Reports")),
    const Center(child: Text("Settings")),
  ];

  @override
  Widget build(BuildContext context) {
    if (company == null) {
      Company c = Company();
      return EmptyScreen(
        company: c,
        onCreate: () => setState(() => company = c),
        onUpdate: () => setState(() {}),
      );
    }
    printTrack("Building HomeSceen");
    return mainDisplay(context);
  }

  void onCompanyDelete() {
    setState(() => company = null);
  }

  Widget mainDisplay(BuildContext context) => Scaffold(
    body: FScaffold(
      header: FHeader(
        title: Row(
          children: [
            Builder(
              builder: (BuildContext context) => FButton.icon(
                onPress: () => Scaffold.of(context).openDrawer(),
                style: FButtonStyle.ghost,
                child: FIcon(FAssets.icons.menu,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 16,),
            FButton.raw(
              style: FButtonStyle.ghost,
              onPress: viewCurrentCompany,
              child: Text(company!.name,
                style: context.theme.typography.xl2,
              ),
            ),
          ],
        ),
        actions: [
          FHeaderAction(
            icon: FIcon(FAssets.icons.bell,
              size: 24,
            ),
            onPress: null,
          ),
          Builder(
            builder: (BuildContext context) => FButton.icon(
              style: FButtonStyle.ghost,
              onPress: () => Scaffold.of(context).openEndDrawer(),
              child: FAvatar.raw(
                child: FIcon(FAssets.icons.user),
              ),
            ),
          )
        ],
      ),
      content: pages[currentIndex],
    ),
    endDrawer: HomeProfileDrawer(
      user: widget.user,
      onLogout: () => logout(context),
      onUserDelete: () {
        widget.user.forget();
        Navigator.pop(context);
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => AuthScreen(
              title: "Avert",
            ),
          )
        );
      },
    ),
    drawer: HomeModuleDrawer(
      currentModule: currentModule,
      onModuleSelect: (selected, module) { if (selected) printTrack("Selecting: ${module.name}");},
    ),
  );

  Widget leftDrawer() {
    return const Drawer(
      width: 250,
      //child: Listjk
    );
  }

  void viewCurrentCompany() {
    printInfo("Viewing Current Company!");
    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => CompanyView(
          document: company!,
          onDelete: onCompanyDelete,
          onUpdate: () {
            throw UnimplementedError();
            printError("From Main Display of HomeScreen");
            setState(() {});
          }
        ),
      )
    );
  }

  Future<void> logout(BuildContext context) async {
    bool shouldLogout = await confirmLogout() ?? false;

    if (shouldLogout && context.mounted) {
      widget.user.forget();
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AuthScreen(
            title: "Avert",
            hasUsers: true,
          ),
        )
      );
    }
  }

  Future<bool?> confirmLogout() async {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (BuildContext context) => FDialog(
        direction: Axis.horizontal,
        title: Text("Log out?"),
        body: Text("Are you sure you want to logout user '${widget.user.name}'?"),
        actions: <Widget>[
          FButton(
            label: const Text("No"),
            style: FButtonStyle.outline,
            onPress: () {
              Navigator.of(context).pop(false);
            },
          ),
          FButton(
            style: FButtonStyle.destructive,
            label: const Text("Yes"),
            onPress: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }
}

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({super.key,
    required this.company,
    required this.onCreate,
    required this.onUpdate,
  });

  final Company company;
  final void Function() onCreate, onUpdate;

  @override
  Widget build(BuildContext context) {
    printTrack("Building EmptyScreen");
    return FTheme(
      data: FTheme.of(context),
      child: FScaffold(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("No Company Found",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          TextButton(
            onPressed: () {
              printInfo("Redirecting to Company Creation Page.");
              Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => CompanyForm(
                    document: company,
                    onInsert: onCreate,
                    onUpdate: onUpdate,
                  ),
                )
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon( Icons.add_rounded,
                  size: 36,
                ),
                Text("Create Company",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ]
            ),
          ),
        ]
      ),
      ),
    );
  }
}
