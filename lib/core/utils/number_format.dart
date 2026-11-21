/// `1234` as `1,234`.
String formatCount(int value) {
  final digits = value.abs().toString();
  final groups = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    groups.insert(0, digits.substring(end < 3 ? 0 : end - 3, end));
  }
  return '${value < 0 ? '-' : ''}${groups.join(',')}';
}
