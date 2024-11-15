import "package:avert/core/components/avert_input.dart";
import "package:avert/core/components/avert_button.dart";
import "package:avert/core/components/avert_link.dart";
import "package:avert/core/home/screen.dart";
import "package:avert/core/core.dart";
import "package:crypto/crypto.dart";
import "dart:convert";

// NOTE: LOGIN FORM.
class LoginForm extends StatefulWidget {
  const LoginForm(this.title, this.setSignupForm, {super.key});

  final String title;
  final VoidCallback setSignupForm;

  @override
  State<StatefulWidget> createState() => _FormState();
}

class _FormState extends State<LoginForm> {

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
    printSuccess("Building LoginForm");
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
        yPadding: 20,
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
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12.0,
            ),
            child: Text( "LOGIN",
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

  void onChangePassword(String? value) {
    if (passErrMsg != null) {
      setState(() => passErrMsg = null);
    }
  }

  Future<void> authenticateUser() async {
    printDebug("Logging in!");
    final bool isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    String username = controllers['username']!.value.text;
    String password = controllers['password']!.value.text;
    printDebug("Validating the ff. values -> Username: $username | Password: $password");
    var bytes = utf8.encode(password);
    Digest digest = sha256.convert(bytes);

    var result = await Core.database!.query("users",
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
        User user = User.fromQuery(
          id: item['id']!,
          name: item['name']!,
          createdAt: item['createdAt']!,
        );
        // TODO: have a setting to check whether this function should be called or not.
        if (rememberLogin) user.remember();
        Navigator.pop(context);
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              title: widget.title,
              user: user,
              company: null,
            ),
          )
        );
        return;
      }
    }
    setState(() => passErrMsg = "Incorrect Password!");
  }
}
