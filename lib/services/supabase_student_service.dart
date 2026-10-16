import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStudentService {
  SupabaseStudentService(this.client);

  final SupabaseClient client;

  static String authEmailForMobile(String mobile) =>
      '${mobile.trim()}@students.dcet.local';

  bool get hasSession => client.auth.currentSession != null;
  String? get userId => client.auth.currentUser?.id;

  Future<void> register({
    required String fullName,
    required String mobile,
    required String password,
  }) async {
    final response = await client.auth.signUp(
      email: authEmailForMobile(mobile),
      password: password,
      data: {'full_name': fullName.trim(), 'mobile': mobile.trim()},
    );
    final user = response.user;
    if (user == null) throw const AuthException('Account creation failed.');
    if (response.session == null) {
      throw const AuthException(
        'Account created, but sign-in is waiting for confirmation. Disable email confirmation for the internal mobile-login flow, or configure a real email verification flow.',
      );
    }
    await client.from('profiles').upsert({
      'id': user.id,
      'full_name': fullName.trim(),
      'mobile': mobile.trim(),
      'email': null,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> login({
    required String mobile,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: authEmailForMobile(mobile),
      password: password,
    );
    if (response.user == null) {
      throw const AuthException('Invalid mobile number or password.');
    }
    return profile();
  }

  Future<void> logout() => client.auth.signOut();

  Future<Map<String, dynamic>> profile() async {
    final id = userId;
    if (id == null) throw const AuthException('No authenticated student.');
    return client.from('profiles').select().eq('id', id).single();
  }

  Future<List<Map<String, dynamic>>> activePlans() async {
    final rows = await client
        .from('subscription_plans')
        .select('id,plan_name,amount,duration_days')
        .eq('is_active', true)
        .order('duration_days');
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<Map<String, dynamic>> createPendingPayment({
    required String planName,
    required int amount,
    required String utr,
    required String paymentReference,
  }) async {
    if (userId == null) throw const AuthException('Please log in again.');
    final plan = await client
        .from('subscription_plans')
        .select('amount')
        .eq('plan_name', planName)
        .eq('is_active', true)
        .single();
    if ((plan['amount'] as num).round() != amount) {
      throw StateError('The selected plan price changed. Refresh and retry.');
    }
    final result = await client.rpc(
      'submit_payment_request',
      params: {
        'p_plan_name': planName,
        'p_utr_number': utr.trim().toUpperCase(),
        'p_payment_reference': paymentReference,
      },
    );
    return Map<String, dynamic>.from(result as Map);
  }

  Future<List<Map<String, dynamic>>> paymentRequests() async {
    final rows = await client
        .from('payment_requests')
        .select(
          'id,payment_reference,utr_number,amount,status,submitted_at,verified_at,rejection_reason,subscription_plans(plan_name,duration_days)',
        )
        .order('submitted_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<Map<String, dynamic>?> activeSubscription() async {
    final row = await client
        .from('subscriptions')
        .select('expiry_date,status,plan_name,payment_request_id')
        .eq('status', 'active')
        .gt('expiry_date', DateTime.now().toUtc().toIso8601String())
        .order('expiry_date', ascending: false)
        .limit(1)
        .maybeSingle();
    return row;
  }

  Future<Map<String, dynamic>> paymentStatus(String reference) async {
    final payment = await client
        .from('payment_requests')
        .select(
          'id,payment_reference,utr_number,amount,status,verified_at,subscription_plans(plan_name)',
        )
        .eq('payment_reference', reference)
        .single();
    final subscription = payment['status'] == 'approved'
        ? await client
            .from('subscriptions')
            .select('expiry_date,status')
            .eq('payment_request_id', payment['id'])
            .maybeSingle()
        : null;
    return {...payment, 'subscription': subscription};
  }
}
