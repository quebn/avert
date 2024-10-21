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
  
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    printLog("Building login state!");
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
              ]
            ),
            margin: EdgeInsets.only(
              left:   12.0,
              right:  12.0,
              top:    MediaQuery.sizeOf(context).height / 5,
              bottom: 30.0,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              shadowColor: Colors.black,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: isLogin ? loginBody(context) : signupBody(context),
                )
              )
            )
          )
        ]
      )
    );
  }  

  Widget loginBody(BuildContext context) {

    TextEditingController userCon = TextEditingController();
    TextEditingController passwordCon = TextEditingController();

    List<Widget> children = <Widget>[
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
          //physics: ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            AcquaInput(
              labelText: "Username", 
              controller: userCon,
            ),
            AcquaInput(
              labelText: "Password", 
              controller: passwordCon,
            ),
            AcquaButton(
              buttonName:"Login",
              fontSize: 18,
              xMargin: 80,
              yMargin: 8,
              height:  60,
              onPressed:() => onLogin(userCon.text, passwordCon.text),
            ),
            AcquaLink(
              linkText: "Create a new account.",
              linkSize: 16,
              yMargin: 20,
              onPressed: (){ printLog("Pressed Link"); },
            ),
            
          ],
        )
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
        labelText:  "Username", 
        controller: userCon,
      ),
      AcquaInput(
        labelText:  "Password", 
        inputType:  AcquaInputType.password, 
        controller: pwdCon,
      ),
      AcquaInput(
        labelText:  "Confirm Password", 
        inputType:  AcquaInputType.password,
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
