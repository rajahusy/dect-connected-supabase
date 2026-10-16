import 'package:dcet_master/core/app_state.dart';
import 'package:dcet_master/data/demo_repository.dart';
import 'package:dcet_master/screens/paper_attempt.dart';
import 'package:dcet_master/screens/resource_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('library categories and previous paper detail route work',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.load();
    await tester.pumpWidget(MaterialApp(
        home: ResourceLibrary(state: state, repo: DemoRepository())));
    expect(find.text('DCET RESOURCE DESK'), findsOneWidget);
    await tester.tap(find.text('Question Papers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DCET 2025 question paper'));
    await tester.pumpAndSettle();
    expect(find.byType(PreviousPaperPage), findsOneWidget);
    expect(find.text('Previous paper source desk'), findsOneWidget);
  });

  testWidgets('subscriber can open and score a model paper route',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.load();
    await state.activateDemo(const Duration(days: 1));
    await tester.pumpWidget(MaterialApp(
        home: ModelPaperPage(
            number: 1, repository: DemoRepository(), state: state)));
    expect(find.textContaining('Question 1/20'), findsOneWidget);
    expect(find.byType(RadioListTile<int>), findsWidgets);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('wide library remains constrained and shows all categories',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.load();
    await tester.pumpWidget(MaterialApp(
        home: ResourceLibrary(state: state, repo: DemoRepository())));
    for (final label in [
      'Syllabus',
      'Question Papers',
      'Notes',
      'Cutoffs',
      'Updates'
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
