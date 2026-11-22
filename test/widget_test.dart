import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/main.dart';

void main() {
  testWidgets('NEON XO Game app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MyApp), findsOneWidget);
    expect(find.text('NEON XO Admin'), findsNothing);
    expect(find.text('ADMIN PANEL'), findsNothing);
  });
}