import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_agent_app/main.dart';

void main() {
  testWidgets('App launches and shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AlgeoVerifyApp());
    expect(find.text('Algeo-Verify'), findsOneWidget);
    expect(find.text('Delivery Agent Portal'), findsOneWidget);
  });
}
