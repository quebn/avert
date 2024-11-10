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
    printDebug("Building HomeScreen");
    if (App.company == null) {
      return noCompanyDisplay();
    }
    printDebug("name: ${App.company!.name}");
    printAssert(App.company != null, "Company null!!!!!!");
    return mainDisplay();
  }

  Widget mainDisplay() => Scaffold(
    drawer: Drawer(
      width: 200,
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
              Company c = Company();
              Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => CompanyView(
                    company: c,
                    onCreate: () => setState(() => App.company = c),
                    onDelete: () => setState(() => App.company = null),
                    onPop: () {
                      printDebug("hello from home!");
                    }
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
    title: TextButton(
      onPressed: () { 
        printDebug("Viewing Current Company!");
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => CompanyView(
              company: App.company!,
              onDelete: () => setState(() => App.company = null),
              onSave: () {},
              // TODO: find way to update to home screen when a company is edited.
              // - like the name that is displayed.
            ),
          )
        );
      },
      child: Text(App.company!.name,
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
      Padding(
        padding: const EdgeInsets.only(right:16),
        child: GestureDetector(
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
          ),
          onTap: () => printDebug("Pressed Profile Picture."),
        ),
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
