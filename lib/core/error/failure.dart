import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class Failure extends Equatable {
  final int? code;
  final String message;

  const Failure({
    this.code,
    required this.message,
  });

  @override
  List<Object?> get props => [code, message];
}
