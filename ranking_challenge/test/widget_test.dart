import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ranking_challenge/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RankingChallengeApp(),
      ),
    );

    // Verify home screen is displayed
    expect(find.text('ランキング'), findsOneWidget);
    expect(find.text('チャレンジ'), findsOneWidget);
  });
}
