import 'package:flutter_test/flutter_test.dart';
import 'package:green_drop_frontend_v1/main.dart';

void main() {
  testWidgets('GreenDropApp loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GreenDropApp());

    // Verify that the title appears
    expect(find.textContaining('GreenDrop'), findsWidgets);
  });
}
