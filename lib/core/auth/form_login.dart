import "package:avert/core/components/avert_input.dart";
import "package:avert/core/components/avert_button.dart";
import "package:avert/core/home/screen.dart";
import "package:avert/core/core.dart";
import "package:crypto/crypto.dart";
import "dart:convert";

import "package:shared_preferences/shared_preferences.dart";

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});


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
    printTrack("Building LoginForm");
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
    ];

    return Padding(
      padding: EdgeInsetsDirectional.only(top: 8),
      child: Form(
        key:key,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          children: widgets,
        ),
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
        SharedPreferencesWithCache sp = await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(allowList: {"company_id"}),
        );
        Company? company = await Company.fetchDefault(Core.database!, sp);
        // TODO: have a setting to check whether this function should be called or not.
        if (rememberLogin) user.remember();
        if(mounted) {
          Navigator.pop(context);
          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                title: "Avert",
                user: user,
                company: company,
              ),
            )
          );
        }
      }
    }
    setState(() => passErrMsg = "Incorrect Password!");
  }
}
