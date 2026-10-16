# DCET Master mobile

A Flutter learning companion for Karnataka diploma students preparing for DCET.

## Run and verify

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
```

## Subscription demo mode

To test the subscriber-only videos, quizzes and model papers locally without
making or verifying a payment, run:

```sh
flutter run -d chrome --dart-define=DCET_ENABLE_ENTITLEMENT_PREVIEW=true
```

The subscription screen will show a clearly labeled **Subscription demo** panel
where the selected plan duration can be activated or expired on the current
device. Demo actions never create or approve a payment request.

Normal app runs keep this panel hidden:

```sh
flutter run -d chrome
```

Demo mode is local testing only. Do not enable
`DCET_ENABLE_ENTITLEMENT_PREVIEW` in release builds.

## What works offline

  Validated registration/login with a local profile and persisted session
  Exactly five subjects with syllabus topics and a Watch -  Learn -  Quiz flow
  First topic video section and quiz free in every subject
  Subscriber gating for later topic videos/quizzes and original model papers
  Free syllabus, previous paper indexes, notes, cutoff references, and updates
  Persisted quiz scores, completion progress, theme, and local access preview

## Production boundary

This repository does not claim server authentication, OTP, payment processing, protected streaming, or official data. Before release, connect secure authentication; store billing and server side receipt validation; licensed video hosting; verified KEA syllabus, paper, cutoff, and update sources; published terms/privacy URLs; and a verified support channel.

The bundled lessons and quizzes are original educational starter material, not official examination papers. Prices are presentation references. The clearly labeled subscriber preview makes no charge and stores entitlement only on the device.

The offline profile stores a dependency free one way credential digest rather than plaintext. It is sufficient only to compare credentials locally and is not cryptographically suitable for production authentication; replace it with server side password hashing and rate limited authentication before release.

## Payments and release blockers

The included QR and `upi://pay` intent initiate a real transfer to `malleshkodabala87@oksbi`, but a client callback, screenshot or typed UTR cannot establish settlement. Verification requests remain pending and never grant entitlement. Before automated checkout, complete merchant onboarding and implement server created orders, signature verification, idempotent webhooks, receipts/invoices, tax handling, refunds and server owned entitlements. Keep gateway and webhook secrets out of Flutter.

Digital education subscriptions distributed through Google Play generally require Google Play Billing unless the app is enrolled in an eligible alternative billing program. The personal UPI flow must not be presented as automatically Play compliant subscription billing. Confirm current policy before release.

Release also requires legal review of the in app Terms, Privacy, and Refund drafts; a business/service address and grievance contact; confirmed tax/invoice practice; production authentication and deletion workflows; and tested payment/support operations. The developer subscriber preview is explicitly test only and must be removed or protected from customer builds.

## Connected Supabase payment flow

When `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` are provided, the app now:

1. Registers/signs in the student through Supabase Auth using the mobile number as an internal login identifier.
2. Creates/updates the student's protected `profiles` row.
3. Submits the selected plan and UTR through `submit_payment_request`; the database supplies the trusted amount and forces `pending` status.
4. Loads only the signed-in student's payment requests through RLS.
5. Refreshes an approved payment and reads the server-created subscription expiry.

For this internal mobile-number/password login flow, open Supabase Dashboard → Authentication → Providers → Email and turn off **Confirm email**. The generated internal address is not presented to the student and no email is sent. For a public production release, replace this with verified phone OTP or a real verified email flow.

The plan names and prices must match `admin_dashboard/supabase/seed.sql` exactly.
