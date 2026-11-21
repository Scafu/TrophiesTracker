import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/widgets/tab_header.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_state.dart';

/// Opens the account page. Once logged in it shows the Steam avatar, so the
/// button also tells whether an account is linked.
class AccountButton extends StatelessWidget {
  const AccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    final avatar = context.watch<AccountCubit>().state.maybeWhen(
      authenticated: (user) => user.avatarUrl,
      orElse: () => null,
    );
    void open() => context.push('/accounts');

    if (avatar == null || avatar.isEmpty) {
      return RoundIconButton(
        icon: Symbols.settings_rounded,
        tooltip: 'Account and settings',
        onPressed: open,
      );
    }

    return Tooltip(
      message: 'Account and settings',
      child: Semantics(
        button: true,
        label: 'Account and settings',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: open,
          child: ClipOval(
            child: SizedBox(
              width: 44,
              height: 44,
              child: Image.network(
                avatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Symbols.account_circle_rounded,
                  size: 44,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
