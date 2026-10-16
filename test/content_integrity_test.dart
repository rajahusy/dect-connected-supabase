import 'package:flutter_test/flutter_test.dart';
import 'package:dcet_master/data/demo_repository.dart';

void main() {
  test('lesson banks have non overlapping semantic identities', () {
    final repository = DemoRepository();
    final globalUrls = <String>{};

    for (final subject in repository.subjects) {
      expect(
          subject.units
              .expand((unit) => unit.videos)
              .where((video) => video.isFreePreview),
          hasLength(1));
      for (final unit in subject.units) {
        expect(unit.videos, hasLength(5));
        final topicIds = <String>{};
        final lessonPromptOptionSignatures = <String>{};
        for (final video in unit.videos) {
          expect(video.questions, hasLength(20));
          expect(video.questions.map((question) => question.prompt).toSet(),
              hasLength(20),
              reason: 'Every question in a lesson needs a unique prompt');
          final lessonIds = video.questions.map((q) => q.semanticId).toSet();
          expect(lessonIds, hasLength(20));
          final conceptIds = video.questions.map((q) => q.conceptId).toSet();
          expect(conceptIds, hasLength(4));
          expect(topicIds.intersection(conceptIds), isEmpty,
              reason: 'A concept cannot be recycled by another lesson');
          final normalized = video.questions
              .map((q) =>
                  '${q.prompt.replaceFirst('${video.title}   ', '').toLowerCase().replaceAll(RegExp(r'[^a z0 9]+'), ' ').trim()}|'
                  '${q.options.map((o) => o.toLowerCase().replaceAll(RegExp(r'[^a z0 9]+'), ' ').trim()).toList()..sort()}')
              .toSet();
          expect(normalized, hasLength(20));
          expect(
              lessonPromptOptionSignatures.add(normalized.join('||')), isTrue,
              reason: 'Every lesson needs a materially distinct question bank');
          topicIds.addAll(conceptIds);
          expect(globalUrls.add(video.sourceUrl), isTrue);
          for (final question in video.questions) {
            expect(question.options.toSet(), hasLength(4));
            expect(question.answer, inInclusiveRange(0, 3));
            expect(question.explanation, contains(unit.title));
            expect(question.prompt,
                isNot(contains('select the accurate statement')));
            expect(question.prompt, isNot(contains('lesson 1   concept')));
          }
        }
        expect(topicIds, hasLength(20));
      }
    }
  });

  test('catalog exposes four hundred focus owned authored concepts', () {
    final repository = DemoRepository();
    final concepts = <String>{};
    for (final unit in repository.units) {
      for (final video in unit.videos) {
        concepts.addAll(video.questions.map((question) => question.conceptId));
      }
    }
    expect(repository.units, hasLength(20));
    expect(concepts, hasLength(400));
  });
}
