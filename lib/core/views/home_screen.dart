import "package:acqua/core/components.dart";
import "package:flutter/material.dart";
import "package:acqua/core.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // int currentModule
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    printAssert(App.user != null, "User null, is not set where it should be through login or auto login.");
    return Scaffold(
      drawer: Drawer(
        width: 200,
      ),
      appBar: AppBar(
        leading: drawerButton(),
        title: titleItems(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            dashboardHeader(),
            dashboardContent(),
          ],
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {currentIndex = index;});
        },
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
  }


  Widget drawerButton() => Builder(
    builder: (BuildContext context) {
      return IconButton(
        icon: const Icon(Icons.menu),
        iconSize: 30,
        onPressed: () => Scaffold.of(context).openDrawer(),
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      );
    },
  );
  
  Widget titleItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // current cd
        //Notification Button.
        IconButton(
          padding: EdgeInsets.only(right:16),
          icon: const Icon(Icons.notifications_rounded),
          iconSize: 30,
          onPressed: () => printLog("Pressed Notification Button!"),
          //tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        ),
        GestureDetector(
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
          ),
          onTap: () => printLog("Pressed Profile Picture."),
        ),
        //Profile Button.
      ], 
    );
  }

  Widget dashboardHeader() {
    return Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: [
        App.company == null ? createCompany() : headerContent(),
        Container(
          decoration: BoxDecoration(
            //padding: EdgeInsets.symmetric(top:)
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20)
            ),
          ),
          height: 25,
        )
      ],
    );
  }

  Widget createCompany() {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: 200,
      color: Colors.black,
      child: Column(
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
              App.company = Company();
              printLog("Redirecting to Company Creation Page.");
              Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => CompanyScreen(company: App.company!)
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
                Text("Create New Company",
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
    );
  }

  Widget headerContent() {
    String p2 = "Current Module";
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: 300,
      color: Colors.black,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16, bottom:8),
            child: Text(App.company!.name,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(p2,
              style: TextStyle(
                fontSize: 14,
                //fontFamily: "Roboto",
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboardContent() {
    return Column(
      children: [
      ]
    );
  }
}
