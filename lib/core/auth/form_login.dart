import "package:avert/core/components/avert_input.dart";
import "package:avert/core/home/screen.dart";
import "package:avert/core/core.dart";
import "package:crypto/crypto.dart";
import "dart:convert";

import "package:shared_preferences/shared_preferences.dart";
import "package:forui/forui.dart";

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
    List<Widget> widgets = [
      const SizedBox(height: 20),
      AvertInput.alphanumeric(
        textInputAction: TextInputAction.next,
        label: "Username",
        hint: "Enter username",
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controllers['username']!,
        required: true,
        forceErrMsg: userErrMsg,
        onChange: (_) => _clearUserNameErr(),
      ),
      const SizedBox(height: 10),
      AvertInput.password(
        controller: controllers['password']!,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        hint: "Enter password",
        validator: (value) => 8 <= (value?.length ?? 0) ? null : "Password must be at least 8 characters long.",
        forceErrMsg: passErrMsg,
        onChange: (_) => _clearPasswordErr(),
      ),
      const SizedBox(height: 20),
      FButton(
        label: const Text("Login",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        onPress: authenticateUser,
      ),
    ];

    return FCard(
      title: const Text("Welcome to Avert"),
      subtitle: const Text("Enter your account credentials, register if you dont have an account"),
      child: Form(
        key: key,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widgets,
        ),
      ),
    );
  }

  Future<void> authenticateUser() async {
    printInfo("Logging in!");
    _clearErrMsgs();
    final bool isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    String username = controllers['username']!.value.text;
    String password = controllers['password']!.value.text;

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

  void _clearErrMsgs() {
    _clearPasswordErr();
    _clearUserNameErr();
  }

  void _clearPasswordErr() {
    if (passErrMsg == null) return;
    setState(() => passErrMsg = null);
  }

  void _clearUserNameErr() {
    if (userErrMsg == null) return;
    setState(() => userErrMsg = null);
  }
}
