import 'package:flutter_test/flutter_test.dart';

import 'package:product_assessment_app/main.dart';

void main() {
  testWidgets('App launches and displays the Products heading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProductAssessmentApp());
    await tester.pump();

    expect(find.text('Products'), findsOneWidget);
  });
}
