import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:tourguideapp/services/firebase_auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupViewModel extends ChangeNotifier {
  final FirebaseAuthService _auth = FirebaseAuthService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId;
  int? _resendToken;
  bool _isCodeSent = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isCodeSent => _isCodeSent;

  Future<User?> signUp(
    String email,
    String password,
    String username,
    String fullName,
    String address,
    String gender,
    String citizenId,
    String phoneNumber,
    String nationality,
    String birthday,
    List<String> hobbies,
  ) async {
    try {
      final user = await _auth.signUpWithEmailAndPassword(
        email,
        password,
        username,
        fullName,
        address,
        gender,
        citizenId,
        phoneNumber,
        nationality,
        birthday,
        hobbies,
      );

      if (user != null) {
        // Initialize empty favorites lists
        await FirebaseFirestore.instance.collection('USER').doc(user.uid).update({
          'favoriteDestinationIds': [],
          'favoriteHotelIds': [],
          'favoriteRestaurantIds': [],
        });
      }

      return user;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return null; // User cancelled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      _errorMessage = 'Google sign-up failed. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<User?> signInWithFacebook() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final LoginResult loginResult = await FacebookAuth.instance.login();

    if (loginResult.status == LoginStatus.success) {
      final accessToken = loginResult.accessToken;
      if (accessToken != null) {
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(accessToken.tokenString);

        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
        return userCredential.user;
      } else {
        _errorMessage = 'Failed to get access token.';
      }
    } else {
      _errorMessage = 'Facebook sign-up failed: ${loginResult.message}';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> sendPhoneVerification(String phoneNumber) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 120),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            _isCodeSent = true;
            notifyListeners();
          } catch (e) {
            if (kDebugMode) {
              print('Auto-verification error: $e');
            }
            _errorMessage = 'Auto-verification failed: $e';
            notifyListeners();
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print('Verification Failed: ${e.message}');
            print('Error code: ${e.code}');
          }
          
          // Xử lý các mã lỗi cụ thể
          switch (e.code) {
            case 'invalid-phone-number':
              _errorMessage = 'The provided phone number is invalid.';
              break;
            case 'too-many-requests':
              _errorMessage = 'Too many requests. Please try again later.';
              break;
            case 'operation-not-allowed':
              _errorMessage = 'Phone number authentication is not enabled.';
              break;
            default:
              _errorMessage = e.message ?? 'An unknown error occurred.';
          }
          
          _isCodeSent = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          if (kDebugMode) {
            print('Code sent to $phoneNumber');
            print('VerificationId: $verificationId');
          }
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isCodeSent = true;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (kDebugMode) {
            print('Auto retrieval timeout');
          }
          _verificationId = verificationId;
          notifyListeners();
        },
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending verification code: $e');
      }
      _errorMessage = 'Failed to send verification code: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOTP(String otp) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_verificationId == null) {
        _errorMessage = 'Verification ID not found';
        return false;
      }

      // Create credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      // Sign in with credential
      await FirebaseAuth.instance.signInWithCredential(credential);
      return true;
    } catch (e) {
      _errorMessage = 'Invalid OTP: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
