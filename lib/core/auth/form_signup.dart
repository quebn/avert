//import "package:avert/core/components/avert_input.dart";
//import "package:avert/core/components/avert_button.dart";
import "package:avert/core/core.dart";
import "package:flutter/services.dart";

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key,
    this.hasUsers = true,
    required this.onRegister,
  });

  final bool hasUsers;
  final void Function() onRegister;

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
    printTrack("Building SignUpForm");
    printInfo("HasUsers: ${widget.hasUsers}");
    //if (!widget.hasUsers) setUsernameValue();
    List<Widget> widgets = <Widget>[
      const SizedBox(height: 20),
      FTextField(
        textInputAction: TextInputAction.next,
        autofocus: !widget.hasUsers,
        label: const Text("Username"),
        hint: "Ex. john_doe",
        controller: controllers['username']!,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => (value?.contains(" ") ?? false) ? "Special characters or Whitespace are not allowed" : null,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z_]")),
        ],
        initialValue: widget.hasUsers ? null : "Administrator",
        maxLines: 1,
      ),
      const SizedBox(height: 10),
      FTextField.password(
        controller: controllers['password']!,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => 8 <= (value?.length ?? 0) ? null : "Password must be at least 8 characters long.",
      ),
      const SizedBox(height: 10),
      FTextField.password(
        label: const Text("Confirm Password"),
        controller: controllers['password_confirm']!,
        validator: (value) {
          return controllers['password']!.text != value ? "Password does not match!" : null;
        },
      ),
      const SizedBox(height: 20),
      FButton(
        label: const Text("Sign Up"),
        onPress: registerUser,
      ),
    ];

    return FCard(
      title: const Text("Register an Account"),
      subtitle: const Text("Fill up the form to register an account, login if you already have one"),
      child: Form(
        key:key,
        child: Column(
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

  Future<void> registerUser() async {
    final bool isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    User user = User(
      name: controllers['username']!.value.text,
    );

    user.password = hashString(controllers['password']!.value.text);
    // todo: should be this in later
    bool userExist = await user.nameExist();
    if (userExist) {
      setState(() {
         userErrMsg = "Username '${user.name}' already exists!";
      });
      printError(userErrMsg!);
      return;
    }
    printAssert(!userExist, "Username ${user.name} already exist in database where it should'nt");
    printInfo("Preparing Creating user.....");
    bool success = await user.insert();
    if (mounted && success) {
      widget.onRegister();
      notifyUpdate(
        context,
        "User '${user.name}' has been successfully created!"
      );
    }
  }

  void setUsernameValue() {
    controllers["username"]!.text = "Administrator";
  }
}
