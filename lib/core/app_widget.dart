import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mseller/core/router/app_router.dart';
import 'package:mseller/modules/auth/business_logic/auth_cubit.dart';
import 'package:mseller/modules/auth/business_logic/initializing_bloc.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appRoute = AppRoute();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => InitializingBloc()..add(InitializingEvent.initDb),
        ),
        BlocProvider(
          create: (context) => AuthCubit(),
        )
      ],
      child: MaterialApp(
        darkTheme: ThemeData(colorScheme: const ColorScheme.dark()),
        theme: ThemeData(
          colorScheme: const ColorScheme.light().copyWith(
            primary: Colors.indigo,
            secondary: Colors.pink,
            onSecondary: Colors.white,
            onPrimary: Colors.white,
          ),
        ),
        onGenerateRoute: appRoute.onGenerateRoute,
        initialRoute: RouteNames.splashPage,
      ),
    );
  }
}
