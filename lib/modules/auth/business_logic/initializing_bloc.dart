import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:mseller/core/database/database.dart';
import 'package:mseller/core/di/di.dart';

enum InitializingEvent { initDb, initDependecies }

enum InitializingState { initial, initializedDatabase, initializedDependecies, error }

class InitializingBloc extends Bloc<InitializingEvent, InitializingState> {
  InitializingBloc() : super(InitializingState.initial) {
    on<InitializingEvent>((event, emit) async {
      try {
        switch (event) {
          case InitializingEvent.initDb:
            await AppDatabase.instance.database;
            emit(InitializingState.initializedDatabase);
            add(InitializingEvent.initDependecies);
            break;
          case InitializingEvent.initDependecies:
            await initDependecies();
            emit(InitializingState.initializedDependecies);
            break;
        }
      } catch (error) {
        log(error.toString());
        emit(InitializingState.error);
      }
    });
  }
}
