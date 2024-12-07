import "package:avert/core/core.dart";

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

/// Gets only the Date value of a DateTime by remove the Time String.
/// Ex. 2000-01-01 00:00:00:000 -> 2000-01-01
String getDate(DateTime datetime) {
  return datetime.toString().split(" ")[0];
}

/// Gets only the DateTime string represent of a date String.
/// NOTE: date string should be in this format 'YYYY-MM-DD'
/// Ex. 2000-01-01 -> 2000-01-01 00:00:00:000
String getDateTime(String date) {
  return "$date 00:00:00:000";
}

String addYearToDate(int year, String date) {
  List<String> dateStrings = date.split("-");
  // NOTE: year is index zero.
  int newYear = int.parse(dateStrings[0]) + year;
  dateStrings[0] = newYear.toString();
  return dateStrings.join("-");
}
