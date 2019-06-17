// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:sleep_destroyer/presentation/common.dart';
import 'package:sleep_destroyer/presentation/home.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(SleepDestroyer());

  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);

  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();

  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });
  group('LoadingIndicator', () {
    testWidgets('LoadingIndicator should have circular progress indicator', (WidgetTester tester) async {
      await tester.pumpWidget(LoadingIndicator());

      final indicatorFinder = find.byType(CircularProgressIndicator);

      expect(indicatorFinder, findsOneWidget);
    });
  });

  group('home.dart', () {
    // group('AlarmSwitch', () {
    //   testWidgets('AlarmSwitch should have "blue" color when on', (WidgetTester tester) async {
    //     await tester.pumpWidget(AlarmSwitch(turnedOn: true));


    //   });
    // });
    group('TimeMenu', () {
      NavigatorObserver mockObserver;

      setUp(() {
        mockObserver = MockNavigatorObserver();
      });

      testWidgets('Should route to TimeSettingPage on tapped', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: TimeMenu(timeSet: true),
          ),
          navigatorObservers: [mockObserver],
        ));
        
        var timeMenuFinder = find.byType(TimeMenu);
        expect(timeMenuFinder, findsOneWidget);

        await tester.tap(timeMenuFinder);
        await tester.pumpAndSettle();
        verify(mockObserver.didPush(any, any));
      });
    });

    group('LocationMenu', () {
      NavigatorObserver mockObserver;

      setUp(() {
        mockObserver = MockNavigatorObserver();
      });

      testWidgets('Should route to LocationSettingPage on tapped', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: LocationMenu(locationSet: true),
          ),
          navigatorObservers: [mockObserver],
        ));

        var locationMenuFinder = find.byType(LocationMenu);
        expect(locationMenuFinder, findsOneWidget);

        await tester.tap(locationMenuFinder);
        await tester.pumpAndSettle();
        verify(mockObserver.didPush(any, any));
      });
    });

    group('RingtoneMenu', () {
      NavigatorObserver mockObserver;

      setUp(() {
        mockObserver = MockNavigatorObserver();
      });

      testWidgets('Should route to RingtoneSettingPage on tapped', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: RingtoneMenu(ringtoneSet: true),
          ),
          navigatorObservers: [mockObserver],
        ));

        var ringtoneMenuFinder = find.byType(RingtoneMenu);
        expect(ringtoneMenuFinder, findsOneWidget);

        await tester.tap(ringtoneMenuFinder);
        await tester.pumpAndSettle();
        verify(mockObserver.didPush(any, any));
      });
    });
  });
}
