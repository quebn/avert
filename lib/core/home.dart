import "package:flutter/material.dart";
import "package:acqua/core.dart";
import "package:acqua/core/login.dart";
import "package:acqua/utils.dart";

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.title}) {
    printLog("Calling App Constructor!");
  }
  final String title;

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  void primaryAction(BuildContext context) {
    printLog("Creating Document...");
  }
  
  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }
  
  Widget homePage(BuildContext context) {
    printLog("Building Homepage state!");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title)
      ),
      body: const Text("HomePage"),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => primaryAction(context),
        tooltip: "Primary Action",
        child: const Icon(Icons.add),
      ),
    );
  }
}
