import "package:avert/accounting/accounting.dart";
import "package:avert/core/core.dart";
import "package:avert/core/auth/screen.dart";
import "package:avert/core/documents/company/form.dart";
import "package:avert/core/documents/company/view.dart";
import "package:avert/core/home/module_drawer.dart";
import "package:avert/core/utils/ui.dart";
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

  set currentCompany(Company? newCompany) => setState(() => company = newCompany);

  @override
  Widget build(BuildContext context) {
    if (company == null) {
      Company c = Company();
      return EmptyScreen(
        company: c,
        onCreate: () => currentCompany = c,
        onUpdate: () => setState(() {}),
        onDelete: onCompanyDelete,
      );
    }
    printTrack("Building HomeSceen");
    return mainDisplay(context);
  }

  void onCompanyDelete() {
    final String m = "Company '${company!.name}' successfully deleted!";
    currentCompany = null;
    printInfo("notifying of company deletion");
    notify(context, m);
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
      footer: FBottomNavigationBar(
        index: currentIndex,
        onChange: (index) => setState(() => currentIndex = index),
        children: [
        FBottomNavigationBarItem(
          icon: FIcon(FAssets.icons.layoutDashboard),
          label: const Text("Dashboard"),
        ),
        FBottomNavigationBarItem(
          icon: FIcon(FAssets.icons.bookText),
          label: const Text("Documents"),
        ),
        FBottomNavigationBarItem(
          icon: FIcon(FAssets.icons.chartNoAxesCombined),
          label: const Text("Reports"),
        ),
        FBottomNavigationBarItem(
          icon: FIcon(FAssets.icons.settings),
          label: const Text("Settings"),
        ),
        ],
      ),
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
    required this.onDelete,
  });

  final Company company;
  final void Function() onCreate, onUpdate, onDelete;

  @override
  Widget build(BuildContext context) {
    printTrack("Building EmptyScreen");
    FThemeData theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldStyle.backgroundColor,
      body: FScaffold(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("No Company Found", style: theme.typography.xl3.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            )),
            TextButton(
              onPressed: () {
                printInfo("Redirecting to Company Creation Page.");
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => CompanyForm(
                      document: company,
                      onInsert: onCreate,
                      onUpdate: onUpdate,
                      onDelete: onDelete,
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
