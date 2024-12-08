import "dart:convert";
import "package:avert/core/core.dart";
import "package:crypto/crypto.dart";

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

bool isNew(Document document) {
  return document.id == 0;
}

String getDate(DateTime datetime) {
  return datetime.toString().split(" ")[0];
}

String getLastDayDate(String date) {
  DateTime startDT = DateTime.parse(date);
  int days = 364;
  if ((isLeapYear(startDT.year) && startDT.month < 3) ||
    isLeapYear(startDT.year + 1) && startDT.month > 2) {
    days = 365;
  }
  DateTime lastDayDT = startDT.add(Duration(days: days));
  return getDate(lastDayDT);
}

bool isLeapYear(int year) {
  return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
}

Digest hashString(String string) {
  var bytes = utf8.encode(string);
  return sha256.convert(bytes);
}

