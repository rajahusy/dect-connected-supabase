import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_state.dart';
import 'legal_pages.dart';
import '../widgets/responsive_layout.dart';

const supportPhone = '+919632476598',
    supportDigits = '919632476598',
    upiId = 'malleshkodabala87@oksbi',
    payeeName = 'Mallesh Kodabala';
const enableDeveloperEntitlementPreview = bool.fromEnvironment(
    'DCET_ENABLE_ENTITLEMENT_PREVIEW',
    defaultValue: false);
typedef Plan = ({String name, int days, int amount});
const paymentPlans = <Plan>[
  (name: '30 days', days: 30, amount: 299),
  (name: '180 days', days: 180, amount: 1299),
  (name: '365 days', days: 365, amount: 1999)
];
String paymentReference([DateTime? now]) =>
    'DCET ${(now ?? DateTime.now()).millisecondsSinceEpoch}';
Uri buildUpiUri(Plan plan, String reference) =>
    Uri(scheme: 'upi', host: 'pay', queryParameters: {
      'pa': upiId,
      'pn': payeeName,
      'am': plan.amount.toStringAsFixed(2),
      'cu': 'INR',
      'tn': 'DCET Master ${plan.name} $reference'
    });
Uri buildWhatsAppUri(String message) => Uri.parse(
    'https://wa.me/$supportDigits?text=${Uri.encodeComponent(message)}');
Uri get supportTelUri => Uri(scheme: 'tel', path: supportPhone);
bool isValidUtr(String value) =>
    RegExp(r'^[A-Za-z0-9]{8,24}$').hasMatch(value.trim());

String paymentVerificationMessage(AppState state, PaymentRequest request) =>
    'DCET Master payment verification\n'
    'Student name: ${state.name}\n'
    'Registered mobile: ${state.mobile}\n'
    'Plan: ${request.plan}\n'
    'Amount: Rs ${request.amount}\n'
    'UTR: ${request.utr}\n'
    'Request ID: ${request.reference}\n'
    'Submitted: ${formatPaymentTime(request.timestamp)}\n'
    'Please verify this payment and activate my subscription access.';

String formatPaymentTime(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}/${value.year} '
      '${two(value.hour)}:${two(value.minute)}';
}

Future<bool> launchOrExplain(BuildContext context, Uri uri) async {
  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Could not open ${uri.scheme}. Copy the details and try on your phone.')));
    }
    return opened;
  } catch (_) {
    if (context.mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Could not open ${uri.scheme}. Copy the details and try on your phone.')));
    return false;
  }
}

Future<void> copyWithConfirmation(
    BuildContext context, String value, String label) async {
  await Clipboard.setData(ClipboardData(text: value));
  if (context.mounted)
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label copied.')));
}

class Plans extends StatefulWidget {
  const Plans(
      {super.key,
      required this.state,
      this.verificationRepository,
      this.paymentSupportLauncher});
  final AppState state;
  final PaymentVerificationRepository? verificationRepository;
  final Future<bool> Function(Uri uri)? paymentSupportLauncher;
  @override
  State<Plans> createState() => _PlansState();
}

class _PlansState extends State<Plans> {
  int selected = 0;
  late String reference = paymentReference();
  final utr = TextEditingController();
  bool accepted = false;
  bool submitting = false;
  bool showNewRequest = false;
  String? highlightedReference;
  final Map<String, GlobalKey> requestKeys = {};
  Plan get plan => paymentPlans[selected];
  Uri get upi => buildUpiUri(plan, reference);
  @override
  void dispose() {
    utr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Subscription & payment')),
      body: ResponsiveBody(
          maxWidth: 1040,
          child: LayoutBuilder(
              builder: (context, c) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Learn without interruption.',
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        const Text(
                            'One time, non renewing access. Notes, syllabus, previous papers, cutoffs and updates remain free.'),
                        const SizedBox(height: 18),
                        Wrap(spacing: 10, runSpacing: 10, children: [
                          for (final e in paymentPlans.indexed)
                            ChoiceChip(
                                selected: selected == e.$1,
                                label: Text('${e.$2.name}   Rs ${e.$2.amount}'),
                                onSelected: (_) => setState(() {
                                      selected = e.$1;
                                      reference = paymentReference();
                                    }))
                        ]),
                        const SizedBox(height: 12),
                        Semantics(
                            label:
                                'Selected ${plan.name} plan, exact price Rs ${plan.amount}, one time non renewing access',
                            child: Container(
                                padding: const EdgeInsets.all(AppSpacing.card),
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainer,
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outlineVariant),
                                    borderRadius: BorderRadius.circular(16)),
                                child: Text(
                                    '${plan.days} days   Rs ${plan.amount}   one time, non renewing\nIncludes all topic videos, quizzes, and original model papers.\nAlways free: syllabus, previous paper indexes, notes, cutoffs, and updates.',
                                    style: const TextStyle(
                                        height: 1.5,
                                        fontWeight: FontWeight.w600)))),
                        const SizedBox(height: 18),
                        Container(
                            padding: const EdgeInsets.all(AppSpacing.card),
                            decoration: BoxDecoration(
                                color: const Color(0xFF4B306D),
                                borderRadius: BorderRadius.circular(22)),
                            child: c.maxWidth < 480 ||
                                    MediaQuery.textScalerOf(context).scale(1) >=
                                        1.3
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                        const Text('PAYABLE TO',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.w800)),
                                        const Text(payeeName,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 21,
                                                fontWeight: FontWeight.w900)),
                                        Text('${plan.name}   $reference',
                                            style: const TextStyle(
                                                color: Colors.white70)),
                                        const SizedBox(height: 12),
                                        Text('Rs ${plan.amount}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 30,
                                                fontWeight: FontWeight.w900))
                                      ])
                                : Row(children: [
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          const Text('PAYABLE TO',
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w800)),
                                          const Text(payeeName,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.w900)),
                                          Text('${plan.name}   $reference',
                                              style: const TextStyle(
                                                  color: Colors.white70))
                                        ])),
                                    Text('Rs ${plan.amount}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                            fontWeight: FontWeight.w900))
                                  ])),
                        const SizedBox(height: 18),
                        Flex(
                            direction: c.maxWidth > 760
                                ? Axis.horizontal
                                : Axis.vertical,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExpandedIf(
                                  horizontal: c.maxWidth > 760,
                                  child: Container(
                                      color: Colors.white,
                                      padding: const EdgeInsets.all(16),
                                      child: Column(children: [
                                        Semantics(
                                            label:
                                                'UPI payment QR for ${plan.name}, Rs ${plan.amount}, payee $payeeName',
                                            image: true,
                                            child: QrImageView(
                                                data: upi.toString(),
                                                size: (c.maxWidth - 80)
                                                    .clamp(140.0, 250.0),
                                                padding:
                                                    const EdgeInsets.all(12),
                                                backgroundColor: Colors.white)),
                                        SelectableText(upiId,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w800)),
                                        TextButton.icon(
                                            onPressed: () =>
                                                copyWithConfirmation(
                                                    context, upiId, 'UPI ID'),
                                            icon: const Icon(Icons.copy),
                                            label: const Text('Copy UPI ID'))
                                      ]))),
                              SizedBox(
                                  width: c.maxWidth > 760 ? 24 : 0,
                                  height: c.maxWidth > 760 ? 0 : 20),
                              ExpandedIf(
                                  horizontal: c.maxWidth > 760,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const Text('Pay using UPI',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900)),
                                        const Text(
                                            'Works with an installed UPI app such as Google Pay or PhonePe. On web/desktop, scan this QR using your phone.'),
                                        const SizedBox(height: 12),
                                        FilledButton.icon(
                                            onPressed: () =>
                                                launchOrExplain(context, upi),
                                            icon: const Icon(Icons.open_in_new),
                                            label: const Text(
                                                'Pay with any UPI app')),
                                        const SizedBox(height: 12),
                                        const ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading:
                                                Icon(Icons.account_balance),
                                            title: Text('Net Banking'),
                                            subtitle: Text(
                                                'Secure merchant gateway setup required   unavailable in this build.')),
                                        const ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Icon(Icons.security),
                                            title:
                                                Text('Automated verification'),
                                            subtitle: Text(
                                                'Requires server created orders, signature checks, idempotent webhooks, receipts/refunds and entitlement activation.'))
                                      ]))
                            ]),
                        const SizedBox(height: 22),
                        if (widget.state.paymentRequests.isEmpty ||
                            showNewRequest) ...[
                          const Text('Request verification',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w900)),
                          const Text(
                              'After paying, enter the bank/UPI transaction reference. This creates only a pending request and opens WhatsApp; it never unlocks access automatically.'),
                          const SizedBox(height: 12),
                          TextField(
                              controller: utr,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (accepted) submit();
                              },
                              decoration: const InputDecoration(
                                  labelText: 'UTR / transaction reference',
                                  helperText: '8-24 letters or digits only')),
                          CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: accepted,
                              onChanged: (v) =>
                                  setState(() => accepted = v ?? false),
                              title: Wrap(children: [
                                const Text('I accept the '),
                                _LegalLink('Terms', LegalDocument.terms),
                                const Text(', '),
                                _LegalLink(
                                    'Privacy Policy', LegalDocument.privacy),
                                const Text(' and '),
                                _LegalLink(
                                    'Refund Policy', LegalDocument.refunds)
                              ])),
                          FilledButton.icon(
                              onPressed:
                                  accepted && !submitting ? submit : null,
                              icon: const Icon(Icons.verified_user_outlined),
                              label: const Text(
                                  'I have paid   request verification')),
                        ] else ...[
                          const Text('Next step',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 6),
                          const Text(
                              'Use the WhatsApp button on your payment request below. Support will verify the UTR before access can activate.'),
                          TextButton.icon(
                              onPressed: () =>
                                  setState(() => showNewRequest = true),
                              icon: const Icon(Icons.add),
                              label: const Text('Submit another payment')),
                        ],
                        const SizedBox(height: 20),
                        Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                                borderRadius: BorderRadius.circular(16)),
                            child: const Text(
                                'How approval works: support checks your UTR against the bank/UPI receipt. Access activates only after a server/admin verifies it. A WhatsApp message alone is not proof. Never share a UPI PIN, OTP, card number or banking password.',
                                style: TextStyle(fontWeight: FontWeight.w700))),
                        if (widget.state.paymentRequests.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const Text('Payment requests',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w900)),
                          for (final r in widget.state.paymentRequests)
                            _PaymentRequestCard(
                                key: requestKeys.putIfAbsent(
                                    r.reference, () => GlobalKey()),
                                request: r,
                                highlighted:
                                    highlightedReference == r.reference,
                                onSend: () => sendToSupport(r),
                                onRefresh: () => refreshStatus(r))
                        ],
                        if (enableDeveloperEntitlementPreview) ...[
                          const Divider(height: 40),
                          Container(
                              padding: const EdgeInsets.all(AppSpacing.card),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                      .withValues(alpha: .45),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: .45)),
                                  borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Icon(Icons.science_outlined,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                          child: Text('Subscription demo',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900)))
                                    ]),
                                    const SizedBox(height: 8),
                                    const Text(
                                        'Local testing only. No payment is made or verified. This panel is hidden unless the developer preview flag is enabled.'),
                                    const SizedBox(height: 12),
                                    Text(
                                        widget.state.isSubscribed
                                            ? 'Demo access active until ${formatPaymentTime(widget.state.subscriptionExpiry!)}'
                                            : 'Demo access is inactive',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: widget.state.isSubscribed
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant)),
                                    const SizedBox(height: 12),
                                    Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: [
                                          FilledButton.icon(
                                              onPressed: activateDemo,
                                              icon: const Icon(
                                                  Icons.lock_open_outlined),
                                              label: Text(
                                                  'Activate ${plan.days}-day demo')),
                                          OutlinedButton.icon(
                                              onPressed:
                                                  widget.state.isSubscribed
                                                      ? resetDemo
                                                      : null,
                                              icon: const Icon(
                                                  Icons.timer_off_outlined),
                                              label: const Text(
                                                  'Expire demo access'))
                                        ]),
                                    const SizedBox(height: 10),
                                    const Text(
                                        'Demo access unlocks subscriber-only videos, quizzes and model papers on this device. It does not create or approve a payment request.',
                                        style: TextStyle(
                                            fontSize: 13, height: 1.35))
                                  ]))
                        ]
                      ]))));

  Future<void> activateDemo() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
                title: const Text('Activate subscription demo?'),
                content: Text(
                    'This grants local test access for ${plan.days} days. No payment will be made or verified.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Activate demo'))
                ]));
    if (confirmed != true) return;
    await widget.state.activateDemo(Duration(days: plan.days));
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '${plan.days}-day local demo access is active. No payment was made.')));
  }

  Future<void> resetDemo() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
                title: const Text('Expire demo access?'),
                content: const Text(
                    'Subscriber-only content will be locked again on this device.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Keep access')),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Expire demo'))
                ]));
    if (confirmed != true) return;
    await widget.state.resetSubscription();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local demo access has expired.')));
  }

  Future<void> submit() async {
    if (submitting) return;
    if (!isValidUtr(utr.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid 8-24 character UTR.')));
      return;
    }
    final existing = widget.state.paymentRequestForUtr(utr.text);
    if (existing != null) {
      setState(() => highlightedReference = existing.reference);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'This UTR was already submitted. Use Resend details on the existing request.')));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = requestKeys[existing.reference]?.currentContext;
        if (target != null) {
          Scrollable.ensureVisible(target,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              alignment: .2);
        }
      });
      return;
    }
    setState(() => submitting = true);
    final request = PaymentRequest(
        reference: reference,
        plan: plan.name,
        amount: plan.amount,
        utr: utr.text.trim(),
        timestamp: DateTime.now());
    try {
      final added = await widget.state.submitPaymentRequest(request);
      if (!mounted) return;
      setState(() => submitting = false);
      if (!added) return;
      await sendToSupport(request);
    } catch (error) {
      if (!mounted) return;
      setState(() => submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not submit payment request: $error'),
      ));
    }
  }

  Future<void> sendToSupport(PaymentRequest request) async {
    final message = paymentVerificationMessage(widget.state, request);
    final uri = buildWhatsAppUri(message);
    final opened = widget.paymentSupportLauncher != null
        ? await widget.paymentSupportLauncher!(uri)
        : await launchOrExplain(context, uri);
    if (!mounted || !opened) return;
    await widget.state.markPaymentSentToSupport(request.reference);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Verification message prepared. Send it in WhatsApp to support.')));
    setState(() {});
  }

  Future<void> refreshStatus(PaymentRequest request) async {
    final repository = widget.verificationRepository ??
        (widget.state.backendEnabled ? widget.state : null);
    if (repository == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'A secure backend connection is required to refresh verification status.')));
      return;
    }
    final verified =
        await widget.state.refreshPaymentStatus(request.reference, repository);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(verified
            ? 'Payment verified. Subscription access is active.'
            : 'Payment is not verified yet. Please check again later.')));
    setState(() {});
  }
}

class _PaymentRequestCard extends StatefulWidget {
  const _PaymentRequestCard(
      {super.key,
      required this.request,
      required this.onSend,
      required this.onRefresh,
      this.highlighted = false});
  final PaymentRequest request;
  final Future<void> Function() onSend, onRefresh;
  final bool highlighted;

  @override
  State<_PaymentRequestCard> createState() => _PaymentRequestCardState();
}

class _PaymentRequestCardState extends State<_PaymentRequestCard> {
  bool sending = false, refreshing = false;

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final sent = request.supportSentAt != null;
    final verified = request.status == 'verified' &&
        request.verifiedExpiry?.isAfter(DateTime.now()) == true;
    return Semantics(
        label:
            'Payment ${verified ? 'verified' : sent ? 'sent to support' : 'pending, send details'} '
            'for ${request.plan}, Rs ${request.amount}',
        child: Card(
            margin: const EdgeInsets.only(top: 12),
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: verified
                        ? const Color(0xFF16865B)
                        : widget.highlighted
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                    width: widget.highlighted ? 2 : 1),
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(
                                verified
                                    ? Icons.verified
                                    : Icons.pending_actions,
                                color: verified
                                    ? const Color(0xFF16865B)
                                    : const Color(0xFFE28A00)),
                            Text('${request.plan}  Rs ${request.amount}',
                                style: Theme.of(context).textTheme.titleMedium),
                            Chip(
                                backgroundColor: verified
                                    ? const Color(0xFFCDEEDC)
                                    : const Color(0xFFFFE7B2),
                                label: Text(verified
                                    ? 'VERIFIED'
                                    : sent
                                        ? 'SENT TO SUPPORT'
                                        : 'PENDING - SEND DETAILS'))
                          ]),
                      const SizedBox(height: 10),
                      SelectableText('Request: ${request.reference}'),
                      const SizedBox(height: 4),
                      SelectableText('UTR: ${request.utr}'),
                      Text(
                          'Submitted: ${formatPaymentTime(request.timestamp)}'),
                      if (request.supportSentAt != null)
                        Text(
                            'Last sent: ${formatPaymentTime(request.supportSentAt!)}'),
                      if (verified)
                        Text(
                            'Access until: ${formatPaymentTime(request.verifiedExpiry!)}',
                            style: const TextStyle(
                                color: Color(0xFF16865B),
                                fontWeight: FontWeight.w800)),
                      const SizedBox(height: 14),
                      if (!verified)
                        SizedBox(
                            height: 48,
                            child: FilledButton.icon(
                                onPressed: sending
                                    ? null
                                    : () async {
                                        setState(() => sending = true);
                                        await widget.onSend();
                                        if (mounted)
                                          setState(() => sending = false);
                                      },
                                icon: const Icon(Icons.chat),
                                label: Text(sending
                                    ? 'Opening WhatsApp...'
                                    : sent
                                        ? 'Resend details'
                                        : 'Send to support on WhatsApp'))),
                      const SizedBox(height: 8),
                      SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                              onPressed: verified || refreshing
                                  ? null
                                  : () async {
                                      setState(() => refreshing = true);
                                      await widget.onRefresh();
                                      if (mounted)
                                        setState(() => refreshing = false);
                                    },
                              icon: const Icon(Icons.refresh),
                              label: Text(refreshing
                                  ? 'Checking securely...'
                                  : verified
                                      ? 'Verified'
                                      : 'Refresh verification status')))
                    ]))));
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink(this.text, this.doc);
  final String text;
  final LegalDocument doc;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
      child: InkWell(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => LegalPage(document: doc))),
          child: Center(
              child: Text(text,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w700)))));
}

class ExpandedIf extends StatelessWidget {
  const ExpandedIf({super.key, required this.horizontal, required this.child});
  final bool horizontal;
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      horizontal ? Expanded(child: child) : child;
}

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Contact & support')),
      body: ResponsiveBody(
          maxWidth: 760,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('How can we help?',
                style: Theme.of(context).textTheme.headlineMedium),
            const Text('Response times may vary.'),
            const SizedBox(height: 18),
            SelectableText('+91 9632476598',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            FilledButton.icon(
                onPressed: () => launchOrExplain(context, supportTelUri),
                icon: const Icon(Icons.call),
                label: const Text('Call support')),
            OutlinedButton.icon(
                onPressed: () => launchOrExplain(
                    context,
                    buildWhatsAppUri(
                        'Hello DCET Master support, I need help with my account.')),
                icon: const Icon(Icons.chat),
                label: const Text('WhatsApp support')),
            TextButton.icon(
                onPressed: () => copyWithConfirmation(
                    context, supportPhone, 'Support number'),
                icon: const Icon(Icons.copy),
                label: const Text('Copy number')),
            const Divider(height: 34),
            for (final p in [
              (
                'Payment help',
                'I need help with a DCET Master payment. My order/UTR is: '
              ),
              (
                'Content issue',
                'I found a content issue in DCET Master. Subject/topic: '
              ),
              (
                'Account support',
                'I need help with my DCET Master account. Registered phone: '
              )
            ])
              ListTile(
                  leading: const Icon(Icons.arrow_outward),
                  title: Text(p.$1),
                  onTap: () => launchOrExplain(context, buildWhatsAppUri(p.$2)))
          ])));
}
