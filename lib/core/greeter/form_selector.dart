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
  final FRadioSelectGroupController<Profile> controller;
  final Function()? onEnter;

  @override
  Widget build(BuildContext context) {
    printTrack("Building SelectProfileForm");
    final String valueText = profiles.isEmpty? "No Profiles Found" :  "No Profile Selected";
    final List<Widget> widgets = [
      const SizedBox(height: 20),
      AvertSelect<Profile>(
        label: "Profile",
        prefix: FIcon(FAssets.icons.user),
        controller: controller,
        valueBuilder: (BuildContext context, Profile? selectedValue) => Text(selectedValue?.name ?? valueText),
        tileSelectBuilder: (context, value) => FSelectTile<Profile>(
          title: Text(value.name),
          value: value,
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
