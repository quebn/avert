import "package:avert/core/core.dart";
import "dashboard.dart";

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
  Company? company;
  int currentIndex = 0;
  bool lastStatus = true;
  double height = 390;

  late ScrollController _scrollController;
  late List<Widget> pages = [
    mainContent(),
    const Center(child: Text("Documents")),
    const Center(child: Text("Reports")),
    const Center(child: Text("Settings")),
  ];

  @override
  void initState() {
    super.initState();
    company = widget.company;
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

  @override
  Widget build(BuildContext context) {
    printSuccess("Building HomeScreen");
    if (company == null) {
      Company c = Company();
      return EmptyScreen(
        company: c,
        onPop: () {
          printTrack("Pooping");
          setState(() => company = c);
        },
        onDelete: () => setState(() => company = null),
      );
    }
    printAssert(company != null, "Company null!!!!!!");
    printLog("name: ${company!.name}");
    return mainDisplay();
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
                onDelete: () => setState(() => company = null),
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
    endDrawer: rightDrawer(),
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
          icon: Icon(Icons.dashboard_rounded),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books_rounded),
          label: "Documents",
        ),
        // TODO: might add create button for quick document creation.
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_rounded),
          label: "Reports",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          label: "Settings",
        ),
      ],
    ),
  );


  Widget leftDrawer() {
    return const Drawer(
      width: 250,
    );
  }

  Widget rightDrawer() {
    return Drawer(
      width: 250,
      child: Column(
        children: [
          DrawerHeader(
            margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 32),
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Center(
              child: Text(widget.user.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text("Profile",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onTap: () { printLog("Open Profile Page.");}
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("App Settings",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onTap: () { printLog("Open Settings App Settings.");}
          ),
          Divider(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Divider(),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text("Log Out",
                    style: TextStyle(
                      fontSize: 16,
                      ),
                    ),
                  onTap: () { printLog("Redirecting to Login Screen");}
                  ),
              ]
            ),
          ),
        ]
      )
    );
  }

  Widget appBar() => SliverAppBar(
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
    excludeHeaderSemantics: true,
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
    pinned: true,
    expandedHeight: 300,
    flexibleSpace: headerContent(),
  );

  Widget headerContent() {
    return FlexibleSpaceBar(
      collapseMode: CollapseMode.pin,
      background: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          Container(
            padding: EdgeInsets.only(top: kToolbarHeight),
            width: MediaQuery.sizeOf(context).width,
            height: 300,
            color: Colors.black,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: const Text("Current Module",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              //padding: EdgeInsets.symmetric(top:)
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20)
              ),
            ),
            height: 24,
          )
        ],
      ),
    );
  }

  Widget mainContent() {
    return SingleChildScrollView(
      child: Column(),
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
    printLog("Building EmptyScreen");
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
