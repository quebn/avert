import "package:flutter/material.dart";
import "package:acqua/core/components.dart";
import "package:acqua/core/app.dart";
import "package:acqua/core/utils.dart";
import "package:crypto/crypto.dart";
import "dart:convert";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, });

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  bool isLogin = false;

  @override
  Widget build(BuildContext context) {
    printLog("building.....");
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
              child: const Text("ACQUA",
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
              child: isLogin ? loginBody(context) : signupBody(context),
            ),
          ),
        ],
      ),
    );
  }  

  Widget loginBody(BuildContext context) {

    final GlobalKey<FormState> key = GlobalKey<FormState>();
    final Map<String, TextEditingController> controllers = {
      "username": TextEditingController(),
      "password": TextEditingController(),
    };

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
        onPressed:() => onLogin(key, controllers['username']!.text, controllers['password']!.text),
      ),
      AcquaLink(
        linkText: "Create a new user.",
        linkSize: 16,
        yMargin: 16,
        onPressed:() {
          setState(() => isLogin = false);
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
    setState(() {
      isLogin = false;
    });
  }
  
  void onLogin(GlobalKey<FormState> formKey, String userName, String userPassword,) {
    if (!formKey.currentState!.validate()) {
      printLog("Reach this block!", level: LogLevel.error);
      return;
    }
    printLog("Username: $userName | Password: $userPassword");
  }

  Widget signupBody(BuildContext context) {

    final GlobalKey<FormState> key = GlobalKey<FormState>();
    final Map<String, TextEditingController> controllers = {
      "username": TextEditingController(),
      "password": TextEditingController(),
      "password_confirm": TextEditingController(),
    };

    List<Widget> children = <Widget>[
      AcquaInput.alphanumeric(
        name:"Username", 
        controller: controllers['username']!,
        required: true,
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
        onPressed:() => onSignup(
          key,
          controllers['username']!.value.text, 
          controllers['password']!.value.text, 
        ),
      ),
      AcquaLink(
        linkText: "Login",
        linkSize: 16,
        yMargin: 16,
        onPressed:() {
          setState(() => isLogin = true);
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

  void onSignup(GlobalKey<FormState> formKey, String userName, String userPassword,) {
    if (formKey.currentState!.validate()) {
      printLog("Username: $userName | Password: $userPassword", level: LogLevel.error);
      return;
    }
    printLog("WRONG!", level: LogLevel.error);
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
