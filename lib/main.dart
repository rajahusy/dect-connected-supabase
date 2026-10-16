import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app_state.dart';
import 'data/demo_repository.dart';
import 'screens/resource_library.dart';
import 'screens/video_learning.dart';
import 'screens/payments.dart' as payments;
import 'screens/legal_pages.dart';
import 'widgets/responsive_layout.dart';
import 'services/supabase_student_service.dart';

const ivory = Color(0xFFFBF8F3),
    peach = Color(0xFFF4DDD4),
    sand = Color(0xFFF3E4CD),
    plum = Color(0xFF6D4AA2),
    ink = Color(0xFF211D24),
    emerald = Color(0xFF2D8C6B);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  SupabaseStudentService? backend;
  if (url.isNotEmpty && key.isNotEmpty) {
    await Supabase.initialize(url: url, anonKey: key);
    backend = SupabaseStudentService(Supabase.instance.client);
  }
  runApp(DcetApp(backend: backend));
}

class DcetApp extends StatefulWidget {
  const DcetApp({super.key, this.state, this.backend});
  final AppState? state;
  final SupabaseStudentService? backend;
  @override
  State<DcetApp> createState() => _DcetAppState();
}

class _DcetAppState extends State<DcetApp> {
  late final AppState state =
      widget.state ?? AppState(backend: widget.backend);
  @override
  void initState() {
    super.initState();
    if (!state.initialized) state.load();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: state,
      builder: (_, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DCET Master',
          themeMode: state.dark ? ThemeMode.dark : ThemeMode.light,
          theme: _theme(false),
          darkTheme: _theme(true),
          home: !state.initialized
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : state.signedIn
                  ? Shell(state: state)
                  : Welcome(state: state)));
}

ThemeData _theme(bool dark) => ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: dark ? const Color(0xFF19161C) : ivory,
    colorScheme: ColorScheme.fromSeed(
        seedColor: plum,
        brightness: dark ? Brightness.dark : Brightness.light,
        primary: dark ? const Color(0xFFCDB7EF) : plum,
        secondary: emerald,
        surface: dark ? const Color(0xFF252128) : Colors.white),
    textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 1.3),
        headlineMedium: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: .8),
        titleLarge: TextStyle(fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontWeight: FontWeight.w700)),
    cardTheme: CardThemeData(
        elevation: 0,
        color: dark ? const Color(0xFF252128) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48))),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
    chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: dark ? const Color(0xFF625A68) : const Color(0xFFCBC2CE))),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF2B272E) : Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(17)),
    filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
            minimumSize: const Size(48, 54),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)))));

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: plum, borderRadius: BorderRadius.circular(13)),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white)),
        const SizedBox(width: 11),
        const Text('DCET MASTER',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2))
      ]);
}

class Welcome extends StatelessWidget {
  const Welcome({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
          child: LayoutBuilder(
              builder: (context, c) => SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.page(c.maxWidth), vertical: 20),
                  child: Center(child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: c.maxHeight - 40, maxWidth: 760),
                      child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Brand(),
                            SizedBox(height: c.maxHeight > 700 ? 100 : 48),
                            Container(width: 70, height: 6, color: emerald),
                            const SizedBox(height: 22),
                            Text('Study with a clear path.',
                                style:
                                    Theme.of(context).textTheme.headlineLarge),
                            const SizedBox(height: 14),
                            const Text(
                                'Watch each topic, learn the idea, then prove it with a focused quiz.',
                                style: TextStyle(fontSize: 18, height: 1.5)),
                            const SizedBox(height: 30),
                            const _Path(),
                            const SizedBox(height: 48),
                            FilledButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            AuthPage(state: state))),
                                child: const SizedBox(
                                    width: double.infinity,
                                    child: Center(child: Text('Get started')))),
                            const SizedBox(height: 12),
                            const Center(
                                child: Text(
                                    'Local profile  -  Your progress stays on this device',
                                    style: TextStyle(fontSize: 12)))
                          ])))))));
}

class _Path extends StatelessWidget {
  const _Path();
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration:
          BoxDecoration(color: adaptiveTint(context, peach), borderRadius: BorderRadius.circular(24)),
      child: const Wrap(
          alignment: WrapAlignment.spaceAround, crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10, runSpacing: 10, children: [
            _PathStep(Icons.play_circle_fill_rounded, 'WATCH'),
            Icon(Icons.arrow_forward, color: plum),
            _PathStep(Icons.lightbulb_rounded, 'LEARN'),
            Icon(Icons.arrow_forward, color: plum),
            _PathStep(Icons.quiz_rounded, 'QUIZ')
          ]));
}

class _PathStep extends StatelessWidget {
  const _PathStep(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, color: plum, size: 30),
        const SizedBox(height: 7),
        Text(label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .8))
      ]);
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.state});
  final AppState state;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool create = false, hidden = true, agreed = false;
  final key = GlobalKey<FormState>();
  final name = TextEditingController(),
      mobile = TextEditingController(),
      password = TextEditingController();
  @override
  void dispose() {
    name.dispose();
    mobile.dispose();
    password.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(),
      body: SafeArea(top: false, bottom: false,
          child: ResponsiveBody(maxWidth: 560, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Brand(),
        const SizedBox(height: 28),
        Text(create ? 'Create your profile' : 'Welcome back',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
            widget.state.backendEnabled
                ? 'Secure student authentication is connected to Supabase.'
                : 'Local development mode: add Supabase URL and publishable key for server authentication.'),
        const SizedBox(height: 24),
        Wrap(spacing: 10, runSpacing: 8, children: [
          ChoiceChip(label: const Text('Login'), selected: !create,
              onSelected: (_) => setState(() => create = false)),
          ChoiceChip(label: const Text('Create account'), selected: create,
              onSelected: (_) => setState(() => create = true)),
        ]),
        const SizedBox(height: 20),
        Form(
            key: key,
            child: Column(children: [
              if (create) ...[
                TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (v) => (v?.trim().length ?? 0) < 2
                        ? 'Enter your full name'
                        : null),
                const SizedBox(height: 12)
              ],
              TextFormField(
                  controller: mobile,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      labelText: '10 digit mobile number'),
                  validator: (v) => RegExp(r'^\d{10}$').hasMatch(v ?? '')
                      ? null
                      : 'Enter exactly 10 digits'),
              const SizedBox(height: 12),
              TextFormField(
                  controller: password,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  obscureText: hidden,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                          onPressed: () => setState(() => hidden = !hidden),
                          icon: Icon(hidden
                              ? Icons.visibility
                              : Icons.visibility_off))),
                  validator: (v) => (v?.length ?? 0) < 6
                      ? 'Use at least 6 characters'
                      : null),
              if (create)
                CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: agreed,
                    onChanged: (v) => setState(() => agreed = v ?? false),
                    title: const Text('I agree to the Terms and Privacy notice',
                        style: TextStyle(fontSize: 13))),
              if (create)
                Wrap(alignment: WrapAlignment.center, spacing: 8, children: [
                  SizedBox(
                      height: 48,
                      child: TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LegalPage(
                                      document: LegalDocument.terms))),
                          child: const Text('Terms of Use'))),
                  SizedBox(
                      height: 48,
                      child: TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LegalPage(
                                      document: LegalDocument.privacy))),
                          child: const Text('Privacy Policy')))
                ]),
              const SizedBox(height: 12),
              FilledButton(
                  onPressed: () => _submit(),
                  child: SizedBox(
                      width: double.infinity,
                      child: Center(
                          child:
                              Text(create
                                  ? (widget.state.backendEnabled
                                      ? 'Create account'
                                      : 'Create local profile')
                                  : 'Login'))))
            ]))
      ]))));
  Future<void> _submit() async {
    if (!key.currentState!.validate()) return;
    if (create && !agreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please accept the terms to continue.')));
      return;
    }
    try {
      if (create) {
        await widget.state.register(name.text, mobile.text, password.text);
      } else {
        final ok = await widget.state.login(mobile.text, password.text);
        if (!ok) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(widget.state.backendEnabled
                    ? 'Mobile number or password is incorrect.'
                    : 'Mobile number or password does not match this local profile.')));
          }
          return;
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account operation failed: $error')),
        );
      }
    }
  }

}

class Shell extends StatefulWidget {
  const Shell({super.key, required this.state});
  final AppState state;
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;
  late final repo = DemoRepository();
  static const destinations = [
    NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.school_rounded), label: 'Learn'),
    NavigationDestination(
        icon: Icon(Icons.folder_copy_rounded), label: 'Library'),
    NavigationDestination(
        icon: Icon(Icons.insights_rounded), label: 'Progress'),
    NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
  ];
  @override
  Widget build(BuildContext context) {
    final pages = [
      Home(
          state: widget.state,
          repo: repo,
          onLearn: () => setState(() => index = 1)),
      Learn(state: widget.state, repo: repo),
      ResourceLibrary(state: widget.state, repo: repo),
      ProgressPage(state: widget.state, repo: repo),
      Profile(state: widget.state)
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      final content = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: IndexedStack(index: index, children: pages));
      if (wide) {
        return Scaffold(
            body: Row(children: [
          Container(width: 168, padding: const EdgeInsets.symmetric(vertical: 20), child: Column(children: [
            const Padding(padding: EdgeInsets.symmetric(horizontal: 18), child: Brand()),
            const SizedBox(height: 28), Expanded(child: NavigationRail(
              selectedIndex: index,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (v) => setState(() => index = v),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(icon: d.icon, label: Text(d.label))
              ]))])),
          const VerticalDivider(width: 1),
          Expanded(child: Align(alignment: Alignment.topCenter, child: content))
        ]));
      }
      return Scaffold(
          body: content,
          bottomNavigationBar: NavigationBar(
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              height: 72,
              selectedIndex: index,
              onDestinationSelected: (v) => setState(() => index = v),
              destinations: destinations));
    });
  }
}

class PageFrame extends StatelessWidget {
  const PageFrame(
      {super.key, required this.title, required this.child, this.subtitle});
  final String title;
  final String? subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => SafeArea(bottom: false,
          child: ResponsiveBody(maxWidth: 1280, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Brand(),
            const SizedBox(height: 24),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
            ],
            const SizedBox(height: 22),
            child
          ])));
}

class Home extends StatelessWidget {
  const Home(
      {super.key,
      required this.state,
      required this.repo,
      required this.onLearn});
  final AppState state;
  final DemoRepository repo;
  final VoidCallback onLearn;
  @override
  Widget build(BuildContext context) {
    final next = repo.units.firstWhere((u) => !state.completed.contains(u.id),
        orElse: () => repo.units.first);
    return PageFrame(
        title: 'Hello, ${state.name.split(' ').first}',
        subtitle: 'Ready for your next focused session?',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Status(state),
          const SizedBox(height: 18),
          Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: plum, borderRadius: BorderRadius.circular(26)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("TODAY'S PATH",
                        style: TextStyle(
                            color: Color(0xFFDCCEF2),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
                    const SizedBox(height: 12),
                    Text(next.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(next.subject,
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 18),
                    const _Path(),
                    const SizedBox(height: 14),
                    FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: plum),
                        onPressed: () => openUnit(context, state, next),
                        child: const Text('Continue topic'))
                  ])),
          const SizedBox(height: 24),
          _SectionTitle('Five subjects', onTap: onLearn),
          const SizedBox(height: 10),
          ...repo.subjects.map((s) => SubjectTile(subject: s, state: state)),
          const SizedBox(height: 18),
          _SectionTitle('Latest update'),
          const SizedBox(height: 10),
          const _InfoTile(
              title: 'DCET 2026 information hub',
              subtitle:
                  'Production update feed connection required  -  Reference status')
        ]));
  }
}

class _Status extends StatelessWidget {
  const _Status(this.state);
  final AppState state;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
          color: adaptiveTint(context, state.isSubscribed ? const Color(0xFFDCEEE7) : sand),
          borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        Icon(
            state.isSubscribed
                ? Icons.verified_rounded
                : Icons.lock_open_rounded,
            color: state.isSubscribed ? emerald : plum),
        const SizedBox(width: 12),
        Expanded(
            child: Text(
                state.isSubscribed
                    ? 'Subscriber preview active on this device'
                    : 'Free access: first topic + quiz in every subject',
                style: const TextStyle(fontWeight: FontWeight.w700)))
      ]));
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.onTap});
  final String text;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Text(text, style: Theme.of(context).textTheme.titleLarge)),
        if (onTap != null)
          TextButton(onPressed: onTap, child: const Text('See all'))
      ]);
}

class Learn extends StatelessWidget {
  const Learn({super.key, required this.state, required this.repo});
  final AppState state;
  final DemoRepository repo;
  @override
  Widget build(BuildContext context) => PageFrame(
      title: 'Learn',
      subtitle: 'Choose a subject, then follow its syllabus topic by topic.',
      child: Column(
          children: repo.subjects
              .map((s) => SubjectTile(subject: s, state: state, large: true))
              .toList()));
}

class SubjectTile extends StatelessWidget {
  const SubjectTile(
      {super.key,
      required this.subject,
      required this.state,
      this.large = false});
  final Subject subject;
  final AppState state;
  final bool large;
  @override
  Widget build(BuildContext context) {
    final done =
        subject.units.where((u) => state.completed.contains(u.id)).length;
    return Card(
        color: Theme.of(context).brightness == Brightness.dark
            ? subject.color.withValues(alpha: .18)
            : subject.color.withValues(alpha: .11),
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        SubjectPage(subject: subject, state: state))),
            child: Padding(
                padding: const EdgeInsets.all(AppSpacing.card),
                child: Row(children: [
                  Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          color: subject.color,
                          borderRadius: BorderRadius.circular(16)),
                      child: Icon(subject.icon, color: Colors.white)),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(subject.name,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 5),
                        Text('$done/${subject.units.length} topics complete',
                            style: const TextStyle(fontSize: 12))
                      ])),
                  const Icon(Icons.chevron_right_rounded)
                ]))));
  }
}

class SubjectPage extends StatelessWidget {
  const SubjectPage({super.key, required this.subject, required this.state});
  final Subject subject;
  final AppState state;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(subject.shortName)),
      body: ResponsiveBody(maxWidth: 760, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Icon(subject.icon, size: 52, color: subject.color),
        const SizedBox(height: 14),
        Text(subject.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text('Syllabus topics  -  Watch -  Learn -  Quiz'),
        const SizedBox(height: 22),
        ...subject.units.asMap().entries.map(
            (e) => _TopicTile(number: e.key + 1, unit: e.value, state: state))
      ])));
}

class _TopicTile extends StatelessWidget {
  const _TopicTile(
      {required this.number, required this.unit, required this.state});
  final int number;
  final LearningUnit unit;
  final AppState state;
  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(borderRadius: BorderRadius.circular(22), onTap: () => openUnit(context, state, unit),
        child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
              backgroundColor: plum,
              foregroundColor: Colors.white,
              child: Text('$number')),
          const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(unit.title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6), Text('${unit.videos.length} video lessons  -  20 questions per assignment')
          ])), const SizedBox(width: 8), const Icon(Icons.chevron_right)
        ]))));
}

void openUnit(BuildContext context, AppState state, LearningUnit unit) =>
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => TopicVideos(unit: unit, state: state)));

class TopicVideos extends StatelessWidget {
  const TopicVideos({
    super.key,
    required this.unit,
    required this.state,
  });

  final LearningUnit unit;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(unit.title)),
      body: ResponsiveBody(maxWidth: 760, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(
            'Video lessons',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Use a topic specific YouTube search, then complete its '
            '20 question assignment.',
          ),
          const SizedBox(height: 18),
          ...unit.videos.asMap().entries.map((entry) {
            final video = entry.value;
            final hasAccess = state.canAccess(
              isFreePreview: video.isFreePreview,
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(borderRadius: BorderRadius.circular(22), onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => hasAccess
                    ? VideoLearningPage(unit: unit, video: video, state: state)
                    : payments.Plans(state: state)));
                }, child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(
                  backgroundColor: video.isFreePreview ? emerald : plum,
                  foregroundColor: Colors.white,
                  child: Icon(
                    hasAccess ? Icons.play_arrow : Icons.lock,
                  ),
                ),
                const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(
                  '${entry.key + 1}. ${video.title}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6), Text(
                  '${video.duration}   20 questions   '
                  '${video.isFreePreview ? 'FREE' : hasAccess ? 'UNLOCKED' : 'SUBSCRIBER'}\n'
                  '${video.sourceLabel} for ${unit.title}',
                )])), IconButton(
                  tooltip: 'Find lesson on YouTube',
                  icon: const Icon(Icons.open_in_new),
                  onPressed:
                      hasAccess ? () => open(context, video.sourceUrl) : null,
                )]))),
            );
          }),
        ])),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.subtitle});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Card(
      color: adaptiveTint(context, peach),
      child: ListTile(
          contentPadding: const EdgeInsets.all(AppSpacing.card),
          leading: const Icon(Icons.campaign_rounded, color: plum),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(subtitle)));
}

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key, required this.state, required this.repo});
  final AppState state;
  final DemoRepository repo;
  @override
  Widget build(BuildContext context) {
    final percent = repo.videos.isEmpty
        ? 0
        : ((state.completed.length / repo.videos.length) * 100)
            .clamp(0, 100)
            .round();
    return PageFrame(
        title: 'Subject mastery',
        subtitle: 'Honest on device analytics - not a global leaderboard.',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.all(AppSpacing.card),
              decoration: BoxDecoration(
                  color: adaptiveTint(context, const Color(0xFFDCEEE7), darkAlpha: .16),
                  borderRadius: BorderRadius.circular(24)),
              child: LayoutBuilder(builder: (context, c) {
                final compact = c.maxWidth < 360 ||
                    MediaQuery.textScalerOf(context).scale(1) >= 1.3;
                final gauge = SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(alignment: Alignment.center, children: [
                      CircularProgressIndicator(
                          value: state.quizAccuracy / 100,
                          color: emerald,
                          strokeWidth: 7),
                      Text('${state.quizAccuracy.round()}%',
                          style: const TextStyle(fontWeight: FontWeight.w900))
                    ]));
                final details = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('${state.onDeviceTier} tier',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(
                          '${state.quizScores.length} assignments  -  $percent% lessons watched'),
                      const Text('On device rank',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: emerald))
                    ]);
                if (compact) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [gauge, const SizedBox(height: 16), details]);
                }
                return Row(children: [
                  gauge,
                  const SizedBox(width: 18),
                  Expanded(child: details)
                ]);
              })),
          const SizedBox(height: 24),
          Text('Performance by subject',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, c) {
            final itemWidth = c.maxWidth >= 760 ? (c.maxWidth - 24) / 2 : c.maxWidth;
            return Wrap(spacing: 24, runSpacing: 4, children: repo.subjects.map((s) {
            final ids = {
              for (final u in s.units)
                for (final v in u.videos) v.id
            };
            final scores = state.quizScores.entries
                .where((e) => ids.contains(e.key))
                .map((e) => e.value)
                .toList();
            final accuracy = scores.isEmpty
                ? 0.0
                : scores.reduce((a, b) => a + b) / (scores.length * 20);
            return SizedBox(width: itemWidth, child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Text(s.shortName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700))),
                        Text('${(accuracy * 100).round()}%')
                      ]),
                      const SizedBox(height: 7),
                      LinearProgressIndicator(
                          value: accuracy,
                          color: s.color,
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 10)
                    ])));
          }).toList());
          }),
          if (state.quizScores.isEmpty)
            const _InfoTile(
                title: 'No quiz history yet',
                subtitle:
                    'Complete a video assignment and your score will appear here.')
          else ...[
            const SizedBox(height: 8),
            Text('Quiz history', style: Theme.of(context).textTheme.titleLarge),
            ...state.quizScores.entries.map((e) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(repo.videoById(e.key)?.title ?? e.key),
                subtitle: Text(repo.videoById(e.key) == null
                    ? 'Saved on this device'
                    : '${repo.videoById(e.key)!.duration} lesson'),
                trailing: Text('${e.value}/20',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, color: emerald))))
          ]
        ]));
  }
}

class Profile extends StatelessWidget {
  const Profile({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) => PageFrame(
      title: 'Profile',
      subtitle: 'Local account, support and policies.',
      child: Column(children: [
        CircleAvatar(
            radius: 36,
            backgroundColor: plum,
            foregroundColor: Colors.white,
            child: Text(state.name.isEmpty ? 'D' : state.name[0].toUpperCase(),
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w900))),
        const SizedBox(height: 10),
        Text(state.name, style: Theme.of(context).textTheme.titleLarge),
        Text(state.mobile),
        const SizedBox(height: 18),
        _Status(state),
        const SizedBox(height: 12),
        ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: const Text('Subscription & payment'),
            subtitle: const Text('UPI payment and pending verification'),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => payments.Plans(state: state)))),
        ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Contact & support'),
            subtitle: const Text('Call or WhatsApp +91 9632476598'),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const payments.SupportPage()))),
        SwitchListTile(
            value: state.dark,
            onChanged: state.toggleTheme,
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark theme')),
        ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Terms of Use'),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const LegalPage(document: LegalDocument.terms)))),
        ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const LegalPage(document: LegalDocument.privacy)))),
        ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Refund & Cancellation Policy'),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const LegalPage(document: LegalDocument.refunds)))),
        const Divider(),
        ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () async => state.logout())
      ]));
}

void _message(BuildContext c, String text) => showDialog(
    context: c,
    builder: (_) => AlertDialog(
            title: const Text('Production setup'),
            content: Text(text),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c), child: const Text('Close'))
            ]));
