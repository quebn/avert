import "package:flutter/material.dart";

enum LogLevel {
  log,
  warn,
  error,
  success,
}

// Black:   \x1B[30m
// Red:     \x1B[31m
// Green:   \x1B[32m
// Yellow:  \x1B[33m
// Blue:    \x1B[34m
// Magenta: \x1B[35m
// Cyan:    \x1B[36m
// White:   \x1B[37m
// Reset:   \x1B[0m

void printLog(String text) {
  // Green:   \x1B[32m
  debugPrint("\x1B[32m [LOG]: $text\x1B[0m");
}

void printWarn(String text) {
  // Yellow:  \x1B[33m
  debugPrint("\x1B[33m [WARN]: $text\x1B[0m");
}

void printError(String text) {
  // Red:     \x1B[31m
  debugPrint("\x1B[31m [ERROR]: $text\x1B[0m");
}

void printSuccess(String text) {
  // Cyan:    \x1B[36m
  debugPrint("\x1B[36m [SUCCESS]: $text\x1B[0m");
}

void printDebug(String text, {LogLevel level = LogLevel.log}) {
  switch (level) {
    case LogLevel.log:
      debugPrint("\x1B[32m [LOG]: $text\x1B[0m");
      break;
    case LogLevel.warn:
      debugPrint("\x1B[33m [WARN]: $text\x1B[0m");
      break;
    case LogLevel.error:
      debugPrint("\x1B[31m [ERROR]: $text\x1B[0m");
      break;
    case LogLevel.success:
      debugPrint("\x1B[32m [ERROR]: $text\x1B[0m");
      break;
  }
}

// NOTE: currently a soft assert.
// TODO: turn this into a proper assert that exits or freezes the app when on assert.
void printAssert(bool assertCondition, String errMsg) {
  if (!assertCondition) {
    printDebug("[ASSERTION FAILED]: $errMsg", level: LogLevel.error);
  }
}
