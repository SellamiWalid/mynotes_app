import 'dart:io';

String getOs() {
  return Platform.operatingSystem;
}

final englishRegex = RegExp(r'[A-Za-z]');

final arabicRegex = RegExp(r'[\u0600-\u06FF]');