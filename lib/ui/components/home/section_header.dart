import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';

// Cabeçalho de seção: título da aba + contador de notas + divisor inferior.
class SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const SectionHeader({
    super.key,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(title, style: AppTheme.sectionTitle),
              const SizedBox(width: 10),
              Text(
                '$count ${count == 1 ? 'nota' : 'notas'}',
                style: AppTheme.sectionCount,
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppTheme.line),
      ],
    );
  }
}
