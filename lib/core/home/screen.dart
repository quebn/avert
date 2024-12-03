import "package:avert/accounting/accounting.dart";
import "package:avert/core/core.dart";
import "package:avert/core/auth/screen.dart";
import "package:avert/core/components/avert_button.dart";
import "package:avert/core/documents/company/form.dart";
import "package:avert/core/documents/company/view.dart";
import "package:avert/core/home/module_drawer.dart";
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
  final List<Module> modules = [
    Accounting(),
  ];
  final List<String> foo = [];

  late Company? company = widget.company;
  late ScrollController _scrollController;
  late List<Widget> pages = [
    HomeDashboard( company: company!, module: currentModule),
    const Center(child: Text("Documents")),
    const Center(child: Text("Reports")),
    const Center(child: Text("Settings")),
  ];

  Module get currentModule => modules[moduleIndex];
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_isShrink != lastStatus) {
      setState(() {
        lastStatus = _isShrink;
      });
    }
  }

  bool get _isShrink {
    return _scrollController.hasClients &&
        _scrollController.offset > (height - kToolbarHeight);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
    return mainDisplay();
  }

  void onCompanyDelete() {
    setState(() => company = null);
  }

  Widget mainDisplay() => Scaffold(
    appBar: AppBar(
      title: TextButton(
        onPressed: () {
          printInfo("Viewing Current Company!");
          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => CompanyView(
                document: company!,
                onDelete: onCompanyDelete,
                onUpdate: () {
                  printError("From Main Display of HomeScreen");
                  setState(() {});
                }
              ),
            )
          );
        },
        child: Text(company!.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
      ),
      actions: [
        IconButton(
          padding: const EdgeInsets.only(right:16),
          icon: const Icon(Icons.notifications_rounded),
          iconSize: 30,
          onPressed: () => printInfo("Pressed Notification Button!"),
          //tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        ),
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              padding: const EdgeInsets.only(right: 16),
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
              ),
              iconSize: 36,
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            );
          },
        ),
      ],
      //excludeHeaderSemantics: true,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            iconSize: 30,
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          );
        },
      ),
    ),
    endDrawer: HomeProfileDrawer(
      user: widget.user,
      onLogout: () => logout(),
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
    drawer: HomeModuleDrawer(modules: modules),
    body: pages[currentIndex],
    bottomNavigationBar: BottomNavigationBar(
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: (int index) => setState(() => currentIndex = index),
      showUnselectedLabels: true,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          label: "Dashboard",
          activeIcon: Icon(Icons.dashboard_sharp)
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books_outlined),
          label: "Documents",
          activeIcon: Icon(Icons.library_books_sharp),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          label: "Reports",
          activeIcon: Icon(Icons.bar_chart_sharp),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: "Settings",
          activeIcon: Icon(Icons.bar_chart_rounded),
        ),
      ],
    ),
  );

  Widget leftDrawer() {
    return const Drawer(
      width: 250,
      //child: Listjk
    );
  }

  Future<void> logout() async {
    bool shouldLogout = await confirmLogout() ?? false;
    if (shouldLogout && mounted) {
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
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Log out user?"),
        content: Center(
          heightFactor: 1,
          child: Text("Are you sure you want to logout user '${widget.user.name}'?"),
        ),
        actions: [
          AvertButton(
            name: "No",
            onPressed: () => Navigator.pop(context, false),
          ),
          AvertButton(
            name: "Yes",
            onPressed: () => Navigator.pop(context, true)
          ),
        ]
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
    return Scaffold(
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top:24),
              child: Text("No Company Found",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
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
                    color: Colors.white,
                    size: 36,
                  ),
                  Text("Create Company",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
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
