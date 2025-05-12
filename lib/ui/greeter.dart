import "package:avert/docs/document.dart";
import "package:avert/docs/profile.dart";
import "package:avert/ui/components/select.dart";
import "package:avert/ui/home.dart";
import "package:avert/ui/profile.dart";
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

  List<Profile> get profiles => widget.profiles;
  Profile? get selectedProfile => selectController.value;

  @override
  void initState() {
    super.initState();
    selectController = AvertSelectController<Profile>(
      value: widget.initialProfile ?? profiles.firstOrNull
    );
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building Greeter Screen");
    final FThemeData theme = FTheme.of(context);

    Widget content = FScaffold(
      header: SizedBox(height: kToolbarHeight),
      content: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 32),
            FHeader(
              title: Text(
                widget.title,
                style: theme.typography.xl3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            FDivider(),
            GreeterForm(
              profiles: profiles,
              controller: selectController,
              onCreate: onProfileCreate,
              onEnter: selectedProfile != null ? () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      title: "Avert",
                      profile: selectedProfile!,
                    )
                  ));
                } : null,
              )
            ],
        ),
      ),
    );
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        child: content,
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      ),
    );
  }

  void onProfileCreate(Profile profile) {
    printAssert(!profiles.contains(profile), "Profiles should not contain profile with name: ${profile.name}");
    genTestDocs(profile);
    selectController.update(profile);//, selected: true);
    setState(() => profiles.add(profile));
    notify(context, "Profile '${profile.name}' has been successfully created!");
  }
}

class GreeterForm extends StatelessWidget {
  const GreeterForm({super.key,
    required this.profiles,
    required this.controller,
    required this.onEnter,
    required this.onCreate,
  });

  final List<Profile> profiles;
  final AvertSelectController<Profile> controller;
  final Function()? onEnter;
  final Function(Profile)? onCreate;

  @override
  Widget build(BuildContext context) {
    printTrack("Building SelectProfileForm");
    FThemeData theme = FTheme.of(context);
    final String valueText = profiles.isEmpty? "No Profiles Found" :  "No Profile Selected";
    final FButtonStyle ghostStyle = theme.buttonStyles.ghost;
    final List<Widget> widgets = [
      const SizedBox(height: 20),
      AvertSelect<Profile>(
        controller: controller,
        label: "Profile",
        prefix: controller.value != null ? FIcon(FAssets.icons.userRound) : null,
        suffix: FButton.icon(
          style: ghostStyle.copyWith(
            iconContentStyle: ghostStyle.iconContentStyle.copyWith(
              padding: EdgeInsets.zero,
            ),
          ),
          onPress: () => createProfile(context),
          child: FIcon(FAssets.icons.userRoundPlus, size: 28),
        ),
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
        prefix: FIcon(FAssets.icons.logIn),
        label: const Text("Enter",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];

    return FCard(
      title: const Text("Welcome to Avert"),
      subtitle: Text("${profiles.isEmpty ? "Create" : "Select"} a Profile to continue"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: profiles.isEmpty ? [
          SizedBox(height: 32,),
          FButton(
            onPress: () => createProfile(context),
            prefix: FIcon(FAssets.icons.userRoundPlus),
            label: const Text("Create Profile",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ] : widgets,
      ),
    );
  }

  void createProfile(BuildContext context) async {
    final Profile profile = Profile();
    final bool success = await showAdaptiveDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) => ProfileForm.dialog(
        document: profile,
        onSubmit: () async => await profile.insert(),
      ),
    ) ?? false;
    if (!success || profile.action != DocAction.insert) return;
    onCreate?.call(profile);
  }
}
