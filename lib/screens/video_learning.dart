import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../data/demo_repository.dart';
import 'resource_library.dart' show open;
import '../widgets/responsive_layout.dart';

const _plum = Color(0xFF6D4AA2), _green = Color(0xFF2D8C6B);

class VideoLearningPage extends StatelessWidget {
  const VideoLearningPage(
      {super.key,
      required this.unit,
      required this.video,
      required this.state});
  final LearningUnit unit;
  final VideoLesson video;
  final AppState state;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(unit.subject)),
      body: ResponsiveBody(maxWidth: 760, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(unit.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text('${video.title}  -  ${video.duration}'),
        const SizedBox(height: 18),
        Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: _plum, borderRadius: BorderRadius.circular(24)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.ondemand_video, color: Colors.white, size: 44),
              const SizedBox(height: 18),
              Text(video.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text(
                  'Topic specific public search  -  choose a trusted educator',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 14),
              FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.white, foregroundColor: _plum),
                  onPressed: () => open(context, video.sourceUrl),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Find lesson on YouTube'))
            ])),
        const SizedBox(height: 20),
        Text(unit.body, style: const TextStyle(fontSize: 16, height: 1.6)),
        const SizedBox(height: 12),
        ...video.objectives.map((x) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle_outline, color: _green),
            title: Text(x))),
        FilledButton.icon(
            onPressed: () async {
              await state.complete(video.id);
              if (context.mounted)
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => VideoQuizPage(
                            unit: unit, video: video, state: state)));
            },
            icon: const Icon(Icons.quiz),
            label: const Text('Start 20 question assignment'))
      ])));
}

class VideoQuizPage extends StatefulWidget {
  const VideoQuizPage(
      {super.key,
      required this.unit,
      required this.video,
      required this.state});
  final LearningUnit unit;
  final VideoLesson video;
  final AppState state;
  @override
  State<VideoQuizPage> createState() => _VideoQuizPageState();
}

class _VideoQuizPageState extends State<VideoQuizPage> {
  late final answers = List<int?>.filled(widget.video.questions.length, null);
  bool submitted = false;
  int get score => [
        for (var i = 0; i < answers.length; i++)
          answers[i] == widget.video.questions[i].answer
      ].where((x) => x).length;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Video assignment')),
      body: ResponsiveBody(maxWidth: 760, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(widget.video.title,
            style: Theme.of(context).textTheme.headlineMedium),
        Text(
            '${widget.video.questions.length} questions  -  Answer all to submit'),
        const SizedBox(height: 18),
        ...widget.video.questions.asMap().entries.map((e) => Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
                padding: const EdgeInsets.all(AppSpacing.card),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${e.key + 1}. ${e.value.prompt}',
                          style: Theme.of(context).textTheme.titleMedium),
                      ...e.value.options.asMap().entries.map((o) =>
                          RadioListTile<int>(
                              contentPadding: EdgeInsets.zero,
                              value: o.key,
                              groupValue: answers[e.key],
                              onChanged: submitted
                                  ? null
                                  : (v) => setState(() => answers[e.key] = v),
                              title: Text(o.value))),
                      if (submitted)
                        Container(
                            padding: const EdgeInsets.all(10),
                            color: (answers[e.key] == e.value.answer
                                    ? _green
                                    : Colors.red)
                                .withValues(alpha: .1),
                            child: Text(e.value.explanation))
                    ])))),
        FilledButton(
            onPressed: submitted || answers.any((x) => x == null)
                ? null
                : () async {
                    setState(() => submitted = true);
                    await widget.state.recordQuiz(widget.video.id, score);
                  },
            child: Text(submitted
                ? 'Score: $score / ${answers.length}'
                : 'Submit assignment'))
      ])));
}
