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
  int currentIndex = 0;
  int moduleIndex = 0;
  bool lastStatus = true;

  final double height = 390;

  late Company? company = widget.company;
  late List<Widget> pages = [
    Dashboard(module: currentModule),
    const Center(child: Text("Documents")),
    const Center(child: Text("Reports")),
    const Center(child: Text("Settings")),
  ];

  late final List<Module> modules = [
    Accounting(company!),
  ];

  Module get currentModule => modules[moduleIndex];

  // Company selector
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
      header: _HomeHeader(
        title: widget.company!.name,
        fallbackString: getAcronym(widget.user.name),
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
      modules: modules,
      currentIndex: moduleIndex,
      onModuleSelect: (int index){},
    ),
    //bottomNavigationBar: BottomNavigationBar(
    //  selectedItemColor: Colors.black,
    //  unselectedItemColor: Colors.grey,
    //  onTap: (int index) => setState(() => currentIndex = index),
    //  showUnselectedLabels: true,
    //  currentIndex: currentIndex,
    //  items: const [
    //    BottomNavigationBarItem(
    //      icon: Icon(Icons.dashboard_outlined),
    //      label: "Dashboard",
    //      activeIcon: Icon(Icons.dashboard_sharp)
    //    ),
    //    BottomNavigationBarItem(
    //      icon: Icon(Icons.library_books_outlined),
    //      label: "Documents",
    //      activeIcon: Icon(Icons.library_books_sharp),
    //    ),
    //    BottomNavigationBarItem(
    //      icon: Icon(Icons.bar_chart_outlined),
    //      label: "Reports",
    //      activeIcon: Icon(Icons.bar_chart_sharp),
    //    ),
    //    BottomNavigationBarItem(
    //      icon: Icon(Icons.settings_outlined),
    //      label: "Settings",
    //      activeIcon: Icon(Icons.bar_chart_rounded),
    //    ),
    //  ],
    //),
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
      Navigator.pop(context);
      Navigator.push(context,
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
    throw UnimplementedError();
    //return showDialog<bool>(
    //  context: context,
    //  builder: (BuildContext context) => AlertDialog(
    //    title: Text("Log out user?"),
    //    content: Center(
    //      heightFactor: 1,
    //      child: Text("Are you sure you want to logout user '${widget.user.name}'?"),
    //    ),
    //    actions: [
    //      AvertButton(
    //        name: "No",
    //        onPressed: () => Navigator.pop(context, false),
    //      ),
    //      AvertButton(
    //        name: "Yes",
    //        onPressed: () => Navigator.pop(context, true)
    //      ),
    //    ]
    //  ),
    //);

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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.title,
    required this.fallbackString,
    this.onTitlePress,
    this.avatarImage,
  });

  final String title;
  final void Function()? onTitlePress;
  final ImageProvider<Object>? avatarImage;
  final String fallbackString;

  @override
  Widget build(BuildContext context) {
    return FHeader(
        // TODO: add leading icon to open left drawer.
        title: Row(
          children: [
            FButton.icon(
              onPress: () => Scaffold.of(context).openDrawer(),
              style: FButtonStyle.ghost,
              child: FIcon(FAssets.icons.menu,
                size: 28,
              ),
            ),
            SizedBox(width: 16,),
            FButton.raw(
              style: FButtonStyle.ghost,
              onPress: onTitlePress,
              child: Text(title,
                style: context.theme.typography.xl2,
              ),
            ),
          ],
        ),
        actions: [
          FHeaderAction(
            icon: FIcon(FAssets.icons.bell,
              size: 28,
            ),
            onPress: () {},
          ),
          FButton.icon(
            style: FButtonStyle.ghost,
            onPress: () => Scaffold.of(context).openEndDrawer(),
            child: FAvatar(
              image: avatarImage ?? const NetworkImage(''),
              fallback: Text(fallbackString),
            ),
          ),
        ],
      );
  }
}
