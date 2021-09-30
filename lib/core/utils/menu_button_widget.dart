import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class MenuBotton extends StatelessWidget {
  final Widget icon;
  final String label;
  final Widget page;

  const MenuBotton({
    Key? key,
    required this.icon,
    required this.label,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionDuration: const Duration(milliseconds: 700),
      closedColor: Theme.of(context).colorScheme.surface,
      closedBuilder: (context, action) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ],
      ),
      openBuilder: (context, action) => page,
    );
  }
}
