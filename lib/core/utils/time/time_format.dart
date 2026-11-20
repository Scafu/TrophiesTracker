const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// `Mar` for month 3 (1-12).
String monthAbbreviation(int month) => _months[month - 1];

/// `12 Mar 2025`.
String formatShortDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

/// How long ago [date] was, as `just now`, `5 min ago`, `3 h ago` or
/// `2 d ago`; from 30 days on it falls back to the date itself.
///
/// [now] only exists so the result can be tested.
String formatRelative(DateTime date, {DateTime? now}) {
  final elapsed = (now ?? DateTime.now()).difference(date);

  if (elapsed.inMinutes < 1) return 'just now';
  if (elapsed.inMinutes < 60) return '${elapsed.inMinutes} min ago';
  if (elapsed.inHours < 24) return '${elapsed.inHours} h ago';
  if (elapsed.inDays < 30) return '${elapsed.inDays} d ago';
  return formatShortDate(date);
}
