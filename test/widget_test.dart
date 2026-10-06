import 'package:flutter_test/flutter_test.dart';
import 'package:mediathek_app/main.dart';

void main() {
  testWidgets('MediathekApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MediathekApp());
    expect(
      find.text('Willkommen in deiner Mediathek!\nBackend-Anbindung folgt.'),
      findsOneWidget,
    );
  });
}
