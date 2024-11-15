import "package:avert/core/components/avert_input.dart";
import "package:avert/core/components/avert_button.dart";
import "package:avert/core/components/avert_link.dart";
import "package:avert/core/core.dart";
import "package:crypto/crypto.dart";
import "dart:convert";

// NOTE: SIGNUP FORM.
class SignUpForm extends StatefulWidget {
  const SignUpForm(this.title, this.setLoginForm, {super.key, this.hasUsers = true});

  final String title;
  final VoidCallback setLoginForm;
  final bool hasUsers;

  @override
  State<StatefulWidget> createState() => _FormState();
}

class _FormState extends State<SignUpForm> {


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
    printSuccess("Building SignUpForm");
    if (widget.hasUsers){
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
        yPadding: 20,
        xMargin: 80,
        yMargin: 8,
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
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12.0,
            ),
            child: Text( "REGISTER",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
    final bool isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    String username = controllers['username']!.value.text;
    String password = controllers['password']!.value.text;
    printAssert(username.isNotEmpty && password.isNotEmpty, "Username and Password is Empty!");
    List<Map<String, Object?>> results = await Core.database!.query("users",
      where:"name = ?",
      whereArgs: [username],
    );

    if (results.isNotEmpty) {
      setState(() {
         userErrMsg = "Username '$username' already exists!";
      });
      printDebug(userErrMsg!, level:LogLevel.error);
      return;
    }
    printAssert(results.isEmpty, "Username $username already exist in database where it should'nt dumping userdata: ${results.toString()}");
    printDebug("Preparing Creating user.....");
    int? status = await createUser(username, password);
    printAssert(status != 0 ,"insert finished with response code of [$status]");
    printDebug("insert finished with response code of [$status]", level: LogLevel.warn);
    final String t = "User '$username' created!";
    final String m = "User '$username' has been successfully created would you like to go to Login form?";
    notifyUserCreation(t, m);
  }

  Future<int?> createUser(String username, String password) async {
    printDebug("Actually Creating user...");
    var bytes = utf8.encode(password);
    Digest digest = sha256.convert(bytes);
    var values = {
      "name"      : username,
      "password"  : digest.toString(),
      "createdAt" : DateTime.now().millisecondsSinceEpoch,
    };
    printDebug("Inserting to users table values: ${values.toString()}", level: LogLevel.warn);
    return await Core.database?.insert("users", values);
  }

  Future<void> notifyUserCreation(String title, String msg) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Center(
          heightFactor: 1,
          child: Text(msg),
        ),
        actions: [
          AvertButton(
            name: "No",
            onPressed: (){
              Navigator.pop(context);
              printDebug("Pressed No");
            },
          ),
          AvertButton(
            name: "Yes",
            onPressed: (){
              Navigator.pop(context);
              widget.setLoginForm();
              printDebug("Pressed Yes");
            },
          ),
        ]
      ),
    );
  }
}
