import 'package:flutter/material.dart';

class DayCircle extends StatelessWidget {
  final int dayNumber;
  final bool isCompleted;
  final bool isCurrent;
  final bool isFuture;
  final bool isDisabled;
  final VoidCallback? onTap;

  const DayCircle({
    super.key,
    required this.dayNumber,
    this.isCompleted = false,
    this.isCurrent = false,
    this.isFuture = false,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);
    final borderColor = _getBorderColor(context);

    return GestureDetector(
      onTap: isDisabled && !isCompleted ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: isCurrent ? 2.5 : 1,
          ),
        ),
        child: Center(
          child: isCompleted
              ? Icon(
                  Icons.check,
                  size: 18,
                  color: Colors.white,
                )
              : Text(
                  '$dayNumber',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDisabled || isFuture
                            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.38)
                            : null,
                      ),
                ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (isCompleted) {
      return Theme.of(context).colorScheme.primary;
    } else if (isCurrent) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.1);
    } else {
      return Colors.transparent;
    }
  }

  Color _getBorderColor(BuildContext context) {
    if (isCompleted || isCurrent) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.outline.withOpacity(0.3);
    }
  }
}