import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tic_tac_toe/screens/tutorial_screen.dart';

/// Pumps the tutorial on small phone screens. A "BOTTOM OVERFLOWED" error
/// is reported by Flutter as an exception, which fails the test.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // flutter_tts has no implementation in tests: answer every call.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (_) async => 1,
    );
  });

  for (final size in const [Size(320, 480), Size(360, 640), Size(640, 360)]) {
    for (final firstRun in [false, true]) {
      testWidgets('tutorial fits ${size.width}x${size.height} (firstRun: $firstRun)',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(home: TutorialScreen(firstRun: firstRun)),
        );
        await tester.pump();

        // Visit every page.
        final pages = firstRun ? 7 : 4;
        for (var i = 0; i < pages - 1; i++) {
          await tester.tap(find.textContaining('NEXT'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        expect(find.textContaining('GET STARTED'), findsOneWidget);
      });
    }
  }
}
