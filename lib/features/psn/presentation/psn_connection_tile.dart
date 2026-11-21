import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/utils/time/time_format.dart';
import 'package:trophies_tracker/core/widgets/connection_tile.dart';
import 'package:trophies_tracker/features/psn/domain/psn_models.dart';
import 'package:trophies_tracker/features/psn/presentation/cubit/psn_cubit.dart';
import 'package:trophies_tracker/features/psn/presentation/cubit/psn_state.dart';

/// What to tell the user about a [PsnFailure].
String psnFailureMessage(PsnFailure failure) => switch (failure) {
  PsnFailure.tokenExpired =>
    'Your PlayStation link has expired. Link it again to keep syncing.',
  PsnFailure.rejected => 'PlayStation refused the link. Try again.',
  PsnFailure.invalidRequest => 'The link could not be completed. Try again.',
  PsnFailure.unavailable =>
    'PlayStation could not be reached. Try again in a moment.',
};

/// How long the link still lasts, as a line for the row: the days left, or
/// that it has run out.
String psnLinkLine(PsnLink link, DateTime now) {
  if (link.isExpired(now)) return 'Link expired';
  final days = link.daysLeft(now);
  if (days == null) return '';
  if (days == 0) return 'Link expires within a day';
  return days == 1 ? 'Link expires in 1 day' : 'Link expires in $days days';
}

/// The warning that the connection is not official, always under the row.
const psnUnofficialNotice =
    'Not affiliated with Sony. The PlayStation connection is unofficial and '
    'may stop working.';

/// The PlayStation account as a row of the connections list: the name, the
/// last sync and the state of the link, with sync and unlink when linked, a
/// button to link again when the link has run out, or one to link it.
///
/// The days left of the link show only when they are three or fewer.
class PsnConnectionTile extends StatelessWidget {
  /// Only here so a test can fix the time.
  final DateTime Function() now;

  const PsnConnectionTile({super.key, this.now = DateTime.now});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PsnCubit, PsnState>(
      builder: (context, state) {
        final link = state.link;
        final time = now();
        final needsLogin = state.loginNeeded(time);
        final failure = state.failure;
        final days = link?.daysLeft(time);
        final syncing = state.phase == PsnPhase.syncing;
        final cubit = context.read<PsnCubit>();

        final lines = <ConnectionLine>[];
        if (link == null) {
          lines.add(const ConnectionLine('Not linked'));
        } else if (syncing) {
          lines.add(
            ConnectionLine(
              state.total == 0
                  ? 'Checking your library…'
                  : 'Syncing ${state.done} of ${state.total} games',
            ),
          );
        } else {
          final last = link.lastSync;
          lines.add(
            ConnectionLine(
              '${link.onlineId ?? 'PlayStation account'} · '
              '${last == null ? 'Not synced yet' : 'Synced ${formatRelative(last, now: time)}'}',
            ),
          );
        }
        if (link != null && !syncing) {
          if (needsLogin) {
            lines.add(
              ConnectionLine(
                failure == PsnFailure.tokenExpired
                    ? psnFailureMessage(failure!)
                    : 'Link expired. Link again to keep syncing.',
                warn: true,
              ),
            );
          } else if (days != null && days <= 3) {
            lines.add(ConnectionLine(psnLinkLine(link, time), warn: true));
          }
        }
        if (failure != null && failure != PsnFailure.tokenExpired) {
          lines.add(ConnectionLine(psnFailureMessage(failure), warn: true));
        }
        return ConnectionTile(
          icon: Symbols.sports_esports_rounded,
          title: 'PlayStation',
          lines: lines,
          busy: syncing,
          progress: state.total == 0 ? null : state.done / state.total,
          footnote: psnUnofficialNotice,
          actions: [
            if (link == null || needsLogin)
              ConnectionButton(
                label: link == null ? 'Link' : 'Link again',
                busy: state.phase == PsnPhase.loggingIn,
                onPressed: state.busy ? null : cubit.login,
              )
            else
              ConnectionSyncButton(busy: state.busy, onPressed: cubit.sync),
            if (link != null)
              ConnectionMenu(enabled: !state.busy, onLogout: cubit.logout),
          ],
        );
      },
    );
  }
}
