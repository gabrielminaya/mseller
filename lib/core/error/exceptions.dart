import 'package:flutter/cupertino.dart';

@immutable
class SystemError implements Exception {
  final String message;

  const SystemError({
    required this.message,
  });
}
