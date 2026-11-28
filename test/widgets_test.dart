import 'package:tic_tac_toe/security/secure_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tic_tac_toe/models/mark.dart';
import 'package:tic_tac_toe/screens/ad_countdown_screen.dart';
import 'package:tic_tac_toe/services/house_ad_service.dart';
import 'package:tic_tac_toe/widgets/board_widget.dart';

void main() {
  setUp(() {
    SecurePrefs.setMockInitialValues({'sound': false});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (_) async => 1,
    );
  });

  group('BoardWidget', () {
    Future<List<int>> pumpBoard(WidgetTester tester, List<Mark?> board,
        {int? hint}) async {
      final taps = <int>[];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: BoardWidget(
              board: board,
              winLine: null,
              hintCell: hint,
              onTap: taps.add,
            ),
          ),
        ),
      ));
      return taps;
    }

    testWidgets('screen reader labels describe every cell', (tester) async {
      final handle = tester.ensureSemantics();
      final board = List<Mark?>.filled(9, null)..[1] = Mark.x..[4] = Mark.o;
      await pumpBoard(tester, board, hint: 8);

      expect(find.bySemanticsLabel('Row 1, column 1, empty'), findsOneWidget);
      expect(find.bySemanticsLabel('Row 1, column 2, X'), findsOneWidget);
      expect(find.bySemanticsLabel('Row 2, column 2, O'), findsOneWidget);
      expect(find.bySemanticsLabel('Row 3, column 3, empty, suggested move'),
          findsOneWidget);
      handle.dispose();
    });

    testWidgets('tapping a cell reports its index', (tester) async {
      final taps = await pumpBoard(tester, List<Mark?>.filled(9, null));
      await tester.tap(find.bySemanticsLabel('Row 2, column 3, empty'));
      expect(taps, [5]);
    });
  });

  group('AdCountdownScreen', () {
    const ad = HouseAd(
      id: 'a1',
      title: 'Neon Sale',
      message: 'Half price skins',
      imageUrl: null,
      countdownSeconds: 15,
    );

    testWidgets('continue is locked until the 15 s countdown ends',
        (tester) async {
      bool? result;

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await AdCountdownScreen.show(context, ad);
            },
            child: const Text('open'),
          ),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Neon Sale'), findsOneWidget);
      expect(find.text('CONTINUE IN 15 s'), findsOneWidget);

      final button = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(button).onPressed, isNull);

      await tester.pump(const Duration(seconds: 10));
      expect(find.text('CONTINUE IN 5 s'), findsOneWidget);
      expect(tester.widget<ElevatedButton>(button).onPressed, isNull);

      await tester.pump(const Duration(seconds: 5));
      expect(find.text('CONTINUE'), findsOneWidget);
      expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.text('Neon Sale'), findsNothing);
    });
  });
}
