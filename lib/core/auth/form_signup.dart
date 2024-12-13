import "package:avert/core/components/avert_input.dart";
import "package:avert/core/core.dart";
import "package:forui/forui.dart";

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key,
    this.hasUsers = true,
    required this.gotoLoginForm,
  });

  final bool hasUsers;
  final void Function() gotoLoginForm;

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
    if (widget.hasUsers) widget.gotoLoginForm;
    List<Widget> widgets = [
      const SizedBox(height: 20),
      AvertInput.alphanumeric(
        textInputAction: TextInputAction.next,
        autofocus: !widget.hasUsers,
        label: "Username",
        required: true,
        hint: "Ex. john_doe",
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controllers['username']!,
        initialValue: widget.hasUsers ? null : "Administrator",
        forceErrMsg: userErrMsg,
      ),
      const SizedBox(height: 10),
      AvertInput.password(
        controller: controllers['password']!,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => 8 <= (value?.length ?? 0) ? null : "Password must be at least 8 characters long.",
      ),
      const SizedBox(height: 10),
      AvertInput.password(
        label:"Confirm Password",
        controller: controllers['password_confirm']!,
        validator: (value) {
          return controllers['password']!.text != value ? "Password does not match!" : null;
        },
      ),
      const SizedBox(height: 20),
      FButton(
        label: const Text("Sign Up",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
    User user = User(name: controllers['username']!.value.text,);

    user.password = hashString(controllers['password']!.value.text);
    if (await user.nameExist()) {
      setState(() {
         userErrMsg = "Username '${user.name}' already exists!";
      });
      return;
    }
    bool success = await user.insert();
    if (mounted && success) {
      widget.gotoLoginForm();
      notifyUpdate(
        context,
        "User '${user.name}' has been successfully created!"
      );
    }
  }
}
