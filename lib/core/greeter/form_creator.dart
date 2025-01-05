import "package:avert/core/core.dart";
import "package:avert/core/components/avert_input.dart";
import "package:avert/core/utils/database.dart";
import "package:forui/forui.dart";

class CreateProfileForm extends StatefulWidget {
  const CreateProfileForm({super.key,
    required this.onCreate,
    required this.profiles,
  });

  final List<Profile> profiles;
  final void Function(Profile createdProfile) onCreate;

  @override
  State<StatefulWidget> createState() => _FormState();
}

class _FormState extends State<CreateProfileForm> {

  final GlobalKey<FormState> key = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    "name": TextEditingController(),
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
    printTrack("Building CreateProfileForm");
    List<Widget> widgets = [
      const SizedBox(height: 20),
      AvertInput.text(
        textInputAction: TextInputAction.next,
        label: "Name",
        required: true,
        hint: "Ex. John Doe",
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChange: onChangeProfileName,
        controller: controllers['name']!,
        forceErrMsg: userErrMsg,
      ),
      const SizedBox(height: 20),
      FButton(
        label: const Text("Create",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        onPress: createProfile,
      ),
    ];

    return FCard(
      title: const Text("Create Profile"),
      subtitle: const Text("Fill up the form to create a profile, go to Select if you already have one."),
      child: Form(
        key:key,
        child: Column(
          children: widgets,
        ),
      ),
    );
  }

  void onChangeProfileName(String? value) {
    if (userErrMsg != null) {
      setState(() => userErrMsg = null);
    }
  }

  Future<void> createProfile() async {
    final bool isValid = key.currentState?.validate() ?? false;

    if (!isValid) return;

    Profile p = Profile(name: controllers['name']!.value.text,);

    if (await exists(p, Profile.tableName)) {
      setState(() {
         userErrMsg = "Profile Name: '${p.name}' already exists!";
      });
      return;
    }
    Result<Profile> result = await p.insert();
    if (result.action == DocumentAction.insert) {
      widget.onCreate(p);
    }
  }
}
