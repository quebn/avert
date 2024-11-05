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
    if (App.company == null) {
      printLog("Company is null");
      return createCompanyForm();
      // TODO: Company creation form.
    }
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
      extendBodyBehindAppBar: true,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor:Colors.black,
        unselectedItemColor:Colors.grey,
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

  // TODO: remake this into a stateless/stateful widget in another file.
  Widget createCompanyForm() {
    final GlobalKey<FormState> key = GlobalKey<FormState>();
    TextEditingController nameCon = TextEditingController();
    // TODO: 1. maybe make this list global where other modules can add their fields for company creation. 
    // TODO: 2. or maybe make this function call a return widgets function foreach modules that is present.
    List<Widget> widgets = [
      Container(
        width: MediaQuery.sizeOf(context).width,
        color: Colors.black,
        child: Container(
          decoration: BoxDecoration(
            //padding: EdgeInsets.symmetric(top:)
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20)
            ),
          ),
          height: 25,
        )
      ),
      Column(
        children: [
          AcquaInput(
            xPadding: 24,
            name: "Company Name", 
            controller: nameCon,
            required: true,
          ),
        ]
      ),
    ];
    // NOTE: do foreach call here if 2. was chosen.
    // call goes here.
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("New Company",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 28,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key:key,
          child: Column(
            children: widgets
          ),
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        AcquaButton(
          name: "Create Company", 
          onPressed: () => createFirstCompany(key, nameCon.value.text),
          yPadding: 16,
        ),
      ],
    );
  }

  Future<void> createFirstCompany(GlobalKey<FormState> key, String name) async {
    printLog("Pressed Create Company");
    if (!key.currentState!.validate()) {
      return;
    }
    printLog("Pressed Create Company with value of: $name");
    Company c = await Company.insert(name);
    setState(() => App.company = c);
    App.rememberCompany(c.id);
    printAssert(App.company != null, "App Company is null where it shouldnt!");
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
        Container(
          width: MediaQuery.sizeOf(context).width,
          height: 300,
          color: Colors.black,
          child: headerContent(),
        ),
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

  Widget headerContent() {
    String p2 = "Current Module";
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16, bottom:8),
          child: Text(App.company!.name,
            style: TextStyle(
              fontSize: 18,
              //fontFamily: "Roboto",
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
    );
  }

  Widget dashboardContent() {
    return Column(
      children: [
      ]
    );
  }
}
