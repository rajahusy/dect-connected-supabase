import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_state.dart';
import '../data/demo_repository.dart';
import 'paper_attempt.dart';
import 'payments.dart' as payments;
import '../widgets/responsive_layout.dart';

const plum = Color(0xFF6D4AA2),
    green = Color(0xFF238566),
    peach = Color(0xFFF4DDD4);
const kea = 'https://cetonline.karnataka.gov.in/kea/';
const syllabusUrl =
    'https://dtek.karnataka.gov.in/storage/pdf files/Syllabus%20C 15/DCET%20syllabus.pdf';

class ResourceLibrary extends StatefulWidget {
  const ResourceLibrary({super.key, required this.state, required this.repo});
  final AppState state;
  final DemoRepository repo;
  @override
  State<ResourceLibrary> createState() => _ResourceLibraryState();
}

class _ResourceLibraryState extends State<ResourceLibrary> {
  int tab = 0;
  static const tabs = [
    ('Syllabus', Icons.list_alt_rounded),
    ('Question Papers', Icons.description_outlined),
    ('Notes', Icons.menu_book_rounded),
    ('Cutoffs', Icons.filter_alt_rounded),
    ('Updates', Icons.campaign_outlined)
  ];
  @override
  Widget build(BuildContext context) => SafeArea(
          child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
            child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1080), child: Container(
                padding: EdgeInsets.fromLTRB(
                    AppSpacing.page(MediaQuery.sizeOf(context).width),
                    18,
                    AppSpacing.page(MediaQuery.sizeOf(context).width),
                    18),
                decoration: const BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Color(0xFFE0D9E2)))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                                color: plum,
                                borderRadius: BorderRadius.circular(14)),
                            child: const Icon(Icons.local_library,
                                color: Colors.white)),
                        const SizedBox(width: 12),
                        const Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('DCET RESOURCE DESK',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: .7)),
                              Text(
                                  'Official links + original revision material',
                                  style: TextStyle(fontSize: 12))
                            ])),
                        const Icon(Icons.verified_outlined, color: green)
                      ]),
                      const SizedBox(height: 22),
                      Text('Library',
                          style: Theme.of(context).textTheme.headlineLarge),
                      const Text(
                          'Five focused exam resource sections. Free unless clearly marked.'),
                      const SizedBox(height: 16),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (var i = 0; i < tabs.length; i++)
                          ChoiceChip(
                              avatar: Icon(tabs[i].$2, size: 18),
                              label: Text(tabs[i].$1),
                              selected: i == tab,
                              onSelected: (_) => setState(() => tab = i),
                              selectedColor: Theme.of(context).colorScheme.primaryContainer,
                              side: BorderSide(
                                  color: i == tab
                                      ? plum
                                      : const Color(0xFFCBC2CE)))
                      ])
                    ]))))),
        SliverLayoutBuilder(builder: (context, constraints) {
          final horizontal = AppSpacing.page(constraints.crossAxisExtent);
          return SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 100),
              sliver: SliverToBoxAdapter(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1080), child: _content(context)))));
        })
      ]));

  Widget _content(BuildContext context) => switch (tab) {
        0 => _subjects(false),
        1 => _papers(),
        2 => _subjects(true),
        3 => const CutoffDesk(),
        _ => const UpdatesDesk()
      };
  Widget _subjects(bool notes) => LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth > 850 ? (c.maxWidth - 14) / 2 : c.maxWidth;
        return Wrap(spacing: 14, runSpacing: 2, children: [
          for (final s in widget.repo.subjects)
            SizedBox(
                width: w,
                child: ResourceCard(
                    icon: notes ? Icons.auto_stories : s.icon,
                    label:
                        notes ? 'FREE REVISION NOTES' : 'C 15 LEGACY REFERENCE',
                    title: '${s.name} ${notes ? 'notes' : 'syllabus'}',
                    subtitle: notes
                        ? '${s.units.length} units  -  concepts, formulas and self checks'
                        : s.units.map((e) => e.title).join('  -  '),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                SubjectReader(subject: s, notes: notes)))))
        ]);
      });
  Widget _papers() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Heading(
            'Previous year papers', 'Free  -  official discovery workflow'),
        ResourceGrid(children: [for (final y in [2025, 2024, 2023, 2022])
          ResourceCard(
              icon: Icons.history_edu,
              label: '$y  -  FREE INDEX',
              title: 'DCET $y question paper',
              subtitle:
                  'View paper categories and verify availability through the official KEA source.',
              action: 'View paper details',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PreviousPaperPage(year: y))))]),
        const SizedBox(height: 14),
        const Heading(
            'Model question papers', 'Subscriber only original practice'),
        ResourceGrid(children: [for (var i = 1; i <= 5; i++)
          ResourceCard(
              icon: widget.state.isSubscribed ? Icons.assignment : Icons.lock,
              label: widget.state.isSubscribed
                  ? 'SUBSCRIBER  -  READY'
                  : 'SUBSCRIBER ONLY',
              title: 'Original model paper ${i.toString().padLeft(2, '0')}',
              subtitle:
                  'A scored 20 question five subject practice attempt. Not an official KEA paper.',
              action: widget.state.isSubscribed
                  ? 'Start attempt'
                  : 'View access requirement',
              onTap: () => widget.state.isSubscribed
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ModelPaperPage(
                              number: i,
                              repository: widget.repo,
                              state: widget.state)))
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => payments.Plans(state: widget.state))))]),
      ]);
}

class ResourceGrid extends StatelessWidget {
  const ResourceGrid({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
    final columns = c.maxWidth >= 760 ? 2 : 1;
    final width = columns == 2 ? (c.maxWidth - 14) / 2 : c.maxWidth;
    return Wrap(spacing: 14, runSpacing: 2, children: [
      for (final child in children) SizedBox(width: width, child: child)
    ]);
  });
}

class SubjectReader extends StatelessWidget {
  const SubjectReader({super.key, required this.subject, required this.notes});
  final Subject subject;
  final bool notes;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(subject.shortName)),
      body: ResponsiveBody(maxWidth: 760, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(subject.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(notes
            ? 'Original quick revision reader  -  Free'
            : 'Outline  -  verify against the current KEA notification'),
        const SizedBox(height: 18),
        for (var i = 0; i < subject.units.length; i++)
          Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                  leading: CircleAvatar(
                      backgroundColor: subject.color.withValues(alpha: .14),
                      child: Text('${i + 1}')),
                  title: Text(subject.units[i].title,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(subject.units[i].objectives.first),
                  childrenPadding: const EdgeInsets.fromLTRB(
                      AppSpacing.card, 0, AppSpacing.card, AppSpacing.card),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Definition and concept',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(subject.units[i].body,
                        style: const TextStyle(height: 1.55)),
                    const SizedBox(height: 14),
                    const Text('Method / formula checklist',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    ...subject.units[i].objectives.map((e) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.check_circle_outline,
                            color: green, size: 19),
                        title: Text(e))),
                    const Text('Worked example',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(
                        '${subject.units[i].questions.first.prompt}\nAnswer: ${subject.units[i].questions.first.options[subject.units[i].questions.first.answer]}\n${subject.units[i].questions.first.explanation}'),
                    const SizedBox(height: 14),
                    const Text('Common mistakes',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    const Text(
                        'Do not skip definitions, change the given conditions, omit units, or accept a result without checking the governing rule.'),
                    const SizedBox(height: 12),
                    TextButton.icon(
                        onPressed: () => open(
                            context, subject.units[i].videos.first.sourceUrl),
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Find a lesson for this topic'))
                  ])),
        OutlinedButton.icon(
            onPressed: () => open(context, syllabusUrl),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open official DTE C 15 syllabus PDF')),
        const SizedBox(height: 8),
        const Text(
            'Legacy C 15 source. Confirm the applicable scheme and year in the current KEA notification.',
            style: TextStyle(fontSize: 12))
      ])));
}

class CutoffDesk extends StatefulWidget {
  const CutoffDesk({super.key});
  @override
  State<CutoffDesk> createState() => _CutoffDeskState();
}

class _CutoffDeskState extends State<CutoffDesk> {
  String year = '2025', category = 'General';
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Heading(
            'Cutoff explorer', 'Free  -  verify every closing rank on KEA'),
        ResourceGrid(children: [Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
                padding: const EdgeInsets.all(AppSpacing.card),
                child: Column(children: [
                  DropdownButtonFormField<String>(
                      value: year,
                      decoration:
                          const InputDecoration(labelText: 'Admission year'),
                      items: ['2025', '2024', '2023', '2022']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => year = v!)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: [
                        'General',
                        'Hyderabad Karnataka',
                        'Evening college'
                      ]
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => category = v!)),
                  const SizedBox(height: 14),
                  const Text(
                      'No numeric rank is displayed without a verified dataset. Compare college, branch, round, seat type and category like for like.'),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                      onPressed: () => open(context, kea),
                      icon: const Icon(Icons.verified_outlined),
                      label: Text('Verify $year $category on KEA'))
                ])))]),
      ]);
}

class UpdatesDesk extends StatelessWidget {
  const UpdatesDesk({super.key});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Heading(
            'DCET updates', 'Official portals  -  no unofficial dates'),
        ResourceGrid(children: [ResourceCard(
            icon: Icons.notifications_active_outlined,
            label: '2026  -  OFFICIAL PORTAL',
            title: 'KEA DCET notifications',
            subtitle:
                'Applications, document verification, admission rounds and results. Check the portal for current dates.',
            action: 'Open KEA portal',
            onTap: () => open(context, kea)),
        ResourceCard(
            icon: Icons.account_balance_outlined,
            label: 'REFERENCE SOURCE',
            title: 'DTE Karnataka resources',
            subtitle:
                'Diploma curriculum and department notices. Source status: official portal.',
            action: 'Open DTE portal',
            onTap: () => open(context, 'https://dtek.karnataka.gov.in/english'))])
      ]);
}

class ResourceCard extends StatelessWidget {
  const ResourceCard(
      {super.key,
      required this.icon,
      required this.label,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.action = 'Open resource'});
  final IconData icon;
  final String label, title, subtitle, action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
              padding: const EdgeInsets.all(AppSpacing.card),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(13)),
                    child: Icon(icon, color: Theme.of(context).colorScheme.onSecondaryContainer)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .7,
                              color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(height: 5),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 5),
                      Text(subtitle,
                          maxLines: 5, overflow: TextOverflow.fade),
                      const SizedBox(height: 10),
                      Text(action,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800))
                    ])),
                const Icon(Icons.chevron_right)
              ]))));
}

class Heading extends StatelessWidget {
  const Heading(this.title, this.subtitle, {super.key});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
      ]));
}

Future<void> open(BuildContext c, String value) async {
  final ok =
      await launchUrl(Uri.parse(value), mode: LaunchMode.externalApplication);
  if (!ok && c.mounted)
    ScaffoldMessenger.of(c).showSnackBar(
        const SnackBar(content: Text('Could not open the official source.')));
}

void info(BuildContext c, String title, String body) => showDialog<void>(
    context: c,
    builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c), child: const Text('Close'))
            ]));
