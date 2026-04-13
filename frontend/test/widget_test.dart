import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/main.dart';

void main() {
  testWidgets('fallback error app renders message', (WidgetTester tester) async {
    await tester.pumpWidget(const FallbackErrorApp(error: 'init failed'));

    expect(find.text('App Initialization Error'), findsOneWidget);
    expect(find.text('init failed'), findsOneWidget);
  });
}
