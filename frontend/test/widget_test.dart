// CropChain Widget Test
// TODO: Add widget tests when screens are ready for testing
import 'package:flutter_test/flutter_test.dart';
import 'package:cropchain_frontend/main.dart';

void main() {
  testWidgets('CropChain app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CropChainApp());
    expect(find.byType(CropChainApp), findsOneWidget);
  });
}
