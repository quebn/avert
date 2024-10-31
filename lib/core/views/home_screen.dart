import "package:flutter/material.dart";
import "package:acqua/core/utils.dart";

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key, required this.title}) {
    printLog("Calling App Constructor!");
  }
  final String title;

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin{
  // Object<AcquaViewable> currentModule
  // AcquaViewMode currentView
  @override
  Widget build(BuildContext context) {
    printLog("Building Homepage state! ->");
    return Scaffold(
      drawer: Drawer(
        width: 200,
      ),
      appBar: AppBar(
        leading: drawerButton(),
        title: titleItems(),
      ),
      body:ListView.builder(
        itemCount: 20,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            color: index.isOdd ? Colors.white : Colors.black12,
            height: 100.0,
            child: Center(
              child: Text('$index', textScaler: const TextScaler.linear(5)),
            ),
          );
        },
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
    List<Widget> widgets = [
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
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: widgets, 
    );
  }
}
