import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/navigation_provider.dart';

void navigateTo(BuildContext context, String screen, {Object? arg}) {
  ProviderScope.containerOf(
    context,
    listen: false,
  ).read(navigationProvider.notifier).navigate(screen, arg: arg);
}

void navigateBack(BuildContext context) {
  ProviderScope.containerOf(
    context,
    listen: false,
  ).read(navigationProvider.notifier).goBack();
}
