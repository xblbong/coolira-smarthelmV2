import 'package:flutter_test/flutter_test.dart';
import 'package:coolora_app_aja/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const CooliraApp());
    expect(find.text('Selamat Pagi, Rayyan 🌤️'), findsOneWidget);
  });
}
