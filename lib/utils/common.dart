import "dart:convert";
import "package:avert/docs/accounting.dart";
import "package:avert/docs/document.dart";
import "package:avert/utils/logger.dart";
import "package:crypto/crypto.dart";

bool isNew(Document document) {
  return document.id == 0;
}

String getDate(DateTime datetime) {
  return datetime.toString().split(" ")[0];
}

String getLastDayString(String date) {
  DateTime startDT = DateTime.parse(date);
  int days = 364;
  if ((isLeapYear(startDT.year) && startDT.month < 3) ||
    isLeapYear(startDT.year + 1) && startDT.month > 2) {
    days = 365;
  }
  DateTime lastDayDT = startDT.add(Duration(days: days));
  return getDate(lastDayDT);
}

DateTime getLastDayDate(DateTime start) {
  int days = 364;
  if ((isLeapYear(start.year) && start.month < 3) ||
    isLeapYear(start.year + 1) && start.month > 2) {
    days = 365;
  }
  DateTime end = start.add(Duration(days: days));
  return end;
}

bool isLeapYear(int year) {
  return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
}

Digest hashString(String string) {
  var bytes = utf8.encode(string);
  return sha256.convert(bytes);
}

String getAcronym(String name) {
  List<String> letters = [];

  List<String> words = name.split(" ");

  for (String word in words) {
    if (word.isEmpty) continue;
    letters.add(word[0]);
  }
  return letters.join();
}

String titleCase(String string) {
  return "${string[0].toUpperCase()}${string.substring(1)}";
}

AccountValue getAccountingEntriesDiff(List<AccountingEntry> entries) {
  AccountValue diff = AccountValue.zero();
  if (entries.isEmpty) return diff;
  for (AccountingEntry entry in entries) {
    printInfo("Entry value: ${entry.value.toString()} ");
    diff += entry.value;
    // printInfo("Diff value: ${diff.toString()} ");
  }
  return diff;
}

const Map<int, String> months = {
  1:"January", 2:"February", 3:"March", 4:"April",
  5:"May", 6:"June", 7:"July", 8:"August",
  9:"September", 10:"October", 11:"November", 12:"December",
};

String formatDT(DateTime dt) {
  final String month = months[dt.month]!;
  final String hour = dt.hour.toString().padLeft(1,"0");
  final String minute = dt.minute.toString().padLeft(1,"0");
  return "${dt.year}, $month ${dt.day}, $hour:$minute";
}
