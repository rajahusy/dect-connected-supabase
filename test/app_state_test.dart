import 'package:dcet_master/core/app_state.dart';
import 'package:dcet_master/data/demo_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryStore implements PreferencesStore {
  final values = <String, Object>{};
  @override
  Future<bool?> getBool(String k) async => values[k] as bool?;
  @override
  Future<int?> getInt(String k) async => values[k] as int?;
  @override
  Future<String?> getString(String k) async => values[k] as String?;
  @override
  Future<List<String>?> getStringList(String k) async =>
      (values[k] as List<String>?)?.toList();
  @override
  Future<void> setBool(String k, bool v) async {
    values[k] = v;
  }

  @override
  Future<void> setInt(String k, int v) async {
    values[k] = v;
  }

  @override
  Future<void> setString(String k, String v) async {
    values[k] = v;
  }

  @override
  Future<void> setStringList(String k, List<String> v) async {
    values[k] = v;
  }

  @override
  Future<void> remove(String k) async {
    values.remove(k);
  }
}

void main() {
  test('five subjects expose distinct topic owned lesson content', () {
    final r = DemoRepository();
    expect(r.subjects, hasLength(5));
    expect(r.units, hasLength(20));
    final urls = <String>{};
    for (final s in r.subjects) {
      expect(s.units.expand((u) => u.videos).where((v) => v.isFreePreview),
          hasLength(1));
      for (final u in s.units) {
        expect(u.videos, hasLength(5));
        final signatures = <String>{};
        for (final v in u.videos) {
          expect(v.questions, hasLength(20));
          expect(v.questions.map((q) => q.prompt).toSet(), hasLength(20));
          expect(
              v.questions.every((q) =>
                  q.options.length == 4 &&
                  q.options.toSet().length == 4 &&
                  q.answer >= 0 &&
                  q.answer < 4 &&
                  q.explanation.contains(u.title)),
              isTrue);
          expect(
              v.questions.every((q) =>
                  q.prompt.contains(u.title) && q.prompt.contains(v.title)),
              isTrue);
          signatures.add(v.questions.map((q) => q.prompt).join('|'));
          expect(urls.add(v.sourceUrl), isTrue);
          final query = Uri.parse(v.sourceUrl).queryParameters['search_query']!;
          expect(query, contains(s.name));
          expect(query, contains(u.title));
          expect(query, contains(v.title));
          expect(
              v.questions.where(
                  (q) => q.prompt.contains('select the accurate statement')),
              isEmpty);
        }
        expect(signatures, hasLength(5));
      }
    }
  });
  test('library covers every subject and keeps only model papers gated', () {
    for (final x in libraryItems) {
      expect(x.requiresSubscription, x.kind == LibraryKind.modelPaper);
    }
    expect(libraryItems.where((x) => x.kind == LibraryKind.syllabus),
        hasLength(5));
    expect(
        libraryItems.where((x) => x.kind == LibraryKind.notes), hasLength(5));
    expect(
        libraryItems.any((x) => x.kind == LibraryKind.previousPaper), isTrue);
    expect(libraryItems.any((x) => x.kind == LibraryKind.cutoff), isTrue);
    expect(libraryItems.any((x) => x.kind == LibraryKind.update), isTrue);
  });
  test('ranking tiers are deterministic and honest', () {
    expect(AppState.tierForAccuracy(20), 'Foundation');
    expect(AppState.tierForAccuracy(55), 'Improving');
    expect(AppState.tierForAccuracy(75), 'Proficient');
    expect(AppState.tierForAccuracy(90), 'Master');
  });
  test('profile, progress, and access persist', () async {
    final store = MemoryStore();
    final a = AppState(store: store);
    await a.load();
    await a.register('Ananya Rao', '9876543210', 'secure12');
    final id = DemoRepository().videos.first.id;
    await a.complete(id);
    await a.recordQuiz(id, 18);
    await a.activateDemo(const Duration(days: 30));
    final b = AppState(store: store);
    await b.load();
    expect(b.signedIn, isTrue);
    expect(b.name, 'Ananya Rao');
    expect(b.completed, contains(id));
    expect(b.quizScores[id], 18);
    expect(b.quizAccuracy, 90);
    expect(b.onDeviceTier, 'Master');
    expect(b.isSubscribed, isTrue);
  });
  test('login validates the locally stored credential', () async {
    final store = MemoryStore();
    final state = AppState(store: store);
    await state.load();
    await state.register('Student', '9876543210', 'correct7');
    await state.logout();
    expect(await state.login('9876543210', 'wrong77'), isFalse);
    expect(state.signedIn, isFalse);
    expect(await state.login('9876543210', 'correct7'), isTrue);
    expect(state.signedIn, isTrue);
  });
}
