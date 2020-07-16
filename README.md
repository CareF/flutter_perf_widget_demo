# perf_widget_demo

This serves as a demo of creating a testing interface using `WidgetController`
as a common ground for our different test needs.

## how it works:

`test/perf_widget.dart` is considered the new interface to address
https://github.com/flutter/flutter/issues/61511

`test/testOps.dart` is how user should write the test for the new interface.
Itself can be used as a live test by running `flutter test test/testOps.dart`
or as a test app by `flutter run test/testOps.dart`.

`e2e.dart` shows if we want to use the test for `e2e`, to make compatible with
`flutter driver` or other platform.

`widget_test.dart` is how user should use the test as unit test.
