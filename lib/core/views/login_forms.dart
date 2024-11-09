import "package:avert/core/views/home_screen.dart";
import "package:flutter/material.dart";
import "package:avert/core/components.dart";
import "package:avert/core/user.dart";
import "package:avert/core/app.dart";
import "package:avert/core/utils.dart";
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

  String? userErrMsg, passErrMsg;
  bool rememberLogin = true;

  @override
  void dispose() {
    for (TextEditingController controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[
      AvertInput.alphanumeric(
        name: "Username", 
        controller: controllers['username']!,
        forceErrMsg: userErrMsg,
        required: true,
        onChanged: onChangeUsername,
      ),
      AvertInput.password(
        controller: controllers['password']!,
        forceErrMsg: passErrMsg,
        onChanged: onChangePassword,
      ),
      AvertButton(
        name:"Login",
        fontSize: 18,
        xMargin: 80,
        yMargin: 8,
        // TODO: fix
        // height:  60,
        onPressed: authenticateUser,
      ),
      AvertLink(
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
              children: widgets,
            )
          ),
        ]
      ),
    );
  }

  void onChangeUsername(String? value) {
    if (userErrMsg != null) {
      setState(() => userErrMsg = null);
    }
  }

  void onChangePassword(String? value) {
    if (passErrMsg != null) {
      setState(() => passErrMsg = null);
    }
  }

  Future<void> authenticateUser() async {
    printLog("Logging in!");
    if (!key.currentState!.validate()) {
      printLog("Input field values are wrong", level: LogLevel.error);
      return;
    }
    String username = controllers['username']!.value.text;
    String password = controllers['password']!.value.text;
    printLog("Validating the ff. values -> Username: $username | Password: $password");
    var bytes = utf8.encode(password);
    Digest digest = sha256.convert(bytes);
    
    var result = await App.database!.query("users", 
      columns: ["id", "name", "password", "createdAt"],
      where:"name = ?",
      whereArgs: [username],
    );
    
    if (result.isEmpty) {
      setState(() => userErrMsg = "Username '$username' does not exist!");
      return;
    }

    for (Map<String, Object?> item in result) {
      if (item['password'] == digest.toString() && mounted) {
        User.login(
          id: item['id']!,
          name: item['name']!,
          createdAt: item['createdAt']!,
        );
        // TODO: have a setting to check whether this function should be called or not.
        App.rememberUser(item['id'] as int, rememberLogin);
        Navigator.pop(context);
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(title: widget.title),
          )
        );
        return;
      }
    }
    setState(() => passErrMsg = "Incorrect Password!");
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
    if (!App.hasUsers){
      controllers['username']!.text = "Administrator";
    }
    List<Widget> widgets = <Widget>[
      AvertInput.alphanumeric(
        name:"Username", 
        controller: controllers['username']!,
        required: true,
        validator: (value) {return null;},
        forceErrMsg: userErrMsg,
        onChanged: onChangeUsername,
      ),
      AvertInput.password(
        controller: controllers['password']!,
      ),
      AvertInput.password(
        name:  "Confirm Password", 
        controller: controllers['password_confirm']!,
        // TODO: add an onValueChange for this widget where is checks field must contain.
        validator: (value) {
          return controllers['password']!.text != value ? "Password does not match!" : null;
        },
      ),
      AvertButton(
        name:"Sign Up",
        fontSize: 18,
        xMargin: 80,
        yMargin: 8,
        // TODO: fix 2
        // height:  60,
        onPressed: registerUser,
      ),
      AvertLink(
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
              children: widgets,
            )
          ),
        ]
      ),
    );
  }

  void onChangeUsername(String? value) {
    if (userErrMsg != null) {
      setState(() => userErrMsg = null);
    }
  }
  
  Future<void> registerUser() async {
    if (!key.currentState!.validate()) {
      printLog("WRONG!", level: LogLevel.error);
      return;
    }
    String username = controllers['username']!.value.text;
    String password = controllers['password']!.value.text;
    printAssert(username.isNotEmpty && password.isNotEmpty, "Username and Password is Empty!");
    List<Map<String, Object?>> results = await App.database!.query("users", 
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
    printLog("Creating user.....");
    int? status = await createUser(username, password);
    printAssert(status != 0 ,"insert finished with response code of [$status]");
    printLog("insert finished with response code of [$status]", level: LogLevel.warn);
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
    return await App.database?.insert("users", values);
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
          AvertButton(
            name: "No",
            onPressed: (){
              Navigator.pop(context);
              printLog("Pressed No");
            },
          ),
          AvertButton(
            name: "Yes",
            onPressed: (){
              Navigator.pop(context);
              widget.setLoginForm();
              printLog("Pressed Yes");
            },
          ),
        ]
      ),
    );
  }
}
