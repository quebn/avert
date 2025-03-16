import "dart:convert";
import "package:avert/core/core.dart";
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
