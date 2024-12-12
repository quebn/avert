import "package:avert/core/home/screen.dart";
import "package:avert/core/core.dart";
import "package:crypto/crypto.dart";
import "package:flutter/services.dart";
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
    List<Widget> widgets = [
      const SizedBox(height: 20),
      FTextField(
        textInputAction: TextInputAction.next,
        label: const Text("Username"),
        hint: "Enter username",
        controller: controllers['username']!,
        //required: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => (value?.contains(" ") ?? false) ? "Special characters or Whitespace are not allowed" : null,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z_]")),
        ],
        keyboardType: TextInputType.text,
        maxLines: 1,

      ),
      const SizedBox(height: 10),
      FTextField.password(
        controller: controllers['password']!,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        hint: "Enter password",
        validator: (value) => 8 <= (value?.length ?? 0) ? null : "Password must be at least 8 characters long.",
      ),
      const SizedBox(height: 20),
      FButton(
        label: const Text("Login"),
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
    printInfo("Logging in!");
    final bool isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    String username = controllers['username']!.value.text;
    String password = controllers['password']!.value.text;
    printInfo("Validating the ff. values -> Username: $username | Password: $password");
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
