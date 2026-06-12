import 'package:flutter/material.dart';

/// Global locale notifier. Wrap [MaterialApp] in a [ValueListenableBuilder]
/// on this notifier to get live locale switching without a state-management package.
final localeNotifier = ValueNotifier<Locale>(const Locale('en'));
