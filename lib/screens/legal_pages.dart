import 'package:flutter/material.dart';
import '../widgets/responsive_layout.dart';

enum LegalDocument { terms, privacy, refunds }

class LegalPage extends StatelessWidget {
  const LegalPage({super.key, required this.document});
  final LegalDocument document;
  static const updated = '22 July 2026';
  String get title => switch (document) {
        LegalDocument.terms => 'Terms of Use',
        LegalDocument.privacy => 'Privacy Policy',
        LegalDocument.refunds => 'Refund & Cancellation Policy'
      };
  List<(String, String)> get sections => switch (document) {
        LegalDocument.terms => [
            (
              'Release review required',
              'This practical draft is not legal advice. A lawyer must review it before release; confirm the operator business address, tax registration, invoice process and court venue.'
            ),
            (
              'Operator and purpose',
              'DCET Master is operated by Mallesh Kodabala. Support: +91 9632476598. It provides educational preparation and is not affiliated with the Government of Karnataka, KEA or DTE. Always verify official information at its original source.'
            ),
            (
              'Accounts and eligibility',
              'Provide accurate registration information and protect your account. A parent or guardian should supervise use by a minor where required by law.'
            ),
            (
              'Free and paid access',
              'Free resources are identified in the app. Paid access is a personal, limited, non transferable licence for the duration and price shown before payment. Access begins only after trusted payment verification; submitting a UTR does not activate it. There is no guarantee of exam score, rank, admission or uninterrupted availability.'
            ),
            (
              'Content and acceptable use',
              'Do not copy, redistribute, scrape, resell, bypass access controls or share accounts. External YouTube, KEA, DTE, UPI and messaging services have their own terms and availability.'
            ),
            (
              'Payments',
              'Current manual UPI access is non renewing. A UPI app return or screenshot cannot prove payment. Taxes and invoices will be handled where legally applicable. Google Play builds offering digital content must use Play Billing unless an eligible alternative program applies.'
            ),
            (
              'Termination and liability',
              'Access may be suspended for misuse. Services and educational materials are provided subject to applicable law without a promise of uninterrupted or error free operation. Liability limitations and Karnataka court jurisdiction require lawyer review.'
            ),
            (
              'Changes and contact',
              'Material changes will be dated in app. Questions: call or WhatsApp +91 9632476598.'
            ),
          ],
        LegalDocument.privacy => [
            (
              'Release review required',
              'This draft needs legal review and a confirmed operator address, grievance contact and production data architecture before release.'
            ),
            (
              'Data in this build',
              'The app stores name, phone number, a local password digest, profile/session, progress, quiz answers and scores, theme, subscription preview, and pending payment reference/UTR on this device. The local digest is not production grade authentication. Bank credentials and card data are not collected.'
            ),
            (
              'Use and basis',
              'Data supports account access, learning progress, preferences, support and payment verification requests, based on providing the requested service and your choices/consent where required. Personal data is not sold. Analytics or advertising will require later notice and consent if introduced.'
            ),
            (
              'External services',
              'Opening WhatsApp, phone, YouTube, KEA/DTE or a UPI app sends you to that provider; its privacy policy applies. A WhatsApp verification message shares the information visible in the prepared message.'
            ),
            (
              'Retention and security',
              'Local data remains until app data is cleared or deletion is requested/implemented. Device storage has security limits; this build does not claim server encryption or controls. Production systems must define retention and appropriate safeguards.'
            ),
            (
              'Rights, deletion and minors',
              "Contact +91 9632476598 to request access, correction or deletion. Current local data can also be removed by clearing app storage. Identity may need verification. Parents/guardians should contact support about a minor's data."
            ),
            (
              'Changes',
              'Policy changes will show a revised date. Contact support with privacy questions.'
            ),
          ],
        LegalDocument.refunds => [
            (
              'Current purchase model',
              'Manual UPI access is one time and non renewing; there is no auto renewal to cancel. Future Play Billing purchases will follow Google Play management and refund rules.'
            ),
            (
              'How to request',
              'WhatsApp +91 9632476598 with account phone, UTR, payment date, amount and reason. Never send a UPI PIN, OTP, card details or banking password.'
            ),
            (
              'Review',
              'Duplicate and failed payments will be checked against provider records. Refund eligibility may consider digital content already accessed, while preserving mandatory statutory rights. A typed UTR or screenshot alone is not proof of settlement.'
            ),
            (
              'Destination and timing',
              'Approved refunds return through an appropriate original/provider supported route after approval and payment provider processing. No fixed completion time is promised until operations and provider timelines are confirmed.'
            ),
          ]
      };
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ResponsiveBody(maxWidth: 760, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Last updated: $updated',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 18),
        for (final s in sections) ...[
          Text(s.$1, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          SelectableText(s.$2, style: const TextStyle(height: 1.55)),
          const SizedBox(height: 20)
        ]
      ])));
}
