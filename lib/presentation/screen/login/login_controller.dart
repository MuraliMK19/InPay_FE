import 'package:flutter/material.dart';
import 'package:inpay_app/presentation/screen/homepage/home_page.dart';
import '../../../data/services/api_services.dart';

class LoginController {
  final ApiService apiService = ApiService();

  Future<void> login(
    String userid,
    String password,
    BuildContext context,
  ) async {
    if (userid.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both userid and password")),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Logging in...")));

      final result = await apiService.login(userid, password);
      if (!context.mounted) return;

      // Now it is safe to hide snackbars and navigate
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Success: ${result['token']}")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      // Error message
      if (!context.mounted)
        return; // Always check before using context after an await

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login failed!")));
    }
  }
}
