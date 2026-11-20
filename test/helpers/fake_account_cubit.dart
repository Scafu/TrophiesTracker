import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_state.dart';

/// An [AccountCubit] that only holds a state: the real one listens for deep
/// links through a plugin that does not exist in widget tests.
class FakeAccountCubit extends Cubit<AccountState> implements AccountCubit {
  FakeAccountCubit([super.initialState = const AccountState.unauthenticated()]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
