import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Wraps child content in a centered, width-constrained layout on web.
/// On mobile the child is returned as-is — zero overhead.
class WebWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const WebWrapper({
    super.key,
    required this.child,
    this.maxWidth = 650,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
