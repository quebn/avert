import "package:flutter/material.dart";
import "package:acqua/core/components.dart";
import "package:acqua/core/utils.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  
  final String title;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  

  final GlobalKey<FormState> key = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    "username": TextEditingController(),
    "password": TextEditingController(),
  };

  @override
  void dispose() {
    for (TextEditingController controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printLog("Building Login Page.....");
    return LoginScaffold(
      title: widget.title, 
      body: loginBody(context),
    );
  }  

  Widget loginBody(BuildContext context) {

    List<Widget> children = <Widget>[
      AcquaInput.alphanumeric(
        name: "Username", 
        controller: controllers['username']!,
        required: true,
      ),
      AcquaInput.password(
        controller: controllers['password']!,
        validator: (value) { return null; },
      ),
      AcquaButton(
        buttonName:"Login",
        fontSize: 18,
        xMargin: 80,
        yMargin: 8,
        height:  60,
        onPressed:() => onLogin,
      ),
      AcquaLink(
        linkText: "Create a new user.",
        linkSize: 16,
        yMargin: 16,
        onPressed: signupPage,
      ),
    ];

    return Form(
      key:key,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12.0,
            ),
            child: const Text( "LOGIN",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              children: children,
            )
          ),
        ]
      ),
    );
  }

  void signupPage() {
    printLog("Pressed Signup Button!");
    controllers['password']!.text = "";
  }
  
  void onLogin() {
    String username = controllers['username']!.value.text;
    String password = controllers['password']!.value.text;
    if (!key.currentState!.validate()) {
      printLog("Input field values are wrong", level: LogLevel.error);
      return;
    }
    printLog("Username: $username | Password: $password");
  }
}

class LoginScaffold extends StatelessWidget {
  const LoginScaffold({super.key, required this.title, required this.body});

  final Widget body;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15.0),
            ),
            height: MediaQuery.sizeOf(context).height / 4,
            child: Center(
              child: Text(title,
                style: TextStyle(
                  //fontFamily: "Roboto",
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10.0,
                )
              ],
            ),
            margin: EdgeInsets.only(
              left:   12.0,
              right:  12.0,
              top:    MediaQuery.sizeOf(context).height / 5,
              bottom: 20.0,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              shadowColor: Colors.black,
              child: body
            ),
          ),
        ],
      ),
    );
  }
}
