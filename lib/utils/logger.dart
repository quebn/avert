import "package:flutter/foundation.dart";

enum LogLevel {
  log,
  warn,
  error,
  success,
}

int trackingID = 0;
void printTrack(String text, {String id = "" }) {
  // Cyan:    \x1B[36m
  if (kReleaseMode) return;
  debugPrint("\x1B[36m------------------------------------------------\x1B[0m");
  debugPrint("\x1B[36m [Track ID:${id == "" ? trackingID : id}]: $text\x1B[0m");
  debugPrint("\x1B[36m------------------------------------------------\x1B[0m");
  if (id == "") trackingID++;
}

void printInfo(String text) {
  // Green:   \x1B[32m
  if (kReleaseMode) return;
  debugPrint("\x1B[32m [INFO]: $text\x1B[0m");
}

void printWarn(String text) {
  // Yellow:  \x1B[33m
  if (kReleaseMode) return;
  debugPrint("\x1B[33m [WARN]: $text\x1B[0m");
}

void printError(String text) {
  // Red:     \x1B[31m
  if (kReleaseMode) return;
  debugPrint("\x1B[31m [ERROR]: $text\x1B[0m");
}

void printSuccess(String text) {
  // Blue:    \x1B[34m
  if (kReleaseMode) return;
  debugPrint("\x1B[34m [SUCCESS]: $text\x1B[0m");
}

void printImplement(String errMsg) {
  // Magenta: \x1B[35m
  throw UnimplementedError("\x1B[35m[ASSERTION FAILED]: $errMsg\x1B[0m");
}

void printAssert(bool assertCondition, String errMsg) {
  // Red:     \x1B[31m
  if (kReleaseMode) return;
  assert(assertCondition, "\x1B[33m[ASSERTION FAILED]: $errMsg\x1B[0m");
}
