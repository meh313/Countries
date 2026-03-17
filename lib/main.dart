import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// Boots the countries application.
void main() {
  runApp(const ProviderScope(child: CountriesApp()));
}
