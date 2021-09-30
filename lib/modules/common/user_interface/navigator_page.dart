import 'package:animations/animations.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mseller/core/error/error_page.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:mseller/core/router/app_router.dart';
import 'package:mseller/modules/billing/user_interface/billing_page.dart';
import 'package:mseller/modules/management/user_interface/pages/management_page.dart';

const bottomNavigationBarItems = [
  BottomNavigationBarItem(icon: Icon(Icons.local_mall_rounded), label: "Ventas"),
  BottomNavigationBarItem(icon: Icon(Icons.inventory_rounded), label: "Administración"),
];

class NavigatorCubit extends Cubit<int> {
  NavigatorCubit() : super(0);

  void changeIndex(int index) => emit(index);
}

class NavigatorPage extends StatelessWidget {
  const NavigatorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigatorCubit(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Bienvenido a MSeller"),
                Text("Usuario: Admin", style: TextStyle(fontSize: 12)),
              ],
            ),
            actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.logout))],
          ),
          body: BlocBuilder<NavigatorCubit, int>(
            builder: (context, index) {
              Widget selectedPage;

              switch (index) {
                case 0:
                  selectedPage = const BillingPage();
                  break;
                case 1:
                  selectedPage = const ManagementPage();
                  break;
                default:
                  selectedPage = const ErrorPage(
                    failure: Failure(message: pageNotFoundErrorMessage),
                  );
                  break;
              }

              return PageTransitionSwitcher(
                child: selectedPage,
                transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                  return FadeThroughTransition(
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  );
                },
              );
            },
          ),
          bottomNavigationBar: BlocBuilder<NavigatorCubit, int>(
            builder: (context, index) => BottomNavigationBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              onTap: (selectedIndex) =>
                  context.read<NavigatorCubit>().changeIndex(selectedIndex),
              currentIndex: index,
              items: bottomNavigationBarItems,
            ),
          ),
        );
      }),
    );
  }
}
