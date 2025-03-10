import "package:avert/core/components/avert_select.dart";
import "package:avert/core/core.dart";

import "package:forui/forui.dart";

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
