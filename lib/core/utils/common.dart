import "package:avert/core/core.dart";
import "package:flutter/material.dart";
import "./logger.dart";

void notifyUpdate(BuildContext context, String msg) {
  final SnackBar snackBar = SnackBar(
    showCloseIcon: true,
    content: Center(
      child: Text(msg),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<bool?> confirmPop(BuildContext context) {
  printWarn("showing pop confirmation dialog");
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Are you sure?"),
        content: const Text("Are you sure you want to leave this page?"),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Stay"),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            onPressed: () {
              Navigator.pop(context, true);
              //popDocument(context);
            },
            child: const Text("Leave"),
          ),
        ],
      );
    },
  );
}

Future<bool?> promptConfirmPop(BuildContext context, String title) {
  printWarn("showing pop confirmation dialog");
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Are you sure?"),
        content: const Text("Are you sure you want to leave this page?"),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Stay"),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            onPressed: () {
              Navigator.pop(context, true);
              //popDocument(context);
            },
            child: const Text("Leave"),
          ),
        ],
      );
    },
  );
}

/// Checks whether the document is new.
/// Document is new if its ID is zero.
bool isNew(Document document) {
  return document.id == 0;
}
