import "package:flutter/material.dart";
import "package:forui/forui.dart";
import "logger.dart";


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
          style: FButtonStyle.outline,
          onPress: () {
            Navigator.of(context).pop(false);
          },
          label: const Text("Stay"),
        ),
        FButton(
          onPress: () {
            Navigator.of(context).pop(true);
          },
          label: const Text("Leave"),
        ),
      ],
    ),
  );
}
