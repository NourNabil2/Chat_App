import 'package:flutter/material.dart';

class CenteredTextDivider extends StatelessWidget {
  final String text;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color color;

  const CenteredTextDivider({
    Key? key,
    required this.text,
    this.thickness = 1.0,
    this.indent = 20.0,
    this.endIndent = 20.0,
    this.color = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left side divider
        Expanded(
          child: Divider(
            thickness: thickness,
            color: color,
            endIndent: 10, // Space between the divider and the text
            indent: indent,
          ),
        ),
        // Text in the center
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
          ),
        ),
        // Right side divider
        Expanded(
          child: Divider(
            thickness: thickness,
            color: color,
            indent: 10, // Space between the divider and the text
            endIndent: endIndent,
          ),
        ),
      ],
    );
  }
}
