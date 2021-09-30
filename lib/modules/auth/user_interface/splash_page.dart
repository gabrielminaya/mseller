import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mseller/core/error/error_page.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:mseller/core/router/app_router.dart';
import 'package:mseller/modules/auth/business_logic/initializing_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<InitializingBloc, InitializingState>(
        listener: (context, state) {
          if (state == InitializingState.initializedDependecies) {
            pushReplacementNamed(context, RouteNames.navigatorPage);
          }
        },
        builder: (context, state) {
          switch (state) {
            case InitializingState.initial:
              return const Center(child: Text("Initializing Database..."));
            case InitializingState.initializedDatabase:
              return const Center(child: Text("Initializing Dependecies..."));
            case InitializingState.initializedDependecies:
              return const Center(child: Text("Done."));
            case InitializingState.error:
              return const ErrorPage(
                failure: Failure(message: "Error al inicializar la apliación"),
              );
          }
        },
      ),
    );
  }
}
