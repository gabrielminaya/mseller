import 'package:flutter/material.dart';
import 'package:mseller/core/error/error_page.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:mseller/modules/auth/user_interface/splash_page.dart';
import 'package:mseller/modules/common/user_interface/navigator_page.dart';
import 'package:mseller/modules/management/user_interface/pages/category_page.dart';
import 'package:mseller/modules/management/user_interface/pages/management_page.dart';
import 'package:mseller/modules/management/user_interface/pages/item_page.dart';
import 'package:mseller/modules/management/user_interface/pages/unit_page.dart';

void pushPage(BuildContext context, Widget page) async {
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => page),
  );
}

void pushReplacementPage(BuildContext context, Widget page) async {
  await Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => page),
  );
}

void pushReplacementNamed(BuildContext context, String name) async {
  await Navigator.of(context).pushReplacementNamed(name);
}

void pushNamed(BuildContext context, String name) async {
  await Navigator.of(context).pushNamed(name);
}

void pop(BuildContext context) {
  Navigator.of(context).pop();
}

@immutable
class RouteNames {
  static const splashPage = "/";
  static const dashboardPage = "/dashboard";
  static const inventoryPage = "/inventory";
  static const navigatorPage = "/navigator";
  static const warehousePage = "/warehouse";
  static const categoryPage = "/category";
  static const itemPage = "/item";
  static const unitPage = "/unit";
}

const pageNotFoundErrorMessage = "Page not found";

@immutable
class AppRoute {
  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splashPage:
        return MaterialPageRoute(builder: (context) => const SplashPage());
      case RouteNames.navigatorPage:
        return MaterialPageRoute(builder: (context) => const NavigatorPage());
      case RouteNames.dashboardPage:
        return MaterialPageRoute(builder: (context) => const Scaffold());
      case RouteNames.inventoryPage:
        return MaterialPageRoute(builder: (context) => const ManagementPage());
      case RouteNames.itemPage:
        return MaterialPageRoute(builder: (context) => const ItemPage());
      case RouteNames.categoryPage:
        return MaterialPageRoute(builder: (context) => const CategoryPage());
      case RouteNames.unitPage:
        return MaterialPageRoute(builder: (context) => const UnitPage());
      default:
        return MaterialPageRoute(
          builder: (context) => const ErrorPage(
            failure: Failure(message: pageNotFoundErrorMessage),
          ),
        );
    }
  }
}
