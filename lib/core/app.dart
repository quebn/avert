import "package:acqua/core.dart";
import "package:acqua/utils.dart";
import "package:flutter/material.dart";

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.title}) {
    printLog("Calling App Constructor!");
  }
  final String title;

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Document> documents = <Document>[];

  void primaryAction(BuildContext context) {
    createDocument();
  }
  
  void createDocument() {
    TextEditingController fnameCon = TextEditingController();
    //TextEditingController lnameCon = TextEditingController();

    List<Widget> children = <Widget>[
      InputField(
        labelText: "Full Name", 
        padding: EdgeInsets.all(8.0),
        controller: fnameCon,
      ),
    ];

    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => PromptScreen(
          body: Column( children: children),
          promptName: "Document", 
          footer: TextButton(
            onPressed: () =>  {
              setState(() => documents.add(Document(name:fnameCon.text,))),
              Navigator.pop(context)
            },
            child: const Text("Create"),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    printLog("Building State!");
    // Check if user logged in, if not then prompt login page.
    return homePage(context);
  }
  
  Widget homePage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: documents.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: 50,
              color: Colors.black87,
              child: Column(
                children: <Widget> [
                  Text( "Full Name: ${documents[index].name}"),
                  Text( "Created at: ${documents[index].createdAt}"),
                ],
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => primaryAction(context),
       tooltip: "Increment",
        child: const Icon(Icons.add),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: const Text("Login Page"),
      ),
    );
  }
}
