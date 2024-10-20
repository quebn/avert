import "package:flutter/material.dart";
import "package:acqua/core.dart";
import "package:acqua/utils.dart";
import "package:crypto/crypto.dart";
import "dart:convert";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, });

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    printLog("Building login state!");
    TextEditingController userCon = TextEditingController();
    TextEditingController passwordCon = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: MediaQuery.sizeOf(context).height / 4,
            child: Center(
              child: const Text("ACQUA",
                style: TextStyle(
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
              ]
            ),
            margin: EdgeInsets.only(
              left:   12.0,
              right:  12.0,
              top:    MediaQuery.sizeOf(context).height / 5,
              bottom: 50.0,
            ),
            child: Card(
              shadowColor: Colors.black,
              child: Center(
                child: const Text("Text Fields"),
                )
            )
          )
        ]
      )
    );
  }  

  Widget loginBody(BuildContext context, TextEditingController userCon, TextEditingController passwordCon) {
    List<Widget> children = <Widget>[
      //const Text("Login as a User"),
      AcquaInput(
        labelText: "Username", 
        padding: EdgeInsets.all(8.0),
        controller: userCon,
      ),
      AcquaInput(
        labelText: "Password", 
        padding: EdgeInsets.all(8.0),
        controller: passwordCon,
      ),
      Row(
        children: <Widget>[
          AcquaButton(
            buttonName:"Sign Up",
            onPressed:() => signupPage(context),
          ),
          AcquaButton(
            buttonName:"Login",
            onPressed:() => onLogin(userCon.text, passwordCon.text),
          ),
        ],
      ),
    ];
    return Center(
      child: Column(
        children: children,
      ),
    );
  }
  
  void signupPage(BuildContext context) {
    printLog("Building signup page!");

    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: signupBody(context)
        )
      ),
    );
    printLog("Pressed Signup Button!");
  }
  
  void onLogin(String userName, String userPassword) {
    printLog("Username: $userName | Password: $userPassword");
  }

  Widget signupBody(BuildContext context) {

    TextEditingController userCon = TextEditingController();
    TextEditingController pwdCon = TextEditingController();
    TextEditingController pwdConfirmCon = TextEditingController();

    List<Widget> children = <Widget>[
      AcquaInput(
        labelText: "Username", 
        padding: EdgeInsets.all(8.0),
        controller: userCon,
      ),
      AcquaInput(
        labelText: "Password", 
        inputType: AcquaInputType.password, 
        padding: EdgeInsets.all(8.0),
        controller: pwdCon,
      ),
      AcquaInput(
        labelText: "Confirm Password", 
        inputType: AcquaInputType.password,
        padding: EdgeInsets.all(8.0),
        controller: pwdConfirmCon,
      ),
      Row(
        children: <Widget>[
          AcquaButton(
            buttonName:"Sign Up",
            onPressed:() => onSignup(userCon, pwdCon, pwdConfirmCon),
          ),
        ],
      ),
    ];

    return Column(
      children: children
    );
  }

  void onSignup(TextEditingController userCon, TextEditingController pwdCon, TextEditingController pwdConfirmCon) {
    String username = userCon.text;
    String password = pwdCon.text;
    String passwordConfirm = pwdConfirmCon.text;
    if (password != passwordConfirm) {
      printLog("Password does not match!", level: LogLevel.error);
      return;
    }
    printLog("Passwords matched!");
    createUser(username, password);
    Navigator.pop(context);
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
