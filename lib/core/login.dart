import "package:flutter/material.dart";
import "package:acqua/core.dart";
import "package:acqua/utils.dart";

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
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Login")
      ),
      body: loginBody(userCon, passwordCon),
      );
  }  

  Widget loginBody(TextEditingController userCon, TextEditingController passwordCon) {
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
            onPressed:() => signup(),
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
  
  void signup() {
    printLog("Building signup state!");
    TextEditingController userCon = TextEditingController();
    TextEditingController pwdCon = TextEditingController();
    TextEditingController pwdConfirmCon = TextEditingController();

    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("Create new user"),
          ),
          body: signupBody(context, userCon, pwdCon, pwdConfirmCon)
        )
      ),
    );
    printLog("Pressed Signup Button!");
  }

  
  void onLogin(String userName, String userPassword) {
    printLog("Username: $userName | Password: $userPassword");
  }

  Widget signupBody(BuildContext context, TextEditingController userCon, TextEditingController pwdCon, TextEditingController pwdConfirmCon) {
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
        controller: pwdCon,
      ),
      AcquaInput(
        labelText: "Confirm Password", 
        padding: EdgeInsets.all(8.0),
        controller: pwdConfirmCon,
      ),
      Row(
        children: <Widget>[
          AcquaButton(
            buttonName:"Sign Up",
            onPressed:() => onSignup(),
          ),
        ],
      ),
    ];

    return Column(
      children: children
    );
  }
  
  void onSignup() {
    printLog("Signing Up!");
  }
}
