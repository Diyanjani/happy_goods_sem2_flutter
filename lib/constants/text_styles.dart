import 'package:flutter/material.dart';

class TextStyles {
  static TextStyle heading(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold);
  }

  static TextStyle subheading(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w400);
  }
}
