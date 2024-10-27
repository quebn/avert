import "package:flutter/material.dart";
import "package:acqua/core/components.dart";
import "package:acqua/core/app.dart";
import "package:acqua/core/utils.dart";
import "package:crypto/crypto.dart";
import "dart:convert";


// NOTE: LOGIN FORM.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.title, required this.setSignupForm});
  
  final String title;
  final VoidCallback setSignupForm;

  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  

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
        name:"Login",
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
        onPressed: widget.setSignupForm,
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

// NOTE: SIGNUP FORM.
class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key, required this.title, required this.setLoginForm});
  
  final String title;
  final VoidCallback setLoginForm;

  @override
  State<StatefulWidget> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  

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
        // TODO: add an onValueChange for this widget where is checks the password what the password must contain.
        validator: (value) {
          return controllers['password']!.text != value ? "Password does not match!" : null;
        },
      ),
      AcquaButton(
        name:"Sign Up",
        fontSize: 18,
        xMargin: 80,
        yMargin: 8,
        height:  60,
        onPressed: onSignup,
      ),
      AcquaLink(
        linkText: "Login",
        linkSize: 16,
        yMargin: 16,
        onPressed: widget.setLoginForm
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
    if(userErrMsg != null) setState(() =>userErrMsg = null);
    if (!key.currentState!.validate()) {
      printLog("WRONG!", level: LogLevel.error);
      return;
    }
    printAssert(username.isNotEmpty && password.isNotEmpty, "Username and Password is Empty!");
    var results = await App.db!.query("users", 
      where:"name = ?",
      whereArgs: [username],
    );

    if (results.isNotEmpty) {
      setState(() {
         userErrMsg = "Username '$username' already exists!";
      });
      printLog(userErrMsg!, level:LogLevel.error);
      return;
    }
    printAssert(results.isEmpty, "Username $username already exist in database where it should'nt dumping userdata: ${results.toString()}");
    // TODO: actions.
    //    [x] check if user exist in database. 
    //    [x] if exist it exist, username field should throw an error message.
    //    [-] if not exist create user.
    //    [ ] show a pop up that a user is created. and show buttons on what the user want to do next.
    printLog("Creating user.....");
    printLog("Username: $username | Password: $password", level: LogLevel.error);
    //int? status_code = createUser(username, password);
    //printLog("insert finished with response code of [$status_code]", level: LogLevel.warn);
    final String t = "User '$username' created!";
    final String m = "User '$username' has been successfully created would you like to go to Login form?";
    notifyUserCreation(t, m);
  }

  Future<int?> createUser(String username, String password) async {
    printLog("Creating user...");
    var bytes = utf8.encode(password);
    Digest digest = sha256.convert(bytes);
    var values = {
      "name"      : username,
      "password"  : digest.toString(),
      "createdAt" : DateTime.now().millisecondsSinceEpoch,
    };
    printLog("Inserting to users table values: ${values.toString()}", level: LogLevel.warn);
    return await App.db?.insert("users", values);
  }

  Future<void> notifyUserCreation(String title, String msg) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(msg),
        ),
        actions: [
          AcquaButton(
            name: "No",
            onPressed: (){
              Navigator.pop(context, "No");
              printLog("Pressed No");
            },
          ),
          AcquaButton(
            name: "Yes",
            onPressed: (){
              Navigator.pop(context, "Yes");
              widget.setLoginForm();
              printLog("Pressed Yes");
            },
          ),
        ]
      ),
    );
  }
}
