import 'package:flutter/material.dart';

void showSnackBarMessage({required BuildContext context, required String message}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: "Close",
        onPressed: () => ScaffoldMessenger.of(context).removeCurrentSnackBar(),
      ),
    ),
  );
}
