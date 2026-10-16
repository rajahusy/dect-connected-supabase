import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_student_service.dart';

class PaymentRequest {
  const PaymentRequest(
      {required this.reference,
      required this.plan,
      required this.amount,
      required this.utr,
      required this.timestamp,
      this.status = 'submitted',
      this.supportSentAt,
      this.verifiedAt,
      this.verifiedExpiry});
  final String reference, plan, utr, status;
  final int amount;
  final DateTime timestamp;
  final DateTime? supportSentAt;
  final DateTime? verifiedAt, verifiedExpiry;
  String get normalizedUtr => utr.trim().toUpperCase();
  PaymentRequest copyWith(
          {String? status,
          DateTime? supportSentAt,
          DateTime? verifiedAt,
          DateTime? verifiedExpiry}) =>
      PaymentRequest(
          reference: reference,
          plan: plan,
          amount: amount,
          utr: utr,
          timestamp: timestamp,
          status: status ?? this.status,
          supportSentAt: supportSentAt ?? this.supportSentAt,
          verifiedAt: verifiedAt ?? this.verifiedAt,
          verifiedExpiry: verifiedExpiry ?? this.verifiedExpiry);
  String encode() => [
        reference,
        plan,
        amount,
        utr,
        timestamp.millisecondsSinceEpoch,
        status,
        supportSentAt?.millisecondsSinceEpoch ?? '',
        verifiedAt?.millisecondsSinceEpoch ?? '',
        verifiedExpiry?.millisecondsSinceEpoch ?? ''
      ].join('|');
  static PaymentRequest? decode(String value) {
    final p = value.split('|');
    if (p.length < 6 || p.length > 9) return null;
    final a = int.tryParse(p[2]), t = int.tryParse(p[4]);
    if (a == null || t == null) return null;
    return PaymentRequest(
        reference: p[0],
        plan: p[1],
        amount: a,
        utr: p[3],
        timestamp: DateTime.fromMillisecondsSinceEpoch(t),
        status: p[5],
        supportSentAt: p.length == 7 && p[6].isNotEmpty
            ? DateTime.fromMillisecondsSinceEpoch(int.parse(p[6]))
            : p.length > 6 && p[6].isNotEmpty
                ? DateTime.fromMillisecondsSinceEpoch(int.parse(p[6]))
                : null,
        verifiedAt: p.length > 7 && p[7].isNotEmpty
            ? DateTime.fromMillisecondsSinceEpoch(int.parse(p[7]))
            : null,
        verifiedExpiry: p.length > 8 && p[8].isNotEmpty
            ? DateTime.fromMillisecondsSinceEpoch(int.parse(p[8]))
            : null);
  }
}

enum PaymentVerificationStatus { pending, verified }

class PaymentVerificationResult {
  const PaymentVerificationResult(
      {required this.authenticated,
      required this.provenance,
      required this.authenticationMarker,
      required this.reference,
      required this.registeredMobile,
      required this.accountId,
      required this.normalizedUtr,
      required this.amount,
      required this.plan,
      required this.status,
      this.expiry});
  final bool authenticated;
  final String provenance,
      authenticationMarker,
      reference,
      registeredMobile,
      accountId,
      normalizedUtr,
      plan;
  final int amount;
  final PaymentVerificationStatus status;
  final DateTime? expiry;
}

abstract class PaymentVerificationRepository {
  Future<PaymentVerificationResult> getPaymentStatus(String reference);
}

abstract class PreferencesStore {
  Future<bool?> getBool(String key);
  Future<int?> getInt(String key);
  Future<String?> getString(String key);
  Future<List<String>?> getStringList(String key);
  Future<void> setBool(String key, bool value);
  Future<void> setInt(String key, int value);
  Future<void> setString(String key, String value);
  Future<void> setStringList(String key, List<String> value);
  Future<void> remove(String key);
}

class SharedPreferencesStore implements PreferencesStore {
  Future<SharedPreferences> get _p => SharedPreferences.getInstance();
  @override
  Future<bool?> getBool(String k) async => (await _p).getBool(k);
  @override
  Future<int?> getInt(String k) async => (await _p).getInt(k);
  @override
  Future<String?> getString(String k) async => (await _p).getString(k);
  @override
  Future<List<String>?> getStringList(String k) async =>
      (await _p).getStringList(k);
  @override
  Future<void> setBool(String k, bool v) async {
    await (await _p).setBool(k, v);
  }

  @override
  Future<void> setInt(String k, int v) async {
    await (await _p).setInt(k, v);
  }

  @override
  Future<void> setString(String k, String v) async {
    await (await _p).setString(k, v);
  }

  @override
  Future<void> setStringList(String k, List<String> v) async {
    await (await _p).setStringList(k, v);
  }

  @override
  Future<void> remove(String k) async {
    await (await _p).remove(k);
  }
}

class AppState extends ChangeNotifier implements PaymentVerificationRepository {
  AppState({PreferencesStore? store, SupabaseStudentService? backend})
      : _store = store ?? SharedPreferencesStore(),
        backend = backend;
  final PreferencesStore _store;
  final SupabaseStudentService? backend;
  bool get backendEnabled => backend != null;
  bool dark = false, initialized = false, signedIn = false;
  String name = '', mobile = '';
  DateTime? subscriptionExpiry;
  final Set<String> completed = {};
  final Map<String, int> quizScores = {};
  final List<PaymentRequest> paymentRequests = [];
  bool get isSubscribed => subscriptionExpiry?.isAfter(DateTime.now()) ?? false;
  bool canAccess({required bool isFreePreview}) =>
      isFreePreview || isSubscribed;
  double get quizAccuracy => quizScores.isEmpty
      ? 0
      : quizScores.values.reduce((a, b) => a + b) /
          (quizScores.length * 20) *
          100;
  String get onDeviceTier => tierForAccuracy(quizAccuracy);
  static String tierForAccuracy(double accuracy) {
    if (accuracy >= 85) return 'Master';
    if (accuracy >= 70) return 'Proficient';
    if (accuracy >= 50) return 'Improving';
    return 'Foundation';
  }

  Future<void> load() async {
    dark = await _store.getBool('dark') ?? false;
    signedIn = await _store.getBool('signedIn') ?? false;
    name = await _store.getString('name') ?? '';
    mobile = await _store.getString('mobile') ?? '';
    final x = await _store.getInt('subscriptionExpiry');
    subscriptionExpiry =
        x == null ? null : DateTime.fromMillisecondsSinceEpoch(x);
    completed
      ..clear()
      ..addAll(await _store.getStringList('completed') ?? []);
    quizScores.clear();
    for (final e in await _store.getStringList('quizScores') ?? []) {
      final i = e.lastIndexOf(':');
      if (i > 0) {
        final v = int.tryParse(e.substring(i + 1));
        if (v != null) quizScores[e.substring(0, i)] = v;
      }
    }
    paymentRequests.clear();
    final seenUtrs = <String>{};
    for (final request in (await _store.getStringList('paymentRequests') ?? [])
        .map(PaymentRequest.decode)
        .whereType<PaymentRequest>()) {
      if (seenUtrs.add(request.normalizedUtr)) paymentRequests.add(request);
    }
    if (backendEnabled && backend!.hasSession) {
      try {
        final profile = await backend!.profile();
        name = (profile['full_name'] as String?)?.trim() ?? name;
        mobile = (profile['mobile'] as String?)?.trim() ?? mobile;
        signedIn = true;
        await syncBackendState();
      } catch (_) {
        signedIn = false;
      }
    }
    initialized = true;
    notifyListeners();
  }

  String _digest(String m, String password) {
    var hash = 0x811c9dc5;
    for (final unit in 'dcet local v1:$m:$password'.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  Future<void> register(String n, String m, [String password = '']) async {
    name = n.trim();
    mobile = m.trim();
    if (backendEnabled) {
      await backend!.register(fullName: name, mobile: mobile, password: password);
      signedIn = true;
      await syncBackendState();
    } else {
      signedIn = true;
      await _store.setString('credentialDigest', _digest(mobile, password));
    }
    await _store.setString('name', name);
    await _store.setString('mobile', mobile);
    await _store.setBool('signedIn', true);
    notifyListeners();
  }

  Future<bool> login(String m, [String password = '']) async {
    mobile = m.trim();
    if (backendEnabled) {
      try {
        final profile = await backend!.login(mobile: mobile, password: password);
        name = (profile['full_name'] as String?)?.trim() ?? 'DCET Learner';
        mobile = (profile['mobile'] as String?)?.trim() ?? mobile;
        signedIn = true;
        await syncBackendState();
      } catch (_) {
        return false;
      }
    } else {
      final savedMobile = await _store.getString('mobile');
      final savedDigest = await _store.getString('credentialDigest');
      if (savedMobile != mobile || savedDigest != _digest(mobile, password)) {
        return false;
      }
      signedIn = true;
      if (name.isEmpty) name = 'DCET Learner';
    }
    await _store.setString('name', name);
    await _store.setString('mobile', mobile);
    await _store.setBool('signedIn', true);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    if (backendEnabled) await backend!.logout();
    signedIn = false;
    subscriptionExpiry = null;
    paymentRequests.clear();
    await _store.setBool('signedIn', false);
    await _store.remove('subscriptionExpiry');
    await _persistPaymentRequests();
    notifyListeners();
  }

  Future<void> toggleTheme(bool v) async {
    dark = v;
    notifyListeners();
    await _store.setBool('dark', v);
  }

  Future<void> activateDemo(Duration d) async {
    subscriptionExpiry = DateTime.now().add(d);
    notifyListeners();
    await _store.setInt(
        'subscriptionExpiry', subscriptionExpiry!.millisecondsSinceEpoch);
  }

  Future<void> resetSubscription() async {
    subscriptionExpiry = null;
    notifyListeners();
    await _store.remove('subscriptionExpiry');
  }

  Future<void> complete(String id) async {
    completed.add(id);
    notifyListeners();
    await _store.setStringList('completed', completed.toList());
  }

  Future<void> recordQuiz(String id, int score) async {
    quizScores[id] = score;
    notifyListeners();
    await _store.setStringList('quizScores',
        quizScores.entries.map((e) => '${e.key}:${e.value}').toList());
  }

  PaymentRequest? paymentRequestForUtr(String utr) {
    final normalized = utr.trim().toUpperCase();
    for (final request in paymentRequests) {
      if (request.normalizedUtr == normalized) return request;
    }
    return null;
  }

  Future<bool> submitPaymentRequest(PaymentRequest request) async {
    if (paymentRequestForUtr(request.utr) != null) return false;
    if (backendEnabled) {
      await backend!.createPendingPayment(
        planName: request.plan,
        amount: request.amount,
        utr: request.utr,
        paymentReference: request.reference,
      );
    }
    paymentRequests.insert(0, request.copyWith(status: 'pending'));
    notifyListeners();
    await _persistPaymentRequests();
    return true;
  }

  Future<void> markPaymentSentToSupport(String reference,
      {DateTime? sentAt}) async {
    final index = paymentRequests.indexWhere((r) => r.reference == reference);
    if (index < 0) return;
    paymentRequests[index] = paymentRequests[index].copyWith(
        status: 'sent_to_support', supportSentAt: sentAt ?? DateTime.now());
    notifyListeners();
    await _persistPaymentRequests();
  }

  Future<bool> refreshPaymentStatus(String reference,
      PaymentVerificationRepository repository) async {
    final index = paymentRequests.indexWhere((r) => r.reference == reference);
    if (index < 0) return false;
    final request = paymentRequests[index];
    final result = await repository.getPaymentStatus(reference);
    if (!result.authenticated ||
        result.provenance.trim().isEmpty ||
        result.authenticationMarker.trim().isEmpty ||
        result.reference != request.reference ||
        result.registeredMobile != mobile ||
        result.accountId != mobile ||
        result.normalizedUtr.trim().toUpperCase() != request.normalizedUtr ||
        result.amount != request.amount ||
        result.plan != request.plan ||
        result.status != PaymentVerificationStatus.verified ||
        result.expiry == null ||
        !result.expiry!.isAfter(DateTime.now())) return false;
    subscriptionExpiry = result.expiry;
    paymentRequests[index] = request.copyWith(
        status: 'verified',
        verifiedAt: DateTime.now(),
        verifiedExpiry: result.expiry);
    await _store.setInt(
        'subscriptionExpiry', subscriptionExpiry!.millisecondsSinceEpoch);
    await _persistPaymentRequests();
    notifyListeners();
    return true;
  }

  Future<void> syncBackendState() async {
    if (!backendEnabled || !backend!.hasSession) return;
    final rows = await backend!.paymentRequests();
    paymentRequests
      ..clear()
      ..addAll(rows.map((row) {
        final plan = row['subscription_plans'] as Map<String, dynamic>?;
        return PaymentRequest(
          reference: row['payment_reference'] as String,
          plan: (plan?['plan_name'] as String?) ?? 'DCET plan',
          amount: (row['amount'] as num).round(),
          utr: row['utr_number'] as String,
          timestamp: DateTime.parse(row['submitted_at'] as String).toLocal(),
          status: row['status'] as String,
          verifiedAt: row['verified_at'] == null
              ? null
              : DateTime.parse(row['verified_at'] as String).toLocal(),
        );
      }));
    final subscription = await backend!.activeSubscription();
    subscriptionExpiry = subscription == null
        ? null
        : DateTime.parse(subscription['expiry_date'] as String).toLocal();
    if (subscriptionExpiry == null) {
      await _store.remove('subscriptionExpiry');
    } else {
      await _store.setInt(
        'subscriptionExpiry',
        subscriptionExpiry!.millisecondsSinceEpoch,
      );
    }
    await _persistPaymentRequests();
    notifyListeners();
  }

  @override
  Future<PaymentVerificationResult> getPaymentStatus(String reference) async {
    if (!backendEnabled) {
      throw StateError('Supabase backend is not configured.');
    }
    final row = await backend!.paymentStatus(reference);
    final plan = row['subscription_plans'] as Map<String, dynamic>?;
    final subscription = row['subscription'] as Map<String, dynamic>?;
    final approved = row['status'] == 'approved' &&
        subscription?['status'] == 'active' &&
        subscription?['expiry_date'] != null;
    return PaymentVerificationResult(
      authenticated: backend!.hasSession,
      provenance: 'supabase_rls',
      authenticationMarker: backend!.userId ?? '',
      reference: row['payment_reference'] as String,
      registeredMobile: mobile,
      accountId: mobile,
      normalizedUtr: (row['utr_number'] as String).trim().toUpperCase(),
      amount: (row['amount'] as num).round(),
      plan: (plan?['plan_name'] as String?) ?? '',
      status: approved
          ? PaymentVerificationStatus.verified
          : PaymentVerificationStatus.pending,
      expiry: approved
          ? DateTime.parse(subscription!['expiry_date'] as String).toLocal()
          : null,
    );
  }

  Future<void> _persistPaymentRequests() => _store.setStringList(
      'paymentRequests', paymentRequests.map((e) => e.encode()).toList());
}
