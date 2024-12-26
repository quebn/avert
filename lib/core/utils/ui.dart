import "package:avert/core/core.dart";
import "package:forui/forui.dart";

void notify(BuildContext context, String msg) {
  final SnackBar snackBar = SnackBar(
    showCloseIcon: true,
    content: Center(
      child: Text(msg),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<bool?> confirm(BuildContext context) {
  printWarn("showing pop confirmation dialog");
  return showAdaptiveDialog<bool>(
    context: context,
    builder: (BuildContext context) => FDialog(
      direction: Axis.horizontal,
      title: const Text("Are you sure?"),
      body: const Text("Are you sure you want to leave this page?"),
      actions: <Widget>[
        FButton(
          label: const Text("Stay"),
          style: FButtonStyle.outline,
          onPress: () {
            Navigator.of(context).pop(false);
          },
        ),
        FButton(
          label: const Text("Leave"),
          onPress: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    ),
  );
}
