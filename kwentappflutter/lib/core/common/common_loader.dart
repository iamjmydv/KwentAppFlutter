import 'package:flutter/material.dart';

class CommonLoader extends StatelessWidget {
  const CommonLoader({super.key, this.size = 28, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          strokeWidth: size <= 20 ? 2 : 3,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
