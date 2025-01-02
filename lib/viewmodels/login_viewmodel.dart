import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/services/firebase_auth_services.dart';
import 'package:tourguideapp/models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Initialize Firestore
  bool isLoading = false;
  String? errorMessage;
  String? _verificationId;
  int? _resendToken;
  String? foundUserName;

  // Login with Email and Password
  Future<User?> signIn(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      User? user = await _authService.signInWithEmailAndPassword(email, password);
      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'Login failed. Please try again later.';
      }
    } catch (e) {
      errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return null;
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isLoading = false;
        notifyListeners();
        return null; // User cancelled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      // Check if user exists in Firestore
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('USER').doc(user.uid).get();
        if (!doc.exists) {
          await createNewUserWithSocialAuth(
            user,
            displayName: googleUser.displayName,
            photoURL: googleUser.photoUrl,
          );
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'An account already exists with a different credential.';
          break;
        case 'invalid-credential':
          errorMessage = 'The credential is invalid or expired.';
          break;
        default:
          errorMessage = 'Login with Google failed. Please try again.';
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error during Google sign-in: $e');
        print('Stack trace: $stackTrace');
      }
      errorMessage = 'An unexpected error occurred during Google login.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return null;
  }

  // Login with Facebook
  Future<User?> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    if (loginResult.status == LoginStatus.success) {
      // Create a credential from the access token
      final accessToken = loginResult.accessToken;
      if (accessToken != null) {
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(accessToken.tokenString);

        // Once signed in, return the UserCredential
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
        User? user = userCredential.user;

        // Check if user is null
        if (user != null) {
          final userData = await FacebookAuth.instance.getUserData();
          DocumentSnapshot doc = await _firestore.collection('USER').doc(user.uid).get();
          if (!doc.exists) {
            await createNewUserWithSocialAuth(
              user,
              displayName: userData['name'],
              photoURL: userData['picture']?['data']?['url'],
            );
          }
        } else {
          errorMessage = 'Failed to get user data.';
        }
        return user;
      } else {
        errorMessage = 'Failed to get access token.';
        notifyListeners();
        return null;
      }
    } else {
      // Handle login failure cases
      errorMessage = 'Facebook login failed: ${loginResult.message}';
      notifyListeners();
      return null;
    }
  }

  Future<void> createNewUserWithSocialAuth(User firebaseUser, {String? displayName, String? photoURL}) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('USER')
          .orderBy('userId', descending: true)
          .limit(1)
          .get();

      String newUserId;
      if (snapshot.docs.isNotEmpty) {
        String lastUserId = snapshot.docs.first['userId'];
        int lastIdNumber = int.parse(lastUserId.substring(1));
        newUserId = 'U${(lastIdNumber + 1).toString().padLeft(5, '0')}';
      } else {
        newUserId = 'U00001';
      }

      UserModel newUser = UserModel(
        userId: newUserId,
        uid: firebaseUser.uid,
        name: displayName ?? firebaseUser.displayName ?? 'User',
        fullName: '',
        email: firebaseUser.email ?? '',
        address: '',
        gender: '',
        citizenId: '',
        phoneNumber: firebaseUser.phoneNumber ?? '',
        nationality: '',
        birthday: '',
        avatar: photoURL ?? firebaseUser.photoURL ?? '',
        hobbies: [],
        favoriteDestinationIds: [],
        favoriteHotelIds: [],
        favoriteRestaurantIds: [],
      );

      await _firestore.collection('USER').doc(firebaseUser.uid).set(newUser.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error creating new user: $e');
      }
      throw Exception('Failed to create new user');
    }
  }

  Future<bool> sendPasswordResetOTP(String phoneNumber) async {
    try {
      isLoading = true;
      notifyListeners();

      // Kiểm tra số điện thoại có tồn tại trong hệ thống không
      QuerySnapshot userQuery = await _firestore
          .collection('USER')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        errorMessage = 'No account found with this phone number';
        foundUserName = null;
        return false;
      }

      // Lưu tên user để hiển thị
      foundUserName = userQuery.docs.first.get('name') as String?;
      
      // Lưu user ID để dùng khi reset password
      String userId = userQuery.docs.first.id;
      await _firestore.collection('USER').doc(userId).update({
        'resetPasswordRequest': true,
        'resetPasswordTimestamp': FieldValue.serverTimestamp(),
      });

      // Gửi OTP thông qua Firebase
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          errorMessage = e.message;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
      );

      return true;
    } catch (e) {
      print('Error sending OTP: $e');
      errorMessage = 'Failed to send verification code';
      foundUserName = null;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyPasswordResetOTP(String otp) async {
    try {
      isLoading = true;
      notifyListeners();

      if (_verificationId == null) {
        errorMessage = 'Verification ID not found';
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
      print('Error verifying OTP: $e');
      errorMessage = 'Invalid verification code';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String phoneNumber, String newPassword) async {
    try {
      isLoading = true;
      notifyListeners();

      // Tìm user với số điện thoại đã xác thực
      QuerySnapshot userQuery = await _firestore
          .collection('USER')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('resetPasswordRequest', isEqualTo: true)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        errorMessage = 'Invalid reset password request';
        return false;
      }

      String userId = userQuery.docs.first.id;
      
      // Cập nhật mật khẩu mới
      await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
      
      // Cập nhật trạng thái trong Firestore
      await _firestore.collection('USER').doc(userId).update({
        'resetPasswordRequest': false,
        'resetPasswordTimestamp': null,
      });

      // Đăng xuất sau khi đổi mật khẩu
      await FirebaseAuth.instance.signOut();

      return true;
    } catch (e) {
      print('Error resetting password: $e');
      errorMessage = 'Failed to reset password';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
