import "package:flutter/material.dart";

enum LogLevel {
  debug ,
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

void printLog(String text, {LogLevel level = LogLevel.debug}) {
  switch (level) {
    case LogLevel.debug:
      debugPrint("\x1B[34m [DEBUG]: $text\x1B[0m");
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
