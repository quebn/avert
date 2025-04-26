import "package:avert/docs/document.dart";
import "package:avert/docs/profile.dart";
import "package:avert/ui/components/input.dart";
import "package:avert/ui/components/select.dart";
import "package:avert/ui/home.dart";
import "package:avert/utils/database.dart";
import "package:avert/utils/logger.dart";
import "package:avert/utils/ui.dart";

import "package:flutter/material.dart";
import "package:forui/forui.dart";

class GreeterScreen extends StatefulWidget {
  const GreeterScreen({super.key,
    required this.title,
    required this.profiles,
    this.initialProfile,
  });

  final String title;
  final List<Profile> profiles;
  final Profile? initialProfile;

  @override
  State<StatefulWidget> createState() => _ScreenState();
}

class _ScreenState extends State<GreeterScreen> with TickerProviderStateMixin{
  late final AvertSelectController<Profile> selectController;
  late final FTabController tabController;

  Profile get selectedProfile => selectController.value!;

  @override
  void initState() {
    super.initState();
    tabController = FTabController(length: 2, vsync: this, initialIndex: 0);
    selectController = AvertSelectController<Profile>(
      value: widget.initialProfile ?? widget.profiles.firstOrNull
    );
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
    // _selectController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building Greeter Screen");
    final FThemeData theme = FTheme.of(context);
    final List<FTabEntry> tabs = [
      FTabEntry(
        label: const Text("Select",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: SelectProfileForm(
          profiles: widget.profiles,
          controller: selectController,
          onEnter: widget.profiles.isNotEmpty ? () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  title: "Avert",
                  profile: selectedProfile,
                )
              ));
          }: null,
        ),
      ),
      FTabEntry(
        label: const Text("Create",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: CreateProfileForm(
          profiles: widget.profiles,
          onCreate: onProfileCreate,
        ),
      ),
    ];

    Widget content = FScaffold(
      header: SizedBox(height: kToolbarHeight,),
      content: SingleChildScrollView(
        // margin: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            FHeader(
              title: Text(widget.title,
                style: theme.typography.xl3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            FDivider(),
            FTabs(
              controller: tabController,
              tabs: tabs,
            ),
          ],
        ),
      ),
    );
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      resizeToAvoidBottomInset: false,
      body: content,
    );
  }

  void onProfileCreate(Profile profile) {
    selectController.update(profile);//, selected: true);
    setState( () {
      widget.profiles.add(profile);
      tabController.index = 0;
    });
    notify(context, "Profile '${profile.name}' has been successfully created!");
  }
}

class SelectProfileForm extends StatelessWidget {
  const SelectProfileForm({super.key,
    required this.profiles,
    required this.controller,
    this.onEnter,
  });

  final List<Profile> profiles;
  final AvertSelectController<Profile> controller;
  final Function()? onEnter;

  @override
  Widget build(BuildContext context) {
    printTrack("Building SelectProfileForm");
    FThemeData theme = FTheme.of(context);
    final String valueText = profiles.isEmpty? "No Profiles Found" :  "No Profile Selected";
    final List<Widget> widgets = [
      const SizedBox(height: 20),
      AvertSelect<Profile>(
        controller: controller,
        label: "Profile",
        prefix: FIcon(FAssets.icons.user),
        required: true,
        valueBuilder: (BuildContext context, Profile? selectedValue) => Text(selectedValue?.name ?? valueText),
        tileSelectBuilder: (context, value) => AvertSelectTile(
          value: value,
          prefix: FIcon(FAssets.icons.userRound),
          title: Text(value.name, style: theme.typography.base),
          selected: controller.value == value,
        ),
      options: profiles,
    ),
      const SizedBox(height: 20),
      FButton(
        onPress: onEnter,
        label: const Text("Enter",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];

    return FCard(
      title: const Text("Select Profile"),
      subtitle: const Text("Select a Profile to continue"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widgets,
      ),
    );
  }
}

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
        onChange: (value) {
          if (userErrMsg != null) {
            setState(() => userErrMsg = null);
          }
        },
        controller: controllers["name"]!,
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

  Future<void> createProfile() async {
    final bool isValid = key.currentState?.validate() ?? false;

    if (!isValid) return;

    Profile p = Profile(name: controllers["name"]!.value.text,);

    if (await exist(p, Profile.tableName)) {
      setState(() {
         userErrMsg = "Profile Name: '${p.name}' already exists!";
      });
      return;
    }
    final String? error = await p.insert();
    if (error == null && p.action == DocAction.insert) {
      genTestDocs(p);
      widget.onCreate(p);
    }
  }
}
