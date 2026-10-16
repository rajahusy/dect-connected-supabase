import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:dcet_master/core/app_state.dart';
import 'package:dcet_master/screens/payments.dart';
import 'package:dcet_master/screens/legal_pages.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

class FixedVerificationRepository implements PaymentVerificationRepository {
  FixedVerificationRepository(this.result);
  final PaymentVerificationResult result;
  @override
  Future<PaymentVerificationResult> getPaymentStatus(String reference) async =>
      result;
}

void main() {
  test('UPI URI contains exact dynamic payment fields', () {
    final uri = buildUpiUri(paymentPlans.first, 'DCET 123');
    expect(uri.scheme, 'upi');
    expect(uri.host, 'pay');
    expect(uri.queryParameters, containsPair('pa', upiId));
    expect(uri.queryParameters, containsPair('pn', payeeName));
    expect(uri.queryParameters, containsPair('am', '299.00'));
    expect(uri.queryParameters, containsPair('cu', 'INR'));
    expect(uri.queryParameters['tn'], contains('DCET 123'));
  });
  test('contact URLs and UTR validation are safe', () {
    expect(supportTelUri.toString(), 'tel:+919632476598');
    expect(buildWhatsAppUri('payment help').host, 'wa.me');
    expect(buildWhatsAppUri('payment help').path, contains(supportDigits));
    expect(isValidUtr('123456789012'), isTrue);
    expect(isValidUtr('123 45'), isFalse);
    expect(isValidUtr('short'), isFalse);
  });
  test('submission persists as pending without entitlement', () async {
    final store = MemoryStore(), state = AppState(store: store);
    await state.load();
    final request = PaymentRequest(
        reference: 'DCET 123',
        plan: '30 days',
        amount: 299,
        utr: '123456789012',
        timestamp: DateTime(2026, 7, 22));
    await state.submitPaymentRequest(request);
    expect(state.isSubscribed, isFalse);
    expect(state.paymentRequests.single.status, 'submitted');
    final restored = AppState(store: store);
    await restored.load();
    expect(restored.paymentRequests.single.reference, 'DCET 123');
    expect(restored.isSubscribed, isFalse);
  });
  test('verification message contains complete student and payment identity',
      () async {
    final state = AppState(store: MemoryStore());
    await state.load();
    await state.register('A Very Long Student Name', '9876543210', 'secret');
    final request = PaymentRequest(
        reference: 'DCET 123',
        plan: '30 days',
        amount: 299,
        utr: 'ABC123456789',
        timestamp: DateTime(2026, 7, 22, 14, 30));
    final message = paymentVerificationMessage(state, request);
    for (final value in [
      'A Very Long Student Name',
      '9876543210',
      '30 days',
      'Rs 299',
      'ABC123456789',
      'DCET 123',
      '22/07/2026 14:30'
    ]) {
      expect(message, contains(value));
    }
  });
  test('duplicate normalized UTR is rejected and sent state persists',
      () async {
    final store = MemoryStore(), state = AppState(store: store);
    await state.load();
    PaymentRequest request(String utr) => PaymentRequest(
        reference: 'DCET 123',
        plan: '30 days',
        amount: 299,
        utr: utr,
        timestamp: DateTime(2026, 7, 22));
    expect(await state.submitPaymentRequest(request('abc12345678')), isTrue);
    expect(await state.submitPaymentRequest(request(' ABC12345678 ')), isFalse);
    expect(state.paymentRequests, hasLength(1));
    await state.markPaymentSentToSupport('DCET 123',
        sentAt: DateTime(2026, 7, 22, 15));
    expect(state.isSubscribed, isFalse);
    final restored = AppState(store: store);
    await restored.load();
    expect(restored.paymentRequests.single.status, 'sent_to_support');
    expect(restored.paymentRequests.single.supportSentAt,
        DateTime(2026, 7, 22, 15));
    expect(restored.isSubscribed, isFalse);
  });
  test('plan amount remains identical across request, UPI and message', () async {
    final state = AppState(store: MemoryStore());
    await state.load();
    await state.register('Student', '9876543210', 'secret');
    for (final plan in paymentPlans) {
      final request = PaymentRequest(
          reference: 'DCET amount',
          plan: plan.name,
          amount: plan.amount,
          utr: 'UTR12345678',
          timestamp: DateTime(2026, 7, 22));
      expect(buildUpiUri(plan, request.reference).queryParameters['am'],
          '${request.amount}.00');
      expect(paymentVerificationMessage(state, request),
          contains('Amount: Rs ${request.amount}'));
    }
  });
  test('only a trusted exact verification match activates access', () async {
    final store = MemoryStore(), state = AppState(store: store);
    await state.load();
    await state.register('Student', '9876543210', 'secret');
    final request = PaymentRequest(
        reference: 'DCET secure', plan: '30 days', amount: 299,
        utr: 'ABC123456789', timestamp: DateTime.now());
    await state.submitPaymentRequest(request);
    PaymentVerificationResult result({bool authenticated = true,
      String provenance = 'signed-api-response', String reference = 'DCET secure',
      String marker = 'verified-server-session',
      String account = '9876543210',
      String mobile = '9876543210', String utr = 'ABC123456789',
      int amount = 299, String plan = '30 days'}) => PaymentVerificationResult(
        authenticated: authenticated, provenance: provenance,
        authenticationMarker: marker,
        reference: reference, registeredMobile: mobile, accountId: account,
        normalizedUtr: utr,
        amount: amount, plan: plan, status: PaymentVerificationStatus.verified,
        expiry: DateTime.now().add(const Duration(days: 30)));
    for (final forged in [result(authenticated: false), result(provenance: ''),
      result(marker: ''),
      result(account: 'other-account'),
      result(reference: 'OTHER'), result(mobile: '9000000000'),
      result(utr: 'WRONG123456'), result(amount: 1), result(plan: '365 days')]) {
      expect(await state.refreshPaymentStatus(
          request.reference, FixedVerificationRepository(forged)), isFalse);
      expect(state.isSubscribed, isFalse);
    }
    expect(await state.refreshPaymentStatus(
        request.reference, FixedVerificationRepository(result())), isTrue);
    expect(state.isSubscribed, isTrue);
    expect(state.paymentRequests.single.status, 'verified');
    final restored = AppState(store: store);
    await restored.load();
    expect(restored.paymentRequests.single.status, 'verified');
    expect(restored.paymentRequests.single.verifiedExpiry, isNotNull);
  });

  testWidgets('verification stays disabled until terms accepted',
      (tester) async {
    final state = AppState(store: MemoryStore());
    await tester.pumpWidget(MaterialApp(home: Plans(state: state)));
    final button = tester.widget<FilledButton>(find.widgetWithText(
        FilledButton, 'I have paid   request verification'));
    expect(button.onPressed, isNull);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    final enabled = tester.widget<FilledButton>(find.widgetWithText(
        FilledButton, 'I have paid   request verification'));
    expect(enabled.onPressed, isNotNull);
  });
  testWidgets('legal pages expose required documents', (tester) async {
    for (final item in [
      (LegalDocument.terms, 'Terms of Use'),
      (LegalDocument.privacy, 'Privacy Policy'),
      (LegalDocument.refunds, 'Refund & Cancellation Policy')
    ]) {
      await tester.pumpWidget(MaterialApp(home: LegalPage(document: item.$1)));
      expect(find.text(item.$2), findsOneWidget);
      expect(find.textContaining('22 July 2026'), findsOneWidget);
    }
  });
  testWidgets('plan switching updates exact QR UPI value', (tester) async {
    final state = AppState(store: MemoryStore());
    await tester.pumpWidget(MaterialApp(home: Plans(state: state)));
    final first = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(first.data, contains('am=299.00'));
    await tester.tap(find.text('180 days   Rs 1299'));
    await tester.pump();
    final second = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(second.data, contains('am=1299.00'));
    expect(second.data, contains(Uri.encodeComponent('180 days')));
  });
  testWidgets('pending request card fits 320px and exposes support actions',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = AppState(store: MemoryStore());
    await state.load();
    await state.register(
        'A Very Long Registered Student Name', '9876543210', 'secret');
    await state.submitPaymentRequest(PaymentRequest(
        reference: 'DCET 12345678901234567890',
        plan: '30 days',
        amount: 299,
        utr: 'ABC123456789',
        timestamp: DateTime(2026, 7, 22)));
    await tester.pumpWidget(MaterialApp(home: Plans(state: state)));
    await tester.drag(find.byType(Scrollable), const Offset(0, -1600));
    await tester.pumpAndSettle();
    expect(find.text('Send to support on WhatsApp'), findsOneWidget);
    expect(find.text('Refresh verification status'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('trusted persisted payment renders Verified', (tester) async {
    final state = AppState(store: MemoryStore());
    await state.load();
    await state.register('Student', '9876543210', 'secret');
    final request = PaymentRequest(reference: 'DCET verified', plan: '30 days',
        amount: 299, utr: 'ABC123456789', timestamp: DateTime.now());
    await state.submitPaymentRequest(request);
    await state.refreshPaymentStatus(request.reference,
        FixedVerificationRepository(PaymentVerificationResult(
            authenticated: true, provenance: 'signed-api-response',
            authenticationMarker: 'verified-server-session',
            reference: request.reference, registeredMobile: state.mobile,
            accountId: state.mobile,
            normalizedUtr: request.normalizedUtr, amount: request.amount,
            plan: request.plan, status: PaymentVerificationStatus.verified,
            expiry: DateTime.now().add(const Duration(days: 30)))));
    await tester.pumpWidget(MaterialApp(home: Plans(state: state)));
    await tester.drag(find.byType(Scrollable), const Offset(0, -1600));
    await tester.pumpAndSettle();
    expect(find.text('VERIFIED'), findsOneWidget);
  });
  testWidgets('WhatsApp action has a per-card busy guard', (tester) async {
    final state = AppState(store: MemoryStore());
    await state.load();
    await state.submitPaymentRequest(PaymentRequest(
        reference: 'DCET busy', plan: '30 days', amount: 299,
        utr: 'ABC123456789', timestamp: DateTime.now()));
    final pendingLaunch = Completer<bool>();
    var launches = 0;
    await tester.pumpWidget(MaterialApp(home: Plans(
        state: state,
        paymentSupportLauncher: (_) {
          launches++;
          return pendingLaunch.future;
        })));
    await tester.drag(find.byType(Scrollable), const Offset(0, -1600));
    await tester.pump();
    await tester.tap(find.text('Send to support on WhatsApp'));
    await tester.pump();
    expect(find.text('Opening WhatsApp...'), findsOneWidget);
    await tester.tap(find.text('Opening WhatsApp...'));
    expect(launches, 1);
    pendingLaunch.complete(false);
    await tester.pump();
  });
  testWidgets('duplicate UTR highlights the existing request', (tester) async {
    final state = AppState(store: MemoryStore());
    await state.load();
    await state.submitPaymentRequest(PaymentRequest(
        reference: 'DCET duplicate', plan: '30 days', amount: 299,
        utr: 'ABC123456789', timestamp: DateTime.now()));
    await tester.pumpWidget(MaterialApp(home: Plans(state: state)));
    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit another payment'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), ' abc123456789 ');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.text('I have paid   request verification'));
    await tester.pumpAndSettle();
    expect(find.textContaining('already submitted'), findsOneWidget);
    final card = tester.widget<Card>(find.byType(Card).last);
    expect((card.shape! as RoundedRectangleBorder).side.width, 2);
    expect(state.paymentRequests, hasLength(1));
  });
}
