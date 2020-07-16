import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meta/meta.dart';

// ignore: deprecated_member_use
import 'package:test_api/test_api.dart' as test_package;

typedef PerfDriverCallback = Future<void> Function(WidgetController);

@isTest
void perfWidget(
  String description,
  PerfDriverCallback driver, {
  bool skip = false,
  test_package.Timeout timeout = const test_package.Timeout(Duration(minutes: 1)),
  Duration initialTimeout,
  bool semanticsEnabled = true,
  TestVariant<Object> variant = const DefaultTestVariant(),
  dynamic tags,
}) {
  assert(variant != null);
  assert(variant.values.isNotEmpty,
      'There must be at least on value to test in the testing variant');
  WidgetsBinding binding = WidgetsBinding.instance;
  if (binding is TestWidgetsFlutterBinding) {
    // For unit test and E2E
    testWidgets(
      description,
      (WidgetTester tester) => driver(tester),
      skip: skip,
      timeout: timeout,
      initialTimeout: initialTimeout,
      semanticsEnabled: semanticsEnabled,
      variant: variant,
      tags: tags,
    );
    return;
  } else if (binding == null || binding is WidgetsFlutterBinding) {
    assert(variant != null);
    assert(variant.values.isNotEmpty,
        'There must be at least on value to test in the testing variant');
    assert(timeout != null);
    binding = WidgetsFlutterBinding.ensureInitialized();
    final LiveWidgetController controller = LiveWidgetController(binding);
    for (final dynamic value in variant.values) {
      final String variationDescription = variant.describeValue(value);
      final String combinedDescription = variationDescription.isNotEmpty
          ? '$description ($variationDescription)'
          : description;
      test(
        combinedDescription,
        () async {
          SemanticsHandle semanticsHandle;
          if (semanticsEnabled == true) {
            // semanticsHandle = controller.ensureSemantics();
            // This can be promoted
          }
          // Not sure if we have this or just disable it
          // tester._recordNumberOfSemanticsHandles();

          runApp(Container(
              key: UniqueKey(),
              child: _preTestMessage)); // Reset the tree to a known state.
          await SchedulerBinding.instance.endOfFrame;
          // Pretend that the first frame produced in the test body is the first frame
          // sent to the engine.
          binding.resetFirstFrameSent();

          // run the test
          debugResetSemanticsIdCounter();
          // TODO(CareF): text input support?
          // tester.resetTestTextInput();
          Object memento;
          try {
            memento = await variant.setUp(value);
            await driver(controller);
          } finally {
            await variant.tearDown(value, memento);
          }
          semanticsHandle?.dispose();

          runApp(Container(
              key: UniqueKey(),
              child: _postTestMessage)); // Unmount any remaining widgets.
          await SchedulerBinding.instance.endOfFrame;
        },
        skip: skip,
        timeout: timeout,
        tags: tags,
      );
    }
  } else {
    throw UnimplementedError;
  }
}

const TextStyle _messageStyle = TextStyle(
  color: Color(0xFF917FFF),
  fontSize: 40.0,
);

const Widget _preTestMessage = Center(
  child: Text(
    'Test starting...',
    style: _messageStyle,
    textDirection: TextDirection.ltr,
  ),
);

const Widget _postTestMessage = Center(
  child: Text(
    'Test finished.',
    style: _messageStyle,
    textDirection: TextDirection.ltr,
  ),
);
