import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:perf_widget_demo/main.dart' as app;
import 'perf_widget.dart';

void main() {
  perfWidget(
    'Counter increments smoke test',
    (WidgetController controller) async {
      // Build our app and trigger a frame.
      app.main();
      // wait for loading the app
      await controller.pump(const Duration(milliseconds: 10));

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // Tap the '+' icon and trigger a frame.
      await controller.tap(find.byIcon(Icons.add));
      await controller.pump(const Duration(milliseconds: 20));

      // Verify that our counter has incremented.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);

      // This is not necessary, I put it here just to wait before exit to see result
      await controller.pump(const Duration(seconds: 5));
  });
}
