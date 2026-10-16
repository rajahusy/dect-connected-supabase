import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../data/demo_repository.dart';
import 'resource_library.dart' show open;
import '../widgets/responsive_layout.dart';

class PreviousPaperPage extends StatelessWidget {
  const PreviousPaperPage({super.key, required this.year});
  final int year;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('DCET $year paper')),
        body: ResponsiveBody(maxWidth: 760, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Official portal search guide',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          const Text(
              'Status: no verified direct PDF URL is stored. Open KEA, locate Admissions or DCET, search the archive by year, then confirm the language and paper code before downloading.'),
          const SizedBox(height: 20),
          for (final category in [
            'General paper',
            'Kannada / Hyderabad Karnataka paper',
            'Evening college paper'
          ])
            Card(
                child: ListTile(
              leading: const Icon(Icons.manage_search),
              title: Text(category),
              subtitle: Text(
                  'Search terms to copy: DCET $year $category question paper'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () =>
                  open(context, 'https://cetonline.karnataka.gov.in/kea/'),
            )),
          const Text(
              'Official source: Karnataka Examinations Authority homepage. This action opens a search starting point, not a direct paper PDF.',
              style: TextStyle(fontSize: 12)),
        ])),
      );
}

class ModelPaperPage extends StatefulWidget {
  const ModelPaperPage(
      {super.key,
      required this.number,
      required this.repository,
      required this.state});
  final int number;
  final DemoRepository repository;
  final AppState state;
  @override
  State<ModelPaperPage> createState() => _ModelPaperPageState();
}

class _ModelPaperPageState extends State<ModelPaperPage> {
  late final List<Question> questions = [
    for (final subject in widget.repository.subjects)
      for (final unit in subject.units.take(1))
        ...unit.videos[(widget.number - 1) % unit.videos.length].questions
            .take(4),
  ];
  late final List<int?> answers = List<int?>.filled(questions.length, null);
  late final PageController controller = PageController();
  Timer? timer;
  int current = 0;
  int secondsLeft = 30 * 60;
  bool submitted = false;
  int get score => [
        for (var i = 0; i < questions.length; i++)
          answers[i] == questions[i].answer
      ].where((x) => x).length;
  int get unanswered => answers.where((x) => x == null).length;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || submitted) return;
      if (secondsLeft <= 1) {
        _finish();
      } else {
        setState(() => secondsLeft);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    timer?.cancel();
    setState(() {
      submitted = true;
      secondsLeft = secondsLeft.clamp(0, secondsLeft);
    });
    await widget.state.recordQuiz('model paper ${widget.number}', score);
  }

  Future<void> _confirmSubmit() async {
    final yes = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Submit short model test?'),
              content: Text(
                  '$unanswered unanswered question(s). You cannot change answers after submission.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Continue test')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Submit'))
              ],
            ));
    if (yes == true) await _finish();
  }

  Widget _testActions(bool compact) {
    final previous = OutlinedButton(
        onPressed: current == 0
            ? null
            : () => controller.previousPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut),
        child: const Text('Previous'));
    final Widget primary = submitted
        ? Center(
            child: Text('Result: $score/${questions.length}',
                style: const TextStyle(fontWeight: FontWeight.w900)))
        : current == questions.length - 1
            ? FilledButton(
                onPressed: _confirmSubmit,
                child: const Text('Review and submit'))
            : FilledButton(
                onPressed: () => controller.nextPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut),
                child: const Text('Next'));
    if (compact) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        previous,
        const SizedBox(height: 10),
        primary,
      ]);
    }
    return Row(children: [previous, const Spacer(), primary]);
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsLeft % 60).toString().padLeft(2, '0');
    final compactActions = MediaQuery.sizeOf(context).width < 360 ||
        MediaQuery.textScalerOf(context).scale(1) >= 1.3;
    return Scaffold(
      appBar: AppBar(title: Text('Model test ${widget.number}')),
      body: SafeArea(top: false, child: Column(children: [
        Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: LayoutBuilder(builder: (context, c) => Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.page(c.maxWidth), 8, AppSpacing.page(c.maxWidth), 10),
            child: Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: 16, runSpacing: 6, children: [
              Text('Question ${current + 1}/${questions.length}'),
              Text('$unanswered unanswered'),
              Chip(avatar: const Icon(Icons.timer_outlined, size: 18), label: Text('$minutes:$seconds'))
            ]))))),
        LinearProgressIndicator(value: (current + 1) / questions.length),
        Expanded(
            child: PageView.builder(
                controller: controller,
                itemCount: questions.length,
                onPageChanged: (v) => setState(() => current = v),
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: LayoutBuilder(builder: (context, c) => ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: pageInsets(c.maxWidth, bottom: 24), children: [
                    Text(question.prompt,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ...question.options.asMap().entries.map((option) =>
                        RadioListTile<int>(
                            value: option.key,
                            groupValue: answers[index],
                            onChanged: submitted
                                ? null
                                : (v) => setState(() => answers[index] = v),
                            title: Text(option.value))),
                    if (submitted)
                      Card(
                          color: (answers[index] == question.answer
                              ? Colors.green
                              : Colors.red).withValues(alpha: .12),
                          child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.card),
                              child: Text(
                                  'Correct answer: ${question.options[question.answer]}\n${question.explanation}'))),
                  ]))));
                })),
        Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: LayoutBuilder(builder: (context, c) => Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.page(c.maxWidth), 12, AppSpacing.page(c.maxWidth), 16),
            child: _testActions(compactActions))))),
      ])),
    );
  }
}
