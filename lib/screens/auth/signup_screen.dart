import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../auth/login_screen.dart';

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 150, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Phần tiêu đề
            const Text(
              'Sign up now',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
            ),
            
            const SizedBox(height: 10), 

            const Text(
              'Please fill the details and create account',
              style: TextStyle(fontSize: 16, color: Color(0xFF7D848D)),
            ),

            const SizedBox(height: 20),

            // Phần đăng ký
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomTextField(
                    hintText: 'Fullname',
                  ),
                  const SizedBox(height: 16.0),
                  const CustomTextField(
                    hintText: 'Email',
                  ),
                  const SizedBox(height: 16.0),
                  const CustomPasswordField(),
                  const SizedBox(height: 8.0),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "Password must be 8 character",
                        style: TextStyle(fontSize: 16, color: Color(0xFF7D848D)),
                      ),
                  ),
                  const SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: () {
                      // Xử lý đăng nhập
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24BAEC),
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(fontSize: 16, color: Color(0xFF7D848D)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Sign in',
                          style: TextStyle(fontSize: 16, color: Color(0xFFFF7029)),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Or connect',
                    style: TextStyle(fontSize: 16, color: Color(0xFF7D848D)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Biểu tượng đăng nhập xã hội
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SocialIconButton(
                  icon: FontAwesomeIcons.facebook,
                  color: const Color(0xFF4267B2),
                  onPressed: () {
                    // Xử lý đăng nhập Facebook
                  },
                ),
                const SizedBox(width: 30),
                SocialIconButton(
                  icon: FontAwesomeIcons.google,
                  color: const Color(0xFFDB4437),
                  onPressed: () {
                    // Xử lý đăng nhập Google
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF7F7F9),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}

class CustomPasswordField extends StatefulWidget {
  const CustomPasswordField({super.key});

  @override
  _CustomPasswordFieldState createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: 'Password',
        filled: true,
        fillColor: const Color(0xFFF7F7F9),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        } else if (value.length < 8) {
          return 'Password must be at least 8 characters long';
        }
        return null;
      },
    );
  }
}

class SocialIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const SocialIconButton({super.key, 
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: FaIcon(icon, color: color, size: 35),
      onPressed: onPressed,
    );
  }
}
