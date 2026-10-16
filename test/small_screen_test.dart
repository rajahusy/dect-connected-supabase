import 'package:dcet_master/core/app_state.dart';
import 'package:dcet_master/main.dart';
import 'package:dcet_master/data/demo_repository.dart';
import 'package:dcet_master/screens/payments.dart';
import 'package:dcet_master/screens/legal_pages.dart';
import 'package:dcet_master/screens/paper_attempt.dart';
import 'package:dcet_master/screens/resource_library.dart';
import 'package:dcet_master/screens/video_learning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class EmptyStore implements PreferencesStore {
  @override
  Future<bool?> getBool(String k) async => null;
  @override
  Future<int?> getInt(String k) async => null;
  @override
  Future<String?> getString(String k) async => null;
  @override
  Future<List<String>?> getStringList(String k) async => null;
  @override
  Future<void> setBool(String k, bool v) async {}
  @override
  Future<void> setInt(String k, int v) async {}
  @override
  Future<void> setString(String k, String v) async {}
  @override
  Future<void> setStringList(String k, List<String> v) async {}
  @override
  Future<void> remove(String k) async {}
}

void main() {
  Future<void> setViewport(WidgetTester t, Size size,
      {double textScale = 1}) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = textScale;
  }

  testWidgets('welcome fits small phone', (t) async {
    t.view.physicalSize = const Size(320, 640);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    await t.pumpWidget(DcetApp(state: AppState(store: EmptyStore())));
    await t.pumpAndSettle();
    expect(find.text('Get started'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('shell has five destinations', (t) async {
    final s = AppState(store: EmptyStore());
    await s.load();
    await s.register('Student', '9876543210');
    await t.pumpWidget(MaterialApp(home: Shell(state: s)));
    await t.pumpAndSettle();
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(t.takeException(), isNull);
  });

  for (final size in const [
    Size(320, 568),
    Size(360, 640),
    Size(375, 667),
    Size(393, 852),
    Size(412, 915),
    Size(430, 932),
    Size(640, 360),
    Size(768, 1024),
    Size(1280, 800)
  ]) {
    testWidgets('welcome is responsive at $size', (t) async {
      await setViewport(t, size);
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      await t.pumpWidget(DcetApp(state: AppState(store: EmptyStore())));
      await t.pumpAndSettle();
      expect(find.text('Get started'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('welcome supports dark mode and 2x text', (t) async {
    await setViewport(t, const Size(320, 640), textScale: 2);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    final state = AppState(store: EmptyStore());
    await state.load();
    await state.toggleDark();
    await t.pumpWidget(DcetApp(state: state));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });

  testWidgets('desktop shell selects NavigationRail', (t) async {
    await setViewport(t, const Size(1280, 800));
    addTearDown(t.view.resetPhysicalSize);
    final s = AppState(store: EmptyStore());
    await s.load();
    await s.register('Student', '9876543210');
    await t.pumpWidget(MaterialApp(home: Shell(state: s)));
    await t.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('learn topic and progress fit narrow text scale', (t) async {
    await setViewport(t, const Size(320, 568), textScale: 1.3);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    final state = AppState(store: EmptyStore());
    await state.load();
    final repo = DemoRepository();
    for (final page in <Widget>[
      SubjectPage(subject: repo.subjects.first, state: state),
      TopicVideos(unit: repo.subjects.first.units.first, state: state),
      ProgressPage(state: state, repo: repo),
    ]) {
      await t.pumpWidget(MaterialApp(home: page));
      await t.pump();
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('payment support and legal fit narrow text scale', (t) async {
    await setViewport(t, const Size(320, 568), textScale: 1.3);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    final state = AppState(store: EmptyStore());
    await state.load();
    for (final page in <Widget>[
      Plans(state: state),
      const SupportPage(),
      const LegalPage(document: LegalDocument.terms),
    ]) {
      await t.pumpWidget(MaterialApp(home: page));
      await t.pump();
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('auth keyboard keeps form scrollable without overflow', (t) async {
    await setViewport(t, const Size(320, 568), textScale: 1.3);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    final state = AppState(store: EmptyStore());
    await state.load();
    await t.pumpWidget(MaterialApp(home: AuthPage(state: state)));
    await t.tap(find.text('Create account'));
    await t.pump();
    await t.showKeyboard(find.byType(TextFormField).last);
    await t.pump();
    await t.ensureVisible(find.text('Create local profile'));
    expect(find.text('Create local profile'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('phone content respects gutter and clears bottom navigation',
      (t) async {
    await setViewport(t, const Size(320, 568));
    addTearDown(t.view.resetPhysicalSize);
    final state = AppState(store: EmptyStore());
    await state.load();
    await state.register('Student', '9876543210');
    await t.pumpWidget(MaterialApp(home: Shell(state: state)));
    await t.pumpAndSettle();
    final statusRect = t.getRect(find.textContaining('Free access').first);
    expect(statusRect.left, greaterThanOrEqualTo(16));
    final navRect = t.getRect(find.byType(NavigationBar));
    expect(navRect.bottom, lessThanOrEqualTo(568));
    expect(t.takeException(), isNull);
  });

  testWidgets('legal final section can scroll above phone bottom', (t) async {
    await setViewport(t, const Size(320, 568), textScale: 1.3);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    await t.pumpWidget(const MaterialApp(
        home: LegalPage(document: LegalDocument.terms)));
    await t.scrollUntilVisible(
        find.text('Changes and contact'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(t.getBottomLeft(find.text('Changes and contact')).dy,
        lessThanOrEqualTo(568 - 24));
    expect(t.takeException(), isNull);
  });

  testWidgets('payment UTR keyboard and final verification action fit',
      (t) async {
    await setViewport(t, const Size(360, 640), textScale: 1.3);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    final state = AppState(store: EmptyStore());
    await state.load();
    await t.pumpWidget(MaterialApp(home: Plans(state: state)));
    await t.scrollUntilVisible(
        find.text('UTR / transaction reference'), 400,
        scrollable: find.byType(Scrollable).first);
    await t.showKeyboard(find.byType(TextField).last);
    await t.enterText(find.byType(TextField).last, '12345678');
    await t.pump();
    await t.ensureVisible(find.textContaining('request verification'));
    expect(t.takeException(), isNull);
  });

  testWidgets('learning quiz and model footer reach final controls', (t) async {
    await setViewport(t, const Size(375, 667), textScale: 1.3);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    final state = AppState(store: EmptyStore());
    await state.load();
    final repo = DemoRepository();
    final unit = repo.subjects.first.units.first;
    final video = unit.videos.first;
    await t.pumpWidget(MaterialApp(
        home: VideoLearningPage(unit: unit, video: video, state: state)));
    await t.scrollUntilVisible(find.text('Start 20 question assignment'), 350,
        scrollable: find.byType(Scrollable).first);
    expect(t.takeException(), isNull);

    await t.pumpWidget(MaterialApp(
        home: VideoQuizPage(unit: unit, video: video, state: state)));
    await t.scrollUntilVisible(find.text('Submit assignment'), 600,
        scrollable: find.byType(Scrollable).first);
    expect(t.takeException(), isNull);

    await t.pumpWidget(MaterialApp(
        home: ModelPaperPage(number: 1, repository: repo, state: state)));
    await t.pump();
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('library categories readers and profile fit narrow phone',
      (t) async {
    await setViewport(t, const Size(393, 852), textScale: 1.3);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    final state = AppState(store: EmptyStore());
    await state.load();
    final repo = DemoRepository();
    await t.pumpWidget(
        MaterialApp(home: ResourceLibrary(state: state, repo: repo)));
    for (final label in
        ['Syllabus', 'Question Papers', 'Notes', 'Cutoffs', 'Updates']) {
      expect(find.text(label), findsWidgets);
    }
    expect(t.takeException(), isNull);

    for (final page in <Widget>[
      SubjectReader(subject: repo.subjects.first, notes: true),
      const CutoffDesk(),
      const UpdatesDesk(),
      Profile(state: state),
    ]) {
      await t.pumpWidget(MaterialApp(home: Scaffold(body: page)));
      await t.pump();
      expect(t.takeException(), isNull);
    }
  });
}
