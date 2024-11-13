import "package:avert/core/views/home_title.dart";
import "package:flutter/material.dart";
import "package:avert/core.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

 final String title;

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  // int currentModule

  @override
  Widget build(BuildContext context) {
    printAssert(App.user != null, "User null, is not set where it should be through login or auto login.");
    printSuccess("Building HomeScreen");
    if (App.company == null) {
      return noCompanyDisplay();
    }
    printLog("name: ${App.company!.name}");
    printAssert(App.company != null, "Company null!!!!!!");
    return mainDisplay();
  }

  Widget mainDisplay() => Scaffold(
    endDrawer: Drawer(
      width: 250,
      child: ListView(
        children: [
          DrawerHeader(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: SizedBox(
              height: 350,
              child: Center(
                child: Text(App.user!.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text("Profile",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            onTap: () { printLog("Open Profile Page.");}
          ),
          Divider(
            height: 8,
            thickness: 1,
          ),
        ]
      )
    ),
    drawer: Drawer(
      width: 250,
    ),
    body: CustomScrollView(
      slivers: [
        appBar(),
        mainContent()
      ],
    ),
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

  Widget noCompanyDisplay() => Scaffold(
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
              Company company = Company();
              Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => CompanyView(
                    company: company,
                    onCreate: () => setState(() => App.company = company),
                    onDelete: () => setState(() => App.company = null),
                    onSave: () => setState(() {}),
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

  Widget appBar() => SliverAppBar(
    title: HomeTitle(
      onDelete: () => setState(() => App.company = null),
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
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 700, // NOTE: temporary height for debug purposes.
        child: Column(
          children: [
          ]
        ),
      ),
    );
  }
}
