import 'package:flutter/material.dart';

/// A small labelled section heading used across screens.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}

/// Rounded padded surface used as the app's building block.
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(18)});

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: padding, child: child));
  }
}

/// Tappable 0..5 star rating.
class StarRating extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;
  final double size;
  const StarRating({super.key, required this.value, this.onChanged, this.size = 30});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value;
        final star = Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          color: filled ? color : Theme.of(context).colorScheme.outline,
          size: size,
        );
        if (onChanged == null) return star;
        return GestureDetector(
          onTap: () => onChanged!(i + 1 == value ? 0 : i + 1),
          child: Padding(padding: const EdgeInsets.only(right: 2), child: star),
        );
      }),
    );
  }
}

/// A compact stat chip (value + caption).
class StatPill extends StatelessWidget {
  final String value;
  final String caption;
  final IconData icon;
  const StatPill({super.key, required this.value, required this.caption, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: scheme.secondary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: scheme.secondary, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(caption,
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

/// Selectable chip for flavour tags / options.
class ChoiceTag extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const ChoiceTag({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? scheme.onPrimary : scheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
