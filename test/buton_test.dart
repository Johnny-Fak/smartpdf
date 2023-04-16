import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finalpdf/widgets/header.dart';

void main() {
  group('Buton widget', () {
    // your tests here
  });
  testWidgets('Builds Buton widget', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: Buton()));
  expect(find.byType(Buton), findsOneWidget);
});

testWidgets('Contains two buttons', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: Buton()));
  expect(find.byType(ElevatedButton), findsNWidgets(2));
});

testWidgets('PDF to TXT button', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: Buton()));

  // Tap the first button
  await tester.tap(find.text('PDF to TXT'));
  await tester.pumpAndSettle();

  // Verify that the file picker is opened
  expect(find.byType(FilePicker), findsOneWidget);

  // You can also simulate a file being picked to test the rest of the functionality
  // ...
});

testWidgets('TXT to PDF button', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: Buton()));

  // Tap the second button
  await tester.tap(find.text('TXT to PDF'));
  await tester.pumpAndSettle();

  // Verify that the file picker is opened
  expect(find.byType(FilePicker), findsOneWidget);

  // You can also simulate a file being picked to test the rest of the functionality
  // ...
});

testWidgets('PDF creation test', (WidgetTester tester) async {
    // Build the Buton widget
    await tester.pumpWidget(const Buton());

    // Call the _createPDF function
    await tester.tap(find.text('PDF to TXT'));
    await tester.pump();

    // Verify that the PDF creation process was started
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the process to complete
    await tester.pumpAndSettle();

    // Verify that the PDF was created successfully
    expect(find.text('PDF created successfully!'), findsOneWidget);
  });
}

