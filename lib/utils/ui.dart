import "package:avert/ui/core.dart";
import "package:flutter/material.dart";
import "package:forui/forui.dart";

void notify(BuildContext context, String msg) {
  final SnackBar snackBar = SnackBar(
    showCloseIcon: true,
    duration: Duration(seconds: 2),
    content: Center(
      child: Text(msg),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<bool?> confirm(BuildContext context) {
  final List<Widget> buttons = [
    FButton(
      label: const Text("Stay"),
      style: FButtonStyle.outline,
      onPress: () => Navigator.of(context).pop(false),
    ),
    FButton(
      label: const Text("Leave"),
      onPress: () => Navigator.of(context).pop(true),
    ),
  ];
  return showAdaptiveDialog<bool>(
    context: context,
    builder: (BuildContext context) => FDialog(
      direction: Axis.horizontal,
      title: const Text("Are you sure?"),
      body: const Text("Are you sure you want to leave this page?"),
      actions: buttons,
    ),
  );
}

void onValueChange(void Function(void Function() fn) setState, DocumentForm form, bool Function() isDirtyCallback) {
  final bool isReallyDirty = isDirtyCallback();
  if (isReallyDirty == form.isDirty) return;
  setState(() => form.isDirty = isReallyDirty);
}
