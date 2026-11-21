import 'package:flutter/material.dart';

/// A small label with the console of a PlayStation game (`PS5`), made to sit
/// on a cover: white on a dark pill, so it reads over any art.
class ConsoleChip extends StatelessWidget {
  final String label;

  const ConsoleChip(this.label, {super.key});

  /// What to write for [consoles]: `PS4/PS5`, in the order Sony lists them.
  static String labelFor(List<String> consoles) => consoles.join('/');

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
