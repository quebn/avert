import "package:avert/core/core.dart";
import "package:avert/core/auth/screen.dart";
import "package:avert/core/components/avert_button.dart";
import "package:avert/core/documents/company/views.dart";
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
  int currntModule = 0;
  bool lastStatus = true;
  double height = 390;

  late Company? company = widget.company;
  late ScrollController _scrollController;
  late List<Widget> pages = [
    HomeDashboard(company!),
    const Center(child: Text("Documents")),
    const Center(child: Text("Reports")),
    const Center(child: Text("Settings")),
  ];

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
        onPop: () {
          printTrack("Pooping");
          setState(() => company = c);
        },
        onDelete: onCompanyDelete,
      );
    }
    printAssert(company != null, "Company null!!!!!!");
    printInfo("name: ${company!.name}");
    return mainDisplay();
  }

  void onCompanyDelete() {
    String name = company!.name;
    setState(() => company = null);
    notifyUpdate(context, "Company '$name' Deleted!");
  }

  Widget mainDisplay() => Scaffold(
    appBar: AppBar(
      title: TextButton(
        onPressed: () {
          printDebug("Viewing Current Company!");
          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => CompanyView(
                company: company!,
                onDelete: onCompanyDelete,
                onSave: () => setState(() {}),
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
          onPressed: () => printDebug("Pressed Notification Button!"),
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
    drawer: leftDrawer(),
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
        // TODO: might add create button for quick document creation.
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
  // TODO: make title or anything in the dialog change color depending on the results.
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
    required this.onDelete,
    required this.onPop,
  });

  final Company company;
  final void Function()? onPop;
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    printInfo("Building EmptyScreen");
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
                printDebug("Redirecting to Company Creation Page.");
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => CompanyView(
                      company: company,
                      onPop: onPop,
                      onDelete: onDelete,
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
