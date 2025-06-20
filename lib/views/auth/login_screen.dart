import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/viewmodels/login_viewmodel.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';
import 'package:tourguideapp/widgets/social_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/core/services/firebase_auth_services.dart';
import 'signup_screen.dart';
import 'forgot_password_phone_screen.dart';
import 'package:tourguideapp/blocs/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('Error')),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).translate('OK')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        _showErrorDialog(AppLocalizations.of(context).translate('Please enter both email and password.'));
      }
      return;
    }

    try {
      User? user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return ChangeNotifierProvider<LoginViewModel>(
      create: (context) => LoginViewModel(
        authService: FirebaseAuthService(),
        authBloc: context.read<AuthBloc>(),
      ),
      child: Consumer<LoginViewModel>(
        builder: (context, loginViewModel, child) => Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              AbsorbPointer(
                absorbing: loginViewModel.isLoading, 
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 140.h, 20.w, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).translate('Sign in now'),
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 26.sp),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppLocalizations.of(context).translate('Please sign in to continue using our app'),
                        style: TextStyle(fontSize: 16.sp, color: const Color(0xFF7D848D)),
                      ),
                      SizedBox(height: 40.h),
                      Container(
                        padding: EdgeInsets.all(15.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTextField(
                              hintText: AppLocalizations.of(context).translate('Email'),
                              controller: _emailController,
                            ),
                            SizedBox(height: 16.h),
                            CustomPasswordField(
                              controller: _passwordController,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ForgotPasswordPhoneScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  AppLocalizations.of(context).translate('Forgot Password?'),
                                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFFFF7029)),
                                ),
                              ),
                            ),
                            SizedBox(height: 30.h),
                            ElevatedButton(
                              onPressed: loginViewModel.isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007BFF),
                                minimumSize: Size(double.infinity, 50.h),
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context).translate('Sign In'),
                                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16.sp),
                              ),
                            ),
                            SizedBox(height: 40.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context).translate("Don't have an account?"),
                                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF7D848D)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => SignupScreen()),
                                    );
                                  },
                                  child: Text(
                                    AppLocalizations.of(context).translate('Sign up'),
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp, color: const Color(0xFFFF7029)),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              AppLocalizations.of(context).translate('Or connect'),
                              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF7D848D)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 25.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SocialIconButton(
                            icon: FontAwesomeIcons.google,
                            label: AppLocalizations.of(context).translate('Google'),
                            color: const Color(0xFFDB4437),
                            onPressed: () async {
                              User? user = await loginViewModel.signInWithGoogle();
                              if (user != null && mounted) {
                                Navigator.pushReplacementNamed(context, '/home');
                              } else if (kDebugMode) {
                                print("Google login failed");
                              }
                            },
                          ),
                          SizedBox(width: 15.w),
                          SocialIconButton(
                            icon: FontAwesomeIcons.facebook,
                            label: AppLocalizations.of(context).translate('Facebook'),
                            color: const Color(0xFF4267B2),
                            onPressed: () async {
                              User? user = await loginViewModel.signInWithFacebook();
                              if (user != null && mounted) {
                                Navigator.pushReplacementNamed(context, '/home');
                              } else if (kDebugMode) {
                                print("Facebook login failed");
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (loginViewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5), // Màn hình xám với độ mờ
                  child: const Center(
                    child: CircularProgressIndicator(), // Hiển thị thanh trạng thái ở giữa màn hình
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
