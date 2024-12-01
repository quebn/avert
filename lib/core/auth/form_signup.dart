import "package:avert/core/components/avert_input.dart";
import "package:avert/core/components/avert_button.dart";
import "package:avert/core/core.dart";
import "package:crypto/crypto.dart";
import "dart:convert";

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
    if (!widget.hasUsers){
      controllers['username']!.text = "Administrator";
    }
    List<Widget> widgets = <Widget>[
      AvertInput.alphanumeric(
        autofocus: true,
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

  Future<void> registerUser() async {
    final bool isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    User user = User(
      name: controllers['username']!.value.text,
    );
    var bytes = utf8.encode(controllers['password']!.value.text);
    user.password = sha256.convert(bytes);
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
}
