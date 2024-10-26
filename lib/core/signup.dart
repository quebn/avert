import "package:flutter/material.dart";
import "package:acqua/core/components.dart";
import "package:acqua/core/app.dart";
import "package:acqua/core/utils.dart";
import "package:acqua/core/login.dart";
import "package:crypto/crypto.dart";
import "dart:convert";

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.title});
  
  final String title;

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  

  final GlobalKey<FormState> key = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    "username": TextEditingController(),
    "password": TextEditingController(),
    "password_confirm": TextEditingController(),
  };
  String? userErrMsg;

  @override
  void dispose() {
    for (TextEditingController controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printLog("Building Signup Page.....");
    return LoginScaffold(
      title: widget.title,
      body: signupBody(context),
    );
  }  

  Widget signupBody(BuildContext context) {
    List<Widget> children = <Widget>[
      AcquaInput.alphanumeric(
        name:"Username", 
        controller: controllers['username']!,
        required: true,
        validator: (value) {return null;},
        forceErrMsg: userErrMsg,
      ),
      AcquaInput.password(
        controller: controllers['password']!,
      ),
      AcquaInput.password(
        name:  "Confirm Password", 
        controller: controllers['password_confirm']!,
        validator: (value) {
          return controllers['password']!.text != value ? "Password does not match!" : null;
        },
      ),
      AcquaButton(
        buttonName:"Sign Up",
        fontSize: 18,
        xMargin: 80,
        yMargin: 8,
        height:  60,
        onPressed:() => onSignup,
      ),
      AcquaLink(
        linkText: "Login",
        linkSize: 16,
        yMargin: 16,
        onPressed:() {
          // TODO: navigate to login.
        }
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
            child: const Text( "REGISTER",
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

  Future<void> onSignup() async {
    String username = controllers['username']!.value.text;
    String password = controllers['password']!.value.text;
    if(userErrMsg != null) setState(() => userErrMsg = null);
    if (!key.currentState!.validate()) {
      printLog("WRONG!", level: LogLevel.error);
      return;
    }
    printAssert(username.isNotEmpty && password.isNotEmpty, "Username and Password is Empty!");
    var results = await App.db!.query("users", 
      where:"name = ?",
      whereArgs: [username],
    );
    if(results.isEmpty) {
      printLog("Username '$username' already exists!", level:LogLevel.error);
      setState(() {
         userErrMsg = "Username '$username' already exists!";
      });
      return;
    }
    // TODO: actions.
    //    [x] check if user exist in database. 
    //    [-] if exist it exist, username field should throw an error message.
    //    [ ] if not exist create user.
    //    [ ] show a pop up that a user is created. and show buttons on what the user want to do next.
    printLog("Creating user.....");
    printLog("Username: $username | Password: $password", level: LogLevel.error);
    //createUser(userName, userPassword);
  }

  Future<void> createUser(String username, String password) async {
    printLog("Creating user...");
    var bytes = utf8.encode(password);
    Digest digest = sha256.convert(bytes);
    var values = {
      "name"      : username,
      "password"  : digest.toString(),
      "createdAt" : DateTime.now().millisecondsSinceEpoch,
    };
    printLog("Inserting to users table values: ${values.toString()}", level: LogLevel.warn);
    int? r = await App.db?.insert("users", values);
    printLog("insert finished with response code of [$r]", level: LogLevel.warn);
  }
}
