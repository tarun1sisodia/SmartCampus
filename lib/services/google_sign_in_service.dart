import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class GoogleSignInService extends GetxService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final supabase = Supabase.instance.client;

  Future<GoogleSignInService> init() async {
    await _googleSignIn.initialize(
      hostedDomain: '',
    );
    return this;
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential for Supabase
      final AuthResponse res = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
      );

      return res.user;
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      // print('Error signing in with Google: $error');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await supabase.auth.signOut();
  }
}
