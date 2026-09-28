import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_assessment_app/screens/image_viewer_screen.dart';

void main() {
  testWidgets('Image viewer closes safely without starting a zoom animation', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ImageViewerScreen(images: [''])),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
