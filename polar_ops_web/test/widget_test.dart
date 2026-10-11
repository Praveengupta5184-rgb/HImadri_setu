// Basic smoke test for POLAR-OPS Web App
import 'package:flutter_test/flutter_test.dart';
import 'package:polar_ops_web/main.dart';

void main() {
  testWidgets('PolarOpsWebApp builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const PolarOpsWebApp());
    expect(find.byType(PolarOpsWebApp), findsOneWidget);
  });
}
