import 'package:flutter/material.dart';
import 'package:mseller/core/error/failure.dart';

class ErrorPage extends StatelessWidget {
  final Failure failure;

  const ErrorPage({
    Key? key,
    required this.failure,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(failure.message)),
    );
  }
}
