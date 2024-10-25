// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tourguideapp/main.dart';

void main() {
  testWidgets('Kiểm tra tăng bộ đếm', (WidgetTester tester) async {
    // Xây dựng ứng dụng và kích hoạt một khung hình
    await tester.pumpWidget(MyApp(showOnboarding: false));

    // Xác minh rằng bộ đếm của chúng ta bắt đầu từ 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
