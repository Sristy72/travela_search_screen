import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travela_search_screen/main.dart';

void main() {
  testWidgets('App renders PropertySearchScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
