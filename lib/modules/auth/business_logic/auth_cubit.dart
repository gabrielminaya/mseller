import 'package:bloc/bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class Authenticating extends AuthState {}

class Authenticated extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(Unauthenticated());

  void signIn({
    required String username,
    required String password,
  }) async {
    emit(Authenticating());
  }

  void signOut() => emit(Unauthenticated());
}
